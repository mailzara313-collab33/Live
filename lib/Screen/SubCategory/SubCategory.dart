import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import '../../Helper/Constant.dart';
import '../../widgets/appBar.dart';
import '../../widgets/desing.dart';
import '../../widgets/GridViewProduct.dart';
import '../ProductList&SectionView/ProductList.dart';

class SubCategory extends StatefulWidget {
  final List<Product>? subList;
  final String title;
  final String? categoryId;
  const SubCategory({
    super.key,
    this.subList,
    required this.title,
    this.categoryId,
  });

  @override
  State<SubCategory> createState() => _SubCategoryState();
}

class _SubCategoryState extends State<SubCategory> {
  List<Product> productList = [];
  bool isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    // Fetch products if categoryId is provided
    if (widget.categoryId != null) {
      fetchCategoryProducts(widget.categoryId!);
    }
  }

  void setStateNow() {
    if (mounted) {
      setState(() {});
    }
  }

  // Fetch products for a category
  Future<void> fetchCategoryProducts(String categoryId) async {
    setState(() {
      isLoadingProducts = true;
    });

    try {
      Map<String, String> parameter = {CATID: categoryId};

      final response = await ApiBaseHelper().postAPICall(
        getProductApi,
        parameter,
      );

      if (response['error'] == false) {
        final data = response['data'];
        final List<Product> fetchedProducts = [];

        if (data != null && data is List) {
          for (var productData in data) {
            try {
              final product = Product.fromJson(productData);
              fetchedProducts.add(product);
            } catch (e) {
              print('Error parsing product: $e');
            }
          }
        }

        if (mounted) {
          setState(() {
            productList = fetchedProducts;
          });
        }
      }
    } catch (e) {
      print('Exception: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoadingProducts = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final subList = widget.subList ?? [];
    final hasSubcategories = subList.isNotEmpty;
    final hasProducts = productList.isNotEmpty;

    return Scaffold(
      appBar: getAppBar(widget.title, context, setStateNow),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show loading indicator while fetching products
            if (isLoadingProducts)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            // Horizontal subcategories section (only when products exist)
            if (hasSubcategories && hasProducts) ...[
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Subcategories'.translate(context: context),
                  style: TextStyle(
                    fontFamily: 'ubuntu',
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.bold,
                    fontSize: textFontSize14,
                  ),
                ),
              ),
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: subList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        if (subList[index].subList == null ||
                            subList[index].subList!.isEmpty) {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => ProductList(
                                name: subList[index].name,
                                id: subList[index].id,
                                tag: false,
                                fromSeller: false,
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => SubCategory(
                                subList: subList[index].subList,
                                title: subList[index].name ?? '',
                                categoryId: subList[index].id,
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 90,
                        margin: const EdgeInsets.only(right: 12),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  circularBorderRadius10,
                                ),
                                child: DesignConfiguration.getCacheNotworkImage(
                                  boxFit: extendImg
                                      ? BoxFit.cover
                                      : BoxFit.contain,
                                  context: context,
                                  heightvalue: null,
                                  widthvalue: null,
                                  imageurlString: subList[index].image!,
                                  placeHolderSize: null,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              subList[index].name!,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(
                                    fontFamily: 'ubuntu',
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.fontColor,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Divider(thickness: 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  'Products'.translate(context: context),
                  style: TextStyle(
                    fontFamily: 'ubuntu',
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.bold,
                    fontSize: textFontSize14,
                  ),
                ),
              ),
            ],
            // Products grid - shows products when available
            if (hasProducts && !isLoadingProducts)
              GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.58,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: productList.length,
                itemBuilder: (context, index) {
                  return GridViewProductListWidget(
                    productList: productList,
                    index: index,
                    pad: false,
                    setState: () {
                      if (mounted) {
                        setState(() {});
                      }
                    },
                  );
                },
              ),
            // GridView for all subcategories when no products exist
            if (hasSubcategories && !hasProducts && !isLoadingProducts)
              GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: subList.length,
                itemBuilder: (context, index) {
                  return subCatItem(index, context, subList);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget subCatItem(int index, BuildContext context, List<Product> subList) {
    return GestureDetector(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(circularBorderRadius10),
                child: DesignConfiguration.getCacheNotworkImage(
                  boxFit: extendImg ? BoxFit.cover : BoxFit.contain,
                  context: context,
                  heightvalue: null,
                  widthvalue: null,
                  placeHolderSize: 50,
                  imageurlString: subList[index].image!,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              subList[index].name!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontFamily: 'ubuntu',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      onTap: () {
        if (subList[index].subList == null || subList[index].subList!.isEmpty) {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => ProductList(
                name: subList[index].name,
                id: subList[index].id,
                tag: false,
                fromSeller: false,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => SubCategory(
                subList: subList[index].subList,
                title: subList[index].name ?? '',
                categoryId: subList[index].id,
              ),
            ),
          );
        }
      },
    );
  }
}
