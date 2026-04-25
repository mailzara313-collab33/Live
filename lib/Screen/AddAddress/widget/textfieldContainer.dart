import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget buildTextFormField({
  required BuildContext context,
  required String labelText,
  required String hintText,
  TextEditingController? controller,
  FocusNode? focusNode,
  FocusNode? nextFocusNode,
  TextInputType inputType = TextInputType.text,
  TextInputAction inputAction = TextInputAction.next,
  String? Function(String?)? validator,
  void Function(String?)? onSaved,
  void Function(String)? onChanged,
  List<TextInputFormatter>? inputFormatters,
  int? maxLength,
  bool isNumber = false,
  bool readOnly = false,
  bool useCustomContainer = false,
  TextCapitalization capitalization = TextCapitalization.none,
  Widget? suffixIcon,
}) {
  final textFormField = TextFormField(
    keyboardType: inputType,
    controller: controller,
    focusNode: focusNode,
    textInputAction: inputAction,
    readOnly: readOnly,
    onChanged: onChanged,
    onFieldSubmitted: (value) {
      if (nextFocusNode != null) {
        _fieldFocusChange(context, focusNode!, nextFocusNode);
      }
    },
    validator: validator,
    onSaved: onSaved,
    inputFormatters: inputFormatters,
    maxLength: maxLength,
    textCapitalization: capitalization,
    style: Theme.of(context)
        .textTheme
        .titleSmall!
        .copyWith(color: Theme.of(context).colorScheme.fontColor),
    decoration: InputDecoration(
      counter: const SizedBox.shrink(),
      hintText: hintText.translate(context: context),
      filled: true,
      fillColor: Theme.of(context).colorScheme.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(circularBorderRadius5),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(circularBorderRadius5),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(circularBorderRadius5),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(circularBorderRadius5),
        borderSide: const BorderSide(color: Colors.red),
      ),
      suffixIcon: suffixIcon,
    ),
  );

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText.translate(context: context),
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontFamily: 'ubuntu',
              ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: useCustomContainer
              ? Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.white,
                    borderRadius: BorderRadius.circular(circularBorderRadius5),
                  ),
                  child: textFormField,
                )
              : textFormField,
        ),
      ],
    ),
  );
}

void _fieldFocusChange(
    BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
  currentFocus.unfocus(); // Unfocus the current field
  FocusScope.of(context).requestFocus(nextFocus); // Move focus to the next
}
