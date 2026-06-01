import 'package:flutter/material.dart';

class EditableTextWidget extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Function(String) onChanged;
  final TextAlign? align;
  final int maxLines;
  final bool singleLine;

  const EditableTextWidget({
    super.key,
    required this.text,
    required this.onChanged,
    this.style,
    this.align,
    this.maxLines = 20,
    this.singleLine = false,
  });

  @override
  State<EditableTextWidget> createState() => _EditableTextWidgetState();
}

class _EditableTextWidgetState extends State<EditableTextWidget> {
  bool isEditing = false;
  late TextEditingController controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.text);
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && isEditing) {
      _commitEdit();
    }
  }

  void _commitEdit() {
    widget.onChanged(controller.text.trim());
    setState(() => isEditing = false);
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
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isEditing) {
      return GestureDetector(
        onTap: () => setState(() {
          isEditing = true;
          controller.text = widget.text;
        }),
        child: Text(widget.text, style: widget.style, textAlign: widget.align),
      );
    }

    return TextField(
      controller: controller,
      focusNode: _focusNode,
      autofocus: true,
      maxLines: widget.singleLine ? 1 : widget.maxLines,
      minLines: widget.singleLine ? 1 : null,
      style: widget.style,
      textAlign: widget.align ?? TextAlign.start,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          vertical: widget.singleLine ? 6 : 8,
          horizontal: 0,
        ),
        border: InputBorder.none,
      ),
      onSubmitted: (_) => _commitEdit(),
    );
  }
}
