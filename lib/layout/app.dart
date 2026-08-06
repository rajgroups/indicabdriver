import 'package:flutter/material.dart';
import 'package:indicab_driver/constants/Colors.dart';

class AppScreen extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final PreferredSizeWidget? appBar;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;
  final bool safeAreaBottom;
  final ScrollPhysics? physics;
  final bool resizeToAvoidBottomInset;

  const AppScreen({
    super.key,
    required this.child,
    this.backgroundColor = AppColors.white,
    this.appBar,
    this.padding,
    this.scrollable = false,
    this.safeAreaBottom = true,
    this.physics,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    if (scrollable) {
      content = SingleChildScrollView(
        physics: physics ?? const BouncingScrollPhysics(),
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: SafeArea(bottom: safeAreaBottom, child: content),
    );
  }
}
