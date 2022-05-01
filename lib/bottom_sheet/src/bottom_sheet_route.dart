import 'package:flutter/material.dart';

class BottomSheetRoute extends ModalRoute {
  BottomSheetRoute({
    this.child,
    this.bottomSheetController,
    this.color,
    this.showGrip,
  });
  bool isPopped = false;

  final Widget? child;
  final BottomSheetController? bottomSheetController;
  final Color? color;
  final bool? showGrip;

  @override
  Future<RoutePopDisposition> willPop() {
    if (isPopped) {
      return Future.value(RoutePopDisposition.doNotPop);
    }
    isPopped = true;
    return super.willPop();
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Color get barrierColor => Colors.black.withOpacity(0.4);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

  @override
  bool get semanticsDismissible => true;

  @override
  Widget buildPage(
      BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    if (bottomSheetController != null) {
      bottomSheetController!.registerListener(() {
        if (!isPopped) {
          isPopped = true;
          Navigator.of(context).pop();
        }
      });
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Dismissible(
          key: const Key("dismissible"),
          direction: DismissDirection.down,
          onDismissed: (direction) {
            if (!isPopped) {
              isPopped = true;
              Navigator.of(context).pop();
            }
          },
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: Column(
              children: <Widget>[
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                  child: Container(
                    color: color ?? Theme.of(context).colorScheme.background,
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.9,
                        minWidth: MediaQuery.of(context).size.width),
                    child: _childWrapper(context),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position:
          Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(animation),
      child: child,
    );
  }

  Widget _childWrapper(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      GestureDetector(
          child: Container(
            height: 36,
            child: Align(
              child: Visibility(
                visible: showGrip ?? true,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: Container(
                    width: 40,
                    height: 4,
                    color: Theme.of(context).colorScheme.background,
                  ),
                ),
              ),
              alignment: Alignment.center,
            ),
            padding: const EdgeInsets.only(bottom: 12),
            color: Colors.transparent,
          ),
          onTap: () {
            if (!isPopped) {
              isPopped = true;
              Navigator.of(context).pop();
            }
          }),
      Flexible(child: child!),
    ]);
  }
}

class BottomSheetController {
  Function? popCallback;

  void registerListener(Function popCallback) {
    this.popCallback = popCallback;
  }

  void pop() {
    if (popCallback != null) {
      popCallback!();
    }
  }

  dispose() {
    popCallback = null;
  }
}
