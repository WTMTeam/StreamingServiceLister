import 'package:flutter/material.dart';

class LongText extends StatefulWidget {
  final String longText;
  const LongText({super.key, required this.longText});

  @override
  State<LongText> createState() => _LongTextState();
}

class _LongTextState extends State<LongText> {
  bool isExpanded = false;
  bool willExpand = true;

  @override
  Widget build(BuildContext context) {
    if (widget.longText == "") {
      willExpand = false;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.longText,
          maxLines: isExpanded ? null : 3, // Show full text if expanded
          overflow: TextOverflow.fade, // Handle overflow
        ),
        const SizedBox(height: 5), // Space between text and button
        willExpand
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded; // Toggle expansion
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        isExpanded ? "See less" : "See more",
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
