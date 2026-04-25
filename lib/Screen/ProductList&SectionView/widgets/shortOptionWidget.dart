import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:flutter/material.dart';

class SortOptionTile extends StatelessWidget {
  final int value;
  final int groupValue;
  final String title;
  final String sortBy;
  final String orderBy;
  final String result;
  final String apiParam;
  final Function(int, String, String, String, String) onSelected;

  const SortOptionTile({
    super.key,
    required this.value,
    required this.groupValue,
    required this.title,
    required this.sortBy,
    required this.orderBy,
    required this.result,
    required this.apiParam,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return RadioGroup<int>(
      groupValue: groupValue, // the currently selected value
      onChanged: (newValue) {
        onSelected(newValue!, sortBy, orderBy, result, apiParam);
      },
      child: RadioListTile<int>(
        title: Text(
          title,
          style: TextStyle(
            color: value == groupValue
                ? Theme.of(context).colorScheme.fontColor
                : Theme.of(context)
                    .colorScheme
                    .fontColor
                    .withValues(alpha: 0.6),
            fontSize: textFontSize16,
            fontFamily: 'ubuntu',
          ),
        ),
        value: value,
        activeColor: Theme.of(context).colorScheme.primary,
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }
}
