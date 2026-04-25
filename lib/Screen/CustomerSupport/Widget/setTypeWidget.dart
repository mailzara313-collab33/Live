import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../../Model/Model.dart';
import '../../../Provider/customerSupportProvider.dart';

// ignore: must_be_immutable
class SetTypeWidget extends StatefulWidget {
  const SetTypeWidget({
    super.key,
  });

  @override
  State<SetTypeWidget> createState() => _SetTypeWidgetState();
}

class _SetTypeWidgetState extends State<SetTypeWidget> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      iconEnabledColor: Theme.of(context).colorScheme.fontColor,
      isDense: true,
      hint: SizedBox(
        width: deviceWidth! * 0.6,
        child: Text(
          'SELECT_TYPE'.translate(context: context),
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.normal,
                fontFamily: 'ubuntu',
              ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          softWrap: true,
        ),
      ),
      decoration: InputDecoration(
        filled: true,
        isDense: true,
        fillColor: Theme.of(context).colorScheme.lightWhite,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.fontColor),
          borderRadius: BorderRadius.circular(circularBorderRadius10),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.lightWhite),
          borderRadius: BorderRadius.circular(circularBorderRadius10),
        ),
      ),
      initialValue: context.read<CustomerSupportProvider>().type,
      style: Theme.of(context)
          .textTheme
          .titleSmall!
          .copyWith(color: Theme.of(context).colorScheme.fontColor),
      onChanged: (String? newValue) {
        if (mounted) {
          setState(
            () {
              context.read<CustomerSupportProvider>().type = newValue;
            },
          );
        }
      },
      items: context.read<CustomerSupportProvider>().typeList.map(
        (Model user) {
          return DropdownMenuItem<String>(
            value: user.id,
            child: Text(
              user.title!,
              style: const TextStyle(
                fontFamily: 'ubuntu',
              ),
            ),
          );
        },
      ).toList(),
    );
  }
}
