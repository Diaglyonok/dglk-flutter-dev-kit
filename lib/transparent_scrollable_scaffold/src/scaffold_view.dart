import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TransparentScrollableScaffold extends StatefulWidget {
  final Widget child;
  final Widget Function(Color?) titleBuilder;
  final bool hasScrollBody;
  final Widget? floatingActionButton;
  final bool useShadow;
  final Color firstColor;
  final Color secondColor;
  final Widget Function(Color?)? leftIconBuilder;
  final Widget Function(Color?)? rightIconBuilder;
  final double opacityBorder;
  final double footerHeight;
  final ScrollController? childScrollController;
  final Future<void> Function()? refreshCallback;
  final bool onlyShadowOpacity;
  final double titleHeight;
  final Color? backgroundColor;
  final Brightness? brightness;

  const TransparentScrollableScaffold(
      {required this.titleBuilder,
      Key? key,
      required this.child,
      this.childScrollController,
      this.brightness,
      this.refreshCallback,
      this.useShadow = true,
      this.onlyShadowOpacity = false,
      this.hasScrollBody = true,
      this.floatingActionButton,
      this.firstColor = Colors.white,
      this.secondColor = Colors.black,
      this.opacityBorder = OpacityAppBar.DEFAULT_OPACITY_BORDER,
      this.leftIconBuilder,
      this.footerHeight = 80.0,
      this.titleHeight = 60.0,
      this.backgroundColor,
      this.rightIconBuilder})
      : super(key: key);

  @override
  TransparentScrollableScaffoldState createState() => TransparentScrollableScaffoldState();
}

class TransparentScrollableScaffoldState extends State<TransparentScrollableScaffold>
    with TickerProviderStateMixin {
  ScrollController scrollController = ScrollController();
  double offset = 0.0;

  Future<void> resetScrollPosition() async {
    final realController = widget.childScrollController ?? scrollController;
    await realController.animateTo(-10.0,
        duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  @override
  void initState() {
    final realController = widget.childScrollController ?? scrollController;
    realController.addListener(() {
      if (!realController.hasClients || realController.positions.length > 1) {
        offset = 0.0;
      } else {
        offset = realController.offset;
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      backgroundColor: widget.backgroundColor ?? Colors.white,
      body: ScrollConfiguration(
        behavior: NoGlowBehaviour(),
        child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
          var refreshCallback = widget.refreshCallback;
          if (refreshCallback != null) {
            return RefreshIndicator(
              displacement: 98,
              child: _scrollableWrapper(widget.child)!,
              onRefresh: refreshCallback,
            );
          } else {
            return _scrollableWrapper(widget.child)!;
          }
        }),
      ),
      floatingActionButton: widget.floatingActionButton,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarBrightness: widget.brightness ?? Brightness.light),
      child: Stack(
        children: <Widget>[
          scaffold,
          OpacityAppBar(
            height: widget.titleHeight,
            firstColor: widget.firstColor,
            secondColor: widget.secondColor,
            shrinkOffset: offset,
            onlyShadowOpacity: widget.onlyShadowOpacity,
            useShadow: widget.useShadow,
            titleBuilder: widget.titleBuilder,
            opacityBorder: widget.opacityBorder,
            rightIconBuilder: widget.rightIconBuilder,
            leftIconBuilder: widget.leftIconBuilder,
          )
        ],
      ),
    );
  }

  Widget? _scrollableWrapper(Widget child) {
    if (child is Scrollable && widget.childScrollController != null || widget.hasScrollBody) {
      return child;
    } else {
      return ListView(
        controller: widget.childScrollController ?? scrollController,
        children: [
          child,
        ],
      );
    }
  }
}

class OpacityAppBar extends StatefulWidget {
  static const double DEFAULT_OPACITY_BORDER = 0.80;

  final double opacityBorder;
  final double height;
  final Widget Function(Color?) titleBuilder;
  final bool useShadow;
  final double shrinkOffset;
  final Color firstColor;
  final Color secondColor;
  final bool onlyShadowOpacity;

  final Widget Function(Color?)? leftIconBuilder;
  final Widget Function(Color?)? rightIconBuilder;

  const OpacityAppBar({
    required this.titleBuilder,
    required this.shrinkOffset,
    Key? key,
    this.height = 60.0,
    this.opacityBorder = DEFAULT_OPACITY_BORDER,
    this.useShadow = true,
    this.onlyShadowOpacity = false,
    this.firstColor = Colors.white,
    this.secondColor = Colors.black,
    this.rightIconBuilder,
    this.leftIconBuilder,
  })  : assert(opacityBorder <= 1.0 && opacityBorder >= 0.0),
        super(key: key);

  @override
  _OpacityAppBarState createState() => _OpacityAppBarState();
}

class _OpacityAppBarState extends State<OpacityAppBar> {
  Widget Function(Color?) get leftIconBuilder =>
      widget.leftIconBuilder ?? (color) => const SizedBox();

  @override
  Widget build(BuildContext context) {
    final shrinkOffset = widget.shrinkOffset;

    final koef = 1.0 - max(0.0, min(widget.height, shrinkOffset)) / widget.height;

    var k = koef;
    if (koef >= widget.opacityBorder) {
      k = koef - widget.opacityBorder;
      k = k / (1 - widget.opacityBorder);
    } else {
      k = 0.0;
    }

    final mainColor =
        Color.lerp(widget.firstColor, widget.secondColor, Curves.easeInCubic.transform(1 - k));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(widget.onlyShadowOpacity ? 1 : 1 - k),
        boxShadow: !widget.useShadow
            ? null
            : [
                BoxShadow(
                  offset: const Offset(0.0, -4),
                  blurRadius: 8.0,
                  spreadRadius: 0.0,
                  color: Color.lerp(
                    Colors.black.withOpacity(lerpDouble(1.0, 0.3, koef)!),
                    Colors.transparent,
                    koef,
                  )!,
                )
              ],
      ),
      height: widget.height + MediaQuery.of(context).padding.top,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Material(
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Row(
                children: <Widget>[
                  leftIconBuilder(mainColor),
                  Expanded(child: widget.titleBuilder(mainColor)),
                  widget.rightIconBuilder == null
                      ? IgnorePointer(
                          child: Opacity(
                            opacity: 0.0,
                            child: leftIconBuilder(mainColor),
                          ),
                        )
                      : widget.rightIconBuilder!(mainColor)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NoGlowBehaviour extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
