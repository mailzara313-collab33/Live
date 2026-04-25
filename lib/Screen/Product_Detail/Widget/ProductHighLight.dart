import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/String.dart';

import 'package:eshop_multivendor/widgets/desing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Helper/Constant.dart';
import '../../../Model/Section_Model.dart';

class ProductHighLightsDetail extends StatelessWidget {
  final Product? model;
  final Function update;
  const ProductHighLightsDetail({
    super.key,
    this.model,
    required this.update,
  });

  Widget _desc(Product? model) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: HtmlWidget(
          model!.shortDescription!,
          onTapUrl: (String? url) async {
            if (await canLaunchUrl(Uri.parse(url!))) {
              await launchUrl(Uri.parse(url));
              return true;
            } else {
              throw 'Could not launch $url';
            }
          },
          onErrorBuilder: (context, element, error) =>
              Text('$element error: $error'),
          onLoadingBuilder: (context, element, loadingProgress) =>
              DesignConfiguration.showCircularProgress(
                  true, Theme.of(context).primaryColor),
          renderMode: RenderMode.column,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return (model!.shortDescription != '' && model!.shortDescription != null)
        ? Container(
            color: Theme.of(context).colorScheme.white,
            padding: const EdgeInsets.only(top: 10.0),
            child: InkWell(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 15.0,
                      end: 15.0,
                      bottom: 10,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Product Highlights'.translate(context: context),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Ubuntu',
                              fontStyle: FontStyle.normal,
                              fontSize: textFontSize16,
                              color: Theme.of(context).colorScheme.fontColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                    child: _desc(model),
                  ),
                ],
              ),
            ),
          )
        : const SizedBox();
  }
}
