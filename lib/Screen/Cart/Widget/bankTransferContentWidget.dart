import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/widgets/desing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Provider/paymentProvider.dart';

class GetBankTransferContent extends StatelessWidget {
  const GetBankTransferContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
            child: Text(
              'BANKTRAN'.translate(context: context),
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontFamily: 'ubuntu',
              ),
            ),
          ),
          Divider(color: Theme.of(context).colorScheme.lightBlack),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
            child: Text(
              'BANK_INS'.translate(context: context),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Text(
              'ACC_DETAIL'.translate(context: context),
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontFamily: 'ubuntu',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: RichText(
              text: TextSpan(
                // Note: Styles for TextSpans must be explicitly defined.
                // Child text spans will inherit styles from parent
                style: Theme.of(
                  context,
                ).textTheme.titleSmall!.copyWith(fontFamily: 'ubuntu'),
                children: <TextSpan>[
                  TextSpan(
                    text: '${'ACCNAME'.translate(context: context)} : ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: context.read<PaymentProvider>().acName!),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: RichText(
              text: TextSpan(
                // Note: Styles for TextSpans must be explicitly defined.
                // Child text spans will inherit styles from parent
                style: Theme.of(
                  context,
                ).textTheme.titleSmall!.copyWith(fontFamily: 'ubuntu'),
                children: <TextSpan>[
                  TextSpan(
                    text: '${'ACCNO'.translate(context: context)} : ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: context.read<PaymentProvider>().acNo!),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: RichText(
              text: TextSpan(
                // Note: Styles for TextSpans must be explicitly defined.
                // Child text spans will inherit styles from parent
                style: Theme.of(
                  context,
                ).textTheme.titleSmall!.copyWith(fontFamily: 'ubuntu'),
                children: <TextSpan>[
                  TextSpan(
                    text: '${'BANKNAME'.translate(context: context)} : ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: context.read<PaymentProvider>().bankName!),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: RichText(
              text: TextSpan(
                // Note: Styles for TextSpans must be explicitly defined.
                // Child text spans will inherit styles from parent
                style: Theme.of(
                  context,
                ).textTheme.titleSmall!.copyWith(fontFamily: 'ubuntu'),
                children: <TextSpan>[
                  TextSpan(
                    text: '${'BANKCODE'.translate(context: context)} : ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: context.read<PaymentProvider>().bankNo!),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              '${'EXTRADETAIL'.translate(context: context)} : ',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                fontFamily: 'ubuntu',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: HtmlWidget(
              _cleanHtmlContent(context.read<PaymentProvider>().exDetails!),
              onTapUrl: (String? url) async {
                url = url.toString().replaceAll('\\', '');
                url = url.replaceAll('"', '');
                if (await canLaunchUrl(Uri.parse(url))) {
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
                    true,
                    Theme.of(context).primaryColor,
                  ),

              renderMode: RenderMode.column,

              // set the default styling for text
              textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Clean HTML content by removing escaped newline characters
  static String _cleanHtmlContent(String htmlContent) {
    return htmlContent
        .replaceAll('\\r\\n', '')
        .replaceAll('\\n', '')
        .replaceAll('\\r', '')
        .replaceAll(r'\r\n', '')
        .replaceAll(r'\n', '')
        .replaceAll(r'\r', '');
  }
}
