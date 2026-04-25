import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/routes.dart';
import '../../../Model/Section_Model.dart';
import '../../../Provider/sellerDetailProvider.dart';

class SellerDetail extends StatelessWidget {
  final Product? model;
  const SellerDetail({super.key, this.model});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: () async {
          context
              .read<SellerDetailProvider>()
              .changeStatus(SellerDetailProviderStatus.isSuccsess);
          Routes.navigateToSellerProfileScreen(
              context,
              model!.seller_id!,
              model!.seller_profile!,
              model!.seller_name!,
              model!.seller_rating!,
              model!.store_name!,
              model!.store_description!,
              model!.totalProductsOfSeller,
              model!.noOfRatingsOnSeller);
        },
        child: ListTile(
          dense: true,
          title: Row(
            children: [
              Text(
                'SELLER_DETAILS'.translate(context: context),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.black,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Ubuntu',
                  fontStyle: FontStyle.normal,
                  fontSize: textFontSize16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(
                model!.store_name ?? '',
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: const TextStyle(
                  color: Color(0xfffc6a57),
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Ubuntu',
                  fontStyle: FontStyle.normal,
                  fontSize: textFontSize16,
                ),
              )),
            ],
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
