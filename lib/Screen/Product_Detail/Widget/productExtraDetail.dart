import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../../Model/Section_Model.dart';

Widget extraDesc(Product model, BuildContext context) {
  return model.extraDesc != '' &&
          model.extraDesc != null &&
          model.extraDesc.toString().toLowerCase() != '<p>null</p>'
      ? SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Card(
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: HtmlWidget(
                  model.extraDesc!,
                  textStyle:
                      TextStyle(color: Theme.of(context).colorScheme.fontColor),
                )),
          ),
        )
      : const SizedBox();
}
