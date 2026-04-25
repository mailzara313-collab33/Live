import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/routes.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Provider/productDetailProvider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CompareProduct extends StatelessWidget {
  final Product? model;

  const CompareProduct({super.key, this.model});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: () {
          if (context.read<ProductDetailProvider>().compareList.length > 0 &&
              context
                  .read<ProductDetailProvider>()
                  .compareList
                  .contains(model)) {
            Routes.navigateToCompareListScreen(context);
          } else {
            context.read<ProductDetailProvider>().addCompareList(model!);
            Routes.navigateToCompareListScreen(context);
          }
        },
        child: ListTile(
          dense: true,
          title: Text(
            'COMPARE_PRO'.translate(context: context),
            style: TextStyle(
              color: Theme.of(context).colorScheme.fontColor,
            ),
          ),
          trailing: Icon(
            Icons.navigate_next,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
