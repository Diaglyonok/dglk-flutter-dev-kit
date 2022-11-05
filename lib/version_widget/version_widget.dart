import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionWidget extends StatefulWidget {
  final String? versionTitleText;
  final TextStyle? textStyle;

  const VersionWidget({Key? key, this.versionTitleText, this.textStyle}) : super(key: key);

  @override
  State<VersionWidget> createState() => _VersionWidgetState();
}

class _VersionWidgetState extends State<VersionWidget> {
  PackageInfo? packageInfo;

  @override
  void initState() {
    PackageInfo.fromPlatform().then(
      (value) {
        packageInfo = value;
        setState(() {});
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        packageInfo == null
            ? ''
            : '${widget.versionTitleText ?? 'Version'}: ${packageInfo!.version}(${packageInfo!.buildNumber})',
        style: widget.textStyle ??
            Theme.of(context).textTheme.bodyText2?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
      ),
    );
  }
}
