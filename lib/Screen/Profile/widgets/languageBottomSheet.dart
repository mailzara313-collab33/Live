import 'dart:io';

import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Model/appLanguageModel.dart';
import 'package:eshop_multivendor/cubits/languageCubit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../widgets/bottomSheet.dart';

class LanguageBottomSheet extends StatefulWidget {
  const LanguageBottomSheet({super.key});

  @override
  State<LanguageBottomSheet> createState() => _LanguageBottomSheetState();
}

class _LanguageBottomSheetState extends State<LanguageBottomSheet> {
  String? selectedLanguageCode;

  @override
  void initState() {
    super.initState();
    final languageState = context.read<LanguageCubit>().state;
    if (languageState is LanguageLoader) {
      selectedLanguageCode = languageState.languageCode;
    }
  }

  Column getLanguageTile({required AppLanguage appLanguage}) => Column(
        children: [
          InkWell(
            onTap: () {
              context.read<LanguageCubit>().changeLanguage(
                    selectedLanguageCode: appLanguage.languageCode,
                    selectedLanguageName: appLanguage.languageName,
                    selectedSubLanguageName: appLanguage.subLanguageName,
                  );
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  RadioGroup<String>(
                    groupValue: selectedLanguageCode,
                    onChanged: (String? val) {
                      if (val == null) return;
                      setState(() {
                        selectedLanguageCode = val;
                      });
                      context.read<LanguageCubit>().changeLanguage(
                            selectedLanguageCode: appLanguage.languageCode,
                            selectedLanguageName: appLanguage.languageName,
                            selectedSubLanguageName:
                                appLanguage.subLanguageName,
                          );
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: [
                        Radio<String>(
                          value: appLanguage.languageCode,
                          fillColor: const WidgetStatePropertyAll(Colors.red),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appLanguage.languageName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              appLanguage.subLanguageName,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Platform.isIOS
          ? EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20)
          : EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomBottomSheet.bottomSheetHandle(context),
          CustomBottomSheet.bottomSheetLabel(context, 'CHOOSE_LANGUAGE_LBL'),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(), // disables bounce
                  itemCount: appLanguages.length,
                  itemBuilder: (context, index) {
                    return getLanguageTile(appLanguage: appLanguages[index]);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
