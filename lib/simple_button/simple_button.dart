import 'package:flutter/material.dart';

class SimpleButton extends StatelessWidget {
  final String title;
  final Function? callback;
  final Widget? child;
  final double borderRadius;
  final Color? backgroundColor;

  final TextStyle? textStyle;
  final bool withShadow;

  const SimpleButton({
    Key? key,
    this.callback,
    required this.title,
    this.child,
    this.borderRadius = 12.0,
    this.backgroundColor,
    this.textStyle,
    this.withShadow = true,
  }) : super(key: key);

  Color getColor(BuildContext context) =>
      backgroundColor ?? Theme.of(context).colorScheme.secondary;

  @override
  Widget build(BuildContext context) {
    bool isDisabled = callback == null;

    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 256),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isDisabled
                ? Color.alphaBlend(Colors.white.withOpacity(0.5), getColor(context))
                : getColor(context),
            boxShadow: !withShadow
                ? null
                : [
                    BoxShadow(
                        offset: const Offset(0.0, 2.0),
                        blurRadius: 8.0,
                        spreadRadius: 0.0,
                        color: Colors.black26.withOpacity(0.3))
                  ],
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(borderRadius),
            onTap: () => callback?.call(),
            child: Center(
              child: child ??
                  Text(
                    title,
                    semanticsLabel: title,
                    style: textStyle ??
                        Theme.of(context).textTheme.labelLarge!.copyWith(
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
