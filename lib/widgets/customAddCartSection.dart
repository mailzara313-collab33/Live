import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';
import '../Model/Section_Model.dart';
import '../Provider/Favourite/UpdateFavProvider.dart';

/// Common Add Cart Section Widget
/// Displays "Add to Cart" button when quantity is 0
/// Displays quantity controls (-, qty, +) when item is in cart
class CommonAddCartSection extends StatelessWidget {
  final TextEditingController controller;
  final Product model;
  final Function() onAddToCart;
  final Function() onRemoveFromCart;
  final Function() onUpdateCart;
  final List<String> itemsCounter;
  final Function(String value) onQuantitySelected;
  final bool isProgress;
  final bool checkFavStatus;

  const CommonAddCartSection({
    super.key,
    required this.controller,
    required this.model,
    required this.onAddToCart,
    required this.onRemoveFromCart,
    required this.onUpdateCart,
    required this.itemsCounter,
    required this.onQuantitySelected,
    this.isProgress = false,
    this.checkFavStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!cartBtnList) {
      return const SizedBox();
    }

    if (model.prVarientList![0].availability == '0') {
      return const SizedBox();
    }

    if (controller.text == '0') {
      return _buildAddButton(context);
    } else {
      return _buildQuantityControls(context);
    }
  }

  Widget _buildAddButton(BuildContext context) {
    return InkWell(
      onTap: () {
        if (checkFavStatus) {
          if (context.read<UpdateFavProvider>().getCurrentStatus !=
              UpdateFavStatus.inProgress) {
            onAddToCart();
          }
        } else {
          if (!isProgress) {
            onAddToCart();
          }
        }
      },
      child: Container(
        height: 25,
        width: 80,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          border: Border.all(
            color: Theme.of(context).colorScheme.gray,
            width: 1,
          ),
          borderRadius: const BorderRadiusDirectional.all(
            Radius.circular(circularBorderRadius7),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                'ADD'.translate(context: context),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Theme.of(context).colorScheme.black,
                  fontSize: textFontSize13,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'ubuntu',
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                height: 35,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.gray,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.gray,
                    width: 1,
                  ),
                  borderRadius: const BorderRadiusDirectional.only(
                    bottomEnd: Radius.circular(circularBorderRadius4),
                    topEnd: Radius.circular(circularBorderRadius4),
                  ),
                ),
                child: Icon(
                  Icons.add,
                  color: Theme.of(context).colorScheme.black,
                  size: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControls(BuildContext context) {
    return Row(
      children: <Widget>[
        _buildRemoveButton(context),
        _buildQuantitySelector(context),
        _buildAddButton2(context),
      ],
    );
  }

  Widget _buildRemoveButton(BuildContext context) {
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          border: Border.all(
            color: Theme.of(context).colorScheme.gray,
            width: 1,
          ),
          borderRadius: const BorderRadiusDirectional.all(
            Radius.circular(circularBorderRadius7),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(
            Icons.remove,
            size: 15,
            color: Theme.of(context).colorScheme.black,
          ),
        ),
      ),
      onTap: () {
        if (checkFavStatus) {
          if (int.parse(controller.text) > 0 &&
              context.read<UpdateFavProvider>().getCurrentStatus !=
                  UpdateFavStatus.inProgress) {
            onRemoveFromCart();
          }
        } else {
          if (!isProgress && int.parse(controller.text) > 0) {
            onRemoveFromCart();
          }
        }
      },
    );
  }

  Widget _buildQuantitySelector(BuildContext context) {
    return Container(
      width: 37,
      height: 20,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.white,
        borderRadius: BorderRadius.circular(circularBorderRadius5),
      ),
      child: Stack(
        children: [
          TextField(
            textAlign: TextAlign.center,
            readOnly: true,
            style: TextStyle(
              fontSize: textFontSize12,
              color: Theme.of(context).colorScheme.fontColor,
            ),
            controller: controller,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
          PopupMenuButton<String>(
            tooltip: '',
            icon: const Icon(Icons.arrow_drop_down, size: 1),
            onSelected: (String value) {
              if (checkFavStatus) {
                if (context.read<UpdateFavProvider>().getCurrentStatus !=
                    UpdateFavStatus.inProgress) {
                  onQuantitySelected(value);
                }
              } else {
                if (!isProgress) {
                  onQuantitySelected(value);
                }
              }
            },
            itemBuilder: (BuildContext context) {
              return itemsCounter.map<PopupMenuItem<String>>((String value) {
                return PopupMenuItem(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'ubuntu',
                      color: Theme.of(context).colorScheme.fontColor,
                    ),
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton2(BuildContext context) {
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          border: Border.all(
            color: Theme.of(context).colorScheme.gray,
            width: 1,
          ),
          borderRadius: const BorderRadiusDirectional.all(
            Radius.circular(circularBorderRadius7),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(
            Icons.add,
            size: 15,
            color: Theme.of(context).colorScheme.black,
          ),
        ),
      ),
      onTap: () {
        if (checkFavStatus) {
          if (context.read<UpdateFavProvider>().getCurrentStatus !=
              UpdateFavStatus.inProgress) {
            onUpdateCart();
          }
        } else {
          if (!isProgress) {
            onUpdateCart();
          }
        }
      },
    );
  }
}
