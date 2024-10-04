import 'package:flutter/material.dart';

class ErrorWidget extends StatefulWidget {
  final Function(String) onChanged;
  const ErrorWidget({super.key, required this.onChanged});

  @override
  State<ErrorWidget> createState() => _ErrorWidgetState();
}

class _ErrorWidgetState extends State<ErrorWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
