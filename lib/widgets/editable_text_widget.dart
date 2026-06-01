import 'package:flutter/material.dart';

class EditableTextWidget extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Function(String) onChanged;
  final TextAlign? align;
  final int maxLines;

  const EditableTextWidget({
    super.key,
    required this.text,
    required this.onChanged,
    this.style,
    this.align,
    this.maxLines = 20,
  });

  @override
  State<EditableTextWidget> createState() => _EditableTextWidgetState();
}

class _EditableTextWidgetState extends State<EditableTextWidget> {
  bool isEditing = false;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.text);
  }

  @override
  void didUpdateWidget(EditableTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text && !isEditing) {
      controller.text = widget.text;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isEditing) {
      return GestureDetector(
        onTap: () => setState(() => isEditing = true),
        child: Text(widget.text, style: widget.style, textAlign: widget.align),
      );
    }

    return TextField(
      controller: controller,
      autofocus: true,
      maxLines: widget.maxLines,
      style: widget.style,
      textAlign: widget.align ?? TextAlign.start,
      onSubmitted: (val) {
        widget.onChanged(val);
        setState(() => isEditing = false);
      },
      onEditingComplete: () {
        widget.onChanged(controller.text);
        setState(() => isEditing = false);
      },
    );
  }
}
