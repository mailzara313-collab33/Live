import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Constant.dart';
import '../../../Provider/customerSupportProvider.dart';

import '../../../widgets/validation.dart';

class SetEmailWidget extends StatefulWidget {
  const SetEmailWidget({super.key});

  @override
  State<SetEmailWidget> createState() => _SetEmailWidgetState();
}

class _SetEmailWidgetState extends State<SetEmailWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 10.0,
      ),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        focusNode: context.read<CustomerSupportProvider>().emailFocus,
        textInputAction: TextInputAction.next,
        controller: context.read<CustomerSupportProvider>().emailController,
        style: TextStyle(
          color: Theme.of(context).colorScheme.fontColor,
          fontWeight: FontWeight.normal,
        ),
        validator: (val) => StringValidation.validateEmail(
          val!,
          'EMAIL_REQUIRED'.translate(context: context),
          'VALID_EMAIL'.translate(context: context),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp('[ ]')),
        ],
        onSaved: (String? value) {
          context.read<CustomerSupportProvider>().email = value;
        },
        onFieldSubmitted: (v) {
          context.read<CustomerSupportProvider>().emailFocus!.unfocus();
          FocusScope.of(context)
              .requestFocus(context.read<CustomerSupportProvider>().nameFocus);
        },
        decoration: InputDecoration(
          hintText: 'EMAILHINT_LBL'.translate(context: context),
          hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.normal,
              ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.lightWhite,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
      ),
    );
  }
}
