// ignore_for_file: constant_identifier_names

/// Build on a https://pub.dev/packages/animated_stream_list package
///
///
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'diff_applier.dart';
import 'list_controller.dart';
import 'myers_diff.dart';

enum _ListViewType {
  Listener,
  Value,
}

class AnimatedBlocListBuilder {
  ///
  /// Default animated wrapper for active items.
  /// Wrapper just adds TransitionAnimation for inserting new items.
  /// [animation] should be provided by [AnimatedStreamListItemBuilder]
  /// [child] is your list item.
  static Widget defaultTile(
    Animation<double> animation,
    Widget child,
  ) {
    return SizeTransition(
      axis: Axis.vertical,
      sizeFactor: animation,
      child: child,
    );
  }

  ///
  /// Default animated wrapper for removed items.
  /// Wrapper adds TransitionAnimation, FadeTransition and blocks all clicks for item.
  /// [animation] should be provided by [AnimatedBlocListItemBuilder]
  /// [child] is your list item.
  static Widget defaultRemovedTile(Animation<double> animation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        axis: Axis.vertical,
        sizeFactor: animation,
        child: IgnorePointer(child: child),
      ),
    );
  }
}

///
/// ListView with insert and remove animations
/// [AnimateBlocList] has 2 variants of use:
///
/// 1 variant:
/// ```dart
/// AnimateBlocList<Null, Null, ListDataType>(
///   scrollPhysics: NeverScrollableScrollPhysics(), ```/// If parent is also list ```
///   shrinkWrap: true,                              ```/// If parent is also list ```
///   equals: (item1, item2) => item1 == item2, ```/// return true if equals.```
///   initialList: listData, ```/// provide here your List<ListDataType>```
///   itemBuilder: (ListDataType item, int index, BuildContext context, Animation<double> animation) =>
///     AnimateBlocListBuilder.defaultTile(
///       ```/// You can use [defaultTile] or create your own Tiles with animations.
///          /// There is also doc for [defaultTile] method. ```
///       animation,
///       ``` your child here ```,
///     ),
///   itemRemovedBuilder: (ListDataType item, int index, BuildContext context, Animation<double> animation) =>
///     AnimateBlocListBuilder.defaultRemovedTile(
///       ```/// You can use [defaultRemovedTile] or create your own removeTiles with animations.
///          /// There is also doc for [defaultRemovedTile] method. ```
///       animation,
///       ``` your child here ```,
///     )
///   ),
/// )
/// ```
///
/// 2 variant: (With block listener)
/// ```dart
/// AnimateBlocList<YourBloc, YourBlocState, ListDataType>.withListener(
///   scrollPhysics: NeverScrollableScrollPhysics(), ```/// If parent is also list ```
///   shrinkWrap: true,                              ```/// If parent is also list ```
///   equals: (item1, item2) => item1 == item2, ```/// return true if equals.```
///   initialList: listData, ```/// provide here your initial List<ListDataType>. Will be used once.```
///   valueFromState: (context, state) {
///     ```/// This method will be called when your bloc state will be changed.
///        /// You should return your current List<ListDataType> here to make list
///        /// run insert or delete animations. If returned null, list will not be updated.
///        /// example: ```
///     if (state is StateLoaded && !listData.isNullOrEmpty){
///       return listData;
///     }
///
///     return null;
///   },
///   itemBuilder: (ListDataType item, int index, BuildContext context, Animation<double> animation) =>
///     AnimateBlocListBuilder.defaultTile(
///       animation,
///       ``` your child here ```,
///     ),
///   itemRemovedBuilder: (ListDataType item, int index, BuildContext context, Animation<double> animation) =>
///     AnimateBlocListBuilder.defaultRemovedTile(
///       animation,
///       ``` your child here ```,
///     )
///   ),
/// )
/// ```
///
///
/// Variants difference:
/// If you want to use ValueType (variant 1), data will be updated every call of build method.
/// If there is no changes after previous build you will not see any animations.
///
/// If you want to use ListenerType (variant 2), valueFromState will be called after state of bloc
/// was changed. If you want list to be updated after valueFromState called, return non-null data there.
///
/// There are also other default parameters of ListView.
class AnimatedBlocList<BlocType extends Cubit<BlocState>, BlocState, E> extends StatefulWidget {
  final List<E> initialList;
  final AnimatedStreamListItemBuilder<E> itemBuilder;
  final AnimatedStreamListItemBuilder<E> itemRemovedBuilder;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? scrollController;
  final bool? primary;
  final ScrollPhysics? scrollPhysics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final Equalizer? equals;
  final Duration duration;
  final List<E>? Function(BuildContext context, BlocState state)? valueFromState;
  final _ListViewType type;

