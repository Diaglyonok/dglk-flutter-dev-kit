import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

export 'package:package_info_plus/package_info_plus.dart';

class AppVersion {
  static Future<PackageInfo> getPackageInfo() {
    return PackageInfo.fromPlatform();
  }
}

class VersionWidget extends StatefulWidget {
  final String? versionTitleText;
  final TextStyle? textStyle;

  final TextAlign? textAlign;

  const VersionWidget({Key? key, this.versionTitleText, this.textStyle, this.textAlign}) : super(key: key);

  @override
  State<VersionWidget> createState() => _VersionWidgetState();
}

class _VersionWidgetState extends State<VersionWidget> {
  PackageInfo? packageInfo;

  @override
  void initState() {
    AppVersion.getPackageInfo().then(
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
            : '${widget.versionTitleText ?? 'Version'}: ${packageInfo!.version} (${packageInfo!.buildNumber})',
        textAlign: widget.textAlign,
        style: widget.textStyle ??
            Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
      ),
    );
  }
}
