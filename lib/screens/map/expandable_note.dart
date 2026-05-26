import 'package:flutter/cupertino.dart';

class ExpandableNote extends StatefulWidget {
  final String text;
  final String title;
  final String showMoreText;
  final String showLessText;

  const ExpandableNote({
    super.key,
    required this.text,
    required this.title,
    required this.showMoreText,
    required this.showLessText,
  });

  @override
  State<ExpandableNote> createState() => ExpandableNoteState();
}

class ExpandableNoteState extends State<ExpandableNote> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: const TextStyle(fontSize: 16)),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() {
              expanded = !expanded;
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (expanded)
                Text(
                  widget.text,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  expanded ? widget.showLessText : widget.showMoreText,
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.activeBlue.resolveFrom(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
