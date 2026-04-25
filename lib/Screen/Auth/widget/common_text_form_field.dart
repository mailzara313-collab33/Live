import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CommonTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final String hintText;
  final IconData icon;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final FormFieldValidator<String>? validator;
  final Function(String?)? onSaved;
  final List<TextInputFormatter>? inputFormatters;
  final double fontSize;
  final double topPadding;
  final Color fontColor;
  final Color fillColor;
  final double borderRadius;
  final bool obscureText;
  final Widget? suffixIcon;
  final void Function(String)? onFieldSubmitted;
  final int? maxLength;
  final Widget? counter;
  final Color? prefixIconColor;
  final bool readOnly;

  const CommonTextFormField({
    super.key,
    required this.controller,
    this.focusNode,
    this.nextFocus,
    required this.hintText,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.done,
    this.validator,
    this.onSaved,
    this.inputFormatters,
    required this.fontSize,
    this.topPadding = 20,
    required this.fontColor,
    required this.fillColor,
    this.borderRadius = 10,
    this.obscureText = false,
    this.suffixIcon,
    this.onFieldSubmitted,
    this.maxLength,
    this.counter,
    this.prefixIconColor,
    this.readOnly = false,
  });

  @override
  State<CommonTextFormField> createState() => _CommonTextFormFieldState();
}

class _CommonTextFormFieldState extends State<CommonTextFormField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: widget.topPadding),
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        keyboardType: widget.keyboardType,
        textCapitalization: widget.textCapitalization,
        textInputAction: widget.textInputAction,
        obscureText: widget.obscureText,
        readOnly: widget.readOnly,
        inputFormatters: widget.inputFormatters,
        maxLength: widget.maxLength,
        style: TextStyle(
          color: widget.fontColor.withValues(alpha: 0.7),
          fontWeight: FontWeight.bold,
          fontSize: widget.fontSize,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(widget.icon,
              color: widget.prefixIconColor ?? widget.fontColor),
          suffixIcon: widget.suffixIcon,
          counter: widget.counter,
          errorMaxLines: 4,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: widget.fontColor.withValues(alpha: 0.3),
            fontWeight: FontWeight.bold,
            fontSize: widget.fontSize,
          ),
          fillColor: widget.fillColor,
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        ),
        validator: widget.validator,
        onSaved: widget.onSaved,
        onFieldSubmitted: (val) {
          widget.onFieldSubmitted?.call(val);
          if (widget.nextFocus != null) {
            FocusScope.of(context).requestFocus(widget.nextFocus);
          } else if (widget.focusNode != null) {
            FocusScope.of(context).requestFocus(widget.focusNode);
          }
        },
      ),
    );
  }
}
