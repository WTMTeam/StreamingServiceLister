import 'package:flutter/material.dart';

class DescriptionCard extends StatelessWidget {
  final String description;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;

  const DescriptionCard({
    super.key,
    required this.description,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        description,
        style: textStyle ?? Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
