import 'package:flutter/material.dart';
import '../../shared/theme/app_insets.dart';

class ThemedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const ThemedCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppInsets.borderRadiusMd,
        child: Padding(
          padding: padding ?? AppInsets.cardPadding,
          child: child,
        ),
      ),
    );
  }
}
