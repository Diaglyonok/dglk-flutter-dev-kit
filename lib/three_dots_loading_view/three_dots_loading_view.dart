import 'package:flutter/material.dart';

class ThreeDotsLoadingView extends StatefulWidget {
  final String? syncText;
  final TextStyle? style;

  const ThreeDotsLoadingView({Key? key, this.syncText, this.style}) : super(key: key);

  @override
  State<ThreeDotsLoadingView> createState() => _ThreeDotsLoadingViewState();
}

class _ThreeDotsLoadingViewState extends State<ThreeDotsLoadingView> with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<int> animation;
  @override
  void initState() {
    controller = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    controller.repeat(reverse: false);
    animation = IntTween(begin: 0, end: 3).animate(controller);

    super.initState();
  }

  String get syncText => widget.syncText ?? 'Syncing';

  String get fullText => '$syncText...';

  String dots(int value) {
    String result = '';
    final dotsVal = (value % 3) + 1;

    for (int i = 0; i < dotsVal; i++) {
      result += '.';
    }

    return result;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          return Stack(
            children: [
              Text(
                fullText,
                style: (widget.style ?? Theme.of(context).textTheme.labelLarge)!.copyWith(
                  color: Colors.transparent,
                ),
              ),
              Text(
                '$syncText${dots(animation.value.toInt())}',
                style: widget.style ??
                    Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: Theme.of(context).colorScheme.onSecondary),
              ),
            ],
          );
        });
  }
}
