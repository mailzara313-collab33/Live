import 'dart:io';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/widgets/snackbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Color.dart';
import '../../../Helper/String.dart';
import '../../../Model/Section_Model.dart';
import '../../../Provider/CartProvider.dart';

// ignore: must_be_immutableclass AttachPrescriptionImages extends StatelessWidget {
class AttachPrescriptionImages extends StatelessWidget {
  final List<SectionModel> cartList;
  const AttachPrescriptionImages({super.key, required this.cartList});

  void _imgFromGallery(BuildContext context, Product product) async {
    // bool storagePermissionGiven = await hasStoragePermissionGiven();
    // if (storagePermissionGiven) {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      if (result.count > 5) {
        setSnackbar('Cannot select more than 5 files', context);
        return;
      }

      double fileSizes = 0.0;
      for (var element in result.files) {
        fileSizes += element.size;
      }

      if ((fileSizes / 1000000) > allowableTotalFileSizesInChatMediaInMB) {
        setSnackbar(
          'Total allowable attachment size is $allowableTotalFileSizesInChatMediaInMB MB',
          context,
        );
        return;
      }

      // Get correct variant ID
      final variantId = product.prVarientList?[product.selVarient ?? 0].id;

      if (variantId != null) {
        context.read<CartProvider>().checkoutState!(() {
          context.read<CartProvider>().setPrescriptionImages(
                variantId,
                result.paths.map((path) => File(path!)).toList(),
              );
        });
      } else {
        setSnackbar('Something went wrong while selecting variant.', context);
      }
    }
    // } else {
    //   setSnackbar('Please give storage permission', context);
    // }
  }

  @override
  Widget build(BuildContext context) {
    for (var section in cartList) {
      final sectionVariantId = section.varientId;

      if (section.productList != null) {
        for (var product in section.productList!) {
          if (product.prVarientList != null &&
              product.prVarientList!.isNotEmpty &&
              sectionVariantId != null) {
            int variantIndex = product.prVarientList!.indexWhere(
              (v) => v.id.toString() == sectionVariantId,
            );
            product.selVarient = variantIndex != -1 ? variantIndex : 0;
          } else {
            product.selVarient = 0;
          }
        }
      }
    }

    // Then proceed with your attachRequiredProducts filtering and UI rendering
    final List<Product> attachRequiredProducts = [
      for (var section in cartList)
        for (var product in section.productList!)
          if (product.is_attch_req == '1') product
    ];

    if (attachRequiredProducts.isEmpty) {
      return const SizedBox();
    }
    return Column(
      children: attachRequiredProducts.map((product) {
        final variantIndex = product.selVarient ?? 0;
        final variantId = (product.prVarientList != null &&
                product.prVarientList!.length > variantIndex)
            ? product.prVarientList![variantIndex].id
            : null;

        print("varientsId for product '${product.name}': $variantId");

        final images = (variantId != null && variantId.toString().isNotEmpty)
            ? context.watch<CartProvider>().getPrescriptionImages(variantId)
            : [];

        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Product title + add icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${'ADD_ATT_REQ'.translate(context: context)}: ${product.name} : ${product.prVarientList![variantIndex].varient_value}',
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              color: Theme.of(context).colorScheme.lightBlack,
                              fontFamily: 'ubuntu',
                            ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 4,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_photo_alternate,
                        color: colors.primary,
                        size: 20.0,
                      ),
                      onPressed: () => _imgFromGallery(context, product),
                    ),
                  ],
                ),

                // Images preview
                if (images.isNotEmpty)
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      itemBuilder: (context, i) {
                        return Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              child: Image.file(
                                images[i],
                                width: 180,
                                height: 180,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: GestureDetector(
                                onTap: () {
                                  if (variantId != null) {
                                    context
                                        .read<CartProvider>()
                                        .removePrescriptionImageForProduct(
                                            variantId, i);
                                  }
                                },
                                child: const CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.black54,
                                  child: Icon(Icons.close,
                                      size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