  const AnimatedBlocList({
    required this.initialList,
    required this.itemBuilder,
    required this.itemRemovedBuilder,
    Key? key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.scrollController,
    this.primary,
    this.scrollPhysics,
    this.shrinkWrap = false,
    this.padding,
    this.equals,
    this.duration = const Duration(milliseconds: 300),
  })  : valueFromState = null,
        type = _ListViewType.Value,
        super(key: key);

  const AnimatedBlocList.withListener({
    required this.valueFromState,
    required this.itemBuilder,
    required this.itemRemovedBuilder,
    required this.initialList,
    Key? key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.scrollController,
    this.primary,
    this.scrollPhysics,
    this.shrinkWrap = false,
    this.padding,
    this.equals,
    this.duration = const Duration(milliseconds: 300),
  })  : type = _ListViewType.Listener,
        super(key: key);

  @override
  State<StatefulWidget> createState() => _AnimatedBlocListState<BlocType, BlocState, E>();
}

class _AnimatedBlocListState<BlocType extends Cubit<BlocState>, BlocState, E>
    extends State<AnimatedBlocList<BlocType, BlocState, E>> with WidgetsBindingObserver {
  final GlobalKey<AnimatedListState> _globalKey = GlobalKey();
  late ListController<E> _listController;
  late DiffApplier<E> _diffApplier;
  late DiffUtil<E> _diffUtil;
  StreamSubscription? _subscription;
  StreamController<List<E>> streamListController = StreamController<List<E>>();

  void startListening() {
    streamListController = StreamController<List<E>>();

    _subscription?.cancel();
    _subscription = streamListController.stream
        .asyncExpand((list) => _diffUtil
                .calculateDiff(_listController.items, list, equalizer: widget.equals)
                .then((list) {
              final result = _diffApplier.applyDiffs(list);
              return result;
            }).asStream())
        .listen((list) {});

    streamListController.add(copy(widget.initialList));
  }

  copy(List<E>? list) => list?.map((e) => e).toList();

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void initState() {
    super.initState();

    _listController = ListController(
        key: _globalKey,
        items: copy(widget.initialList) ?? <E>[],
        itemRemovedBuilder: widget.itemRemovedBuilder,
        duration: widget.duration);

    _diffApplier = DiffApplier(_listController);
    _diffUtil = DiffUtil();

    startListening();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        startListening();
        break;
      case AppLifecycleState.paused:
        stopListening();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == _ListViewType.Value) {
      streamListController.add(copy(widget.initialList));
    }

    return listenerWrapper(
        child: AnimatedList(
      initialItemCount: _listController.items.length,
      key: _globalKey,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      primary: widget.primary,
      controller: widget.scrollController,
      physics: widget.scrollPhysics,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      itemBuilder: (BuildContext context, int index, Animation<double> animation) =>
          widget.itemBuilder(
        _listController[index],
        index,
        context,
        animation,
      ),
    ));
  }

  listenerWrapper({required Widget child}) {
    if (widget.type == _ListViewType.Value) {
      return child;
    }

    return BlocListener<BlocType, BlocState>(
      listener: (context, state) {
        List<E>? newList = widget.valueFromState?.call(context, state);
        if (newList != null) {
          streamListController.add(copy(newList));
        }
      },
      child: child,
    );
  }
}
