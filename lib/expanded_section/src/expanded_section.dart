import 'package:flutter/material.dart';

class ExpandedSection extends StatefulWidget {
  final Widget child;
  final bool expand;
  final Duration? duration;
  final bool expandOnStart;
  final Function? afterInit;

  const ExpandedSection({
    required this.child,
    Key? key,
    this.expand = false,
    this.duration,
    this.afterInit,
    this.expandOnStart = true,
  }) : super(key: key);

  @override
  _ExpandedSectionState createState() => _ExpandedSectionState();
}

class _ExpandedSectionState extends State<ExpandedSection> with SingleTickerProviderStateMixin {
  AnimationController? expandController;
  Animation<double>? animation;

  @override
  void initState() {
    super.initState();
    prepareAnimations();
    _runExpandCheck();
    if (widget.afterInit != null) {
      widget.afterInit!();
    }
  }

  ///Setting up the animation
  void prepareAnimations() {
    expandController = AnimationController(
        vsync: this, duration: widget.duration ?? const Duration(milliseconds: 500));
    if (!widget.expandOnStart) {
      expandController!.value = widget.expand ? 1.0 : 0.0;
    }
    animation = CurvedAnimation(
      parent: expandController!,
      curve: Curves.fastOutSlowIn,
    )..addListener(() {
        setState(() {});
      });
  }

  void _runExpandCheck() {
    if (widget.expand && animation!.value != 1.0) {
      expandController!.forward();
    }
    if (!widget.expand && animation!.value != 0.0) {
      expandController!.reverse();
    }
  }

  @override
  void didUpdateWidget(ExpandedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _runExpandCheck();
  }

  @override
  void dispose() {
    expandController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      axisAlignment: -1.0,
      sizeFactor: animation!,
      child: Stack(
        children: <Widget>[
          widget.child,
        ],
      ),
    );
  }
}
