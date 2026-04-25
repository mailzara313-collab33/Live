import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';
import '../Model/Section_Model.dart';
import '../Provider/Favourite/UpdateFavProvider.dart';

/// Sepete ekle bölümü — ekleme anında scale + renk flash animasyonu
class CommonAddCartSection extends StatefulWidget {
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
  State<CommonAddCartSection> createState() => _CommonAddCartSectionState();
}

class _CommonAddCartSectionState extends State<CommonAddCartSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _successCtrl;
  late Animation<double> _successScale;

  bool _showSuccessFlash = false;

  @override
  void initState() {
    super.initState();
    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // Sepete ekle: 1.0 → 1.10 → 1.0 (kısa başarı pulse)
    _successScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.10)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.10, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 55,
      ),
    ]).animate(_successCtrl);
  }

  @override
  void dispose() {
    _successCtrl.dispose();
    super.dispose();
  }

  void _triggerSuccess() {
    _successCtrl.forward(from: 0);
    if (mounted) setState(() => _showSuccessFlash = true);
    Future.delayed(const Duration(milliseconds: 380), () {
      if (mounted) setState(() => _showSuccessFlash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!cartBtnList) return const SizedBox();
    if (widget.model.prVarientList![0].availability == '0') {
      return const SizedBox();
    }

    if (widget.controller.text == '0') {
      return _buildAddButton(context);
    } else {
      return _buildQuantityControls(context);
    }
  }

  Widget _buildAddButton(BuildContext context) {
    return ScaleTransition(
      scale: _successScale,
      child: InkWell(
        onTap: () {
          if (widget.checkFavStatus) {
            if (context.read<UpdateFavProvider>().getCurrentStatus !=
                UpdateFavStatus.inProgress) {
              _triggerSuccess();
              widget.onAddToCart();
            }
          } else {
            if (!widget.isProgress) {
              _triggerSuccess();
              widget.onAddToCart();
            }
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 25,
          width: 80,
          decoration: BoxDecoration(
            color: _showSuccessFlash
                ? colors.primary.withValues(alpha: 0.12)
                : Theme.of(context).colorScheme.white,
            border: Border.all(
              color: _showSuccessFlash
                  ? colors.primary
                  : Theme.of(context).colorScheme.gray,
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
                    color: _showSuccessFlash
                        ? colors.primary
                        : Theme.of(context).colorScheme.black,
                    fontSize: textFontSize13,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'ubuntu',
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 35,
                  decoration: BoxDecoration(
                    color: _showSuccessFlash
                        ? colors.primary
                        : Theme.of(context).colorScheme.gray,
                    border: Border.all(
                      color: _showSuccessFlash
                          ? colors.primary
                          : Theme.of(context).colorScheme.gray,
                      width: 1,
                    ),
                    borderRadius: const BorderRadiusDirectional.only(
                      bottomEnd: Radius.circular(circularBorderRadius4),
                      topEnd: Radius.circular(circularBorderRadius4),
                    ),
                  ),
                  child: Icon(
                    _showSuccessFlash ? Icons.check : Icons.add,
                    color: _showSuccessFlash
                        ? colors.whiteTemp
                        : Theme.of(context).colorScheme.black,
                    size: 15,
                  ),
                ),
              ),
            ],
          ),
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
        if (widget.checkFavStatus) {
          if (int.parse(widget.controller.text) > 0 &&
              context.read<UpdateFavProvider>().getCurrentStatus !=
                  UpdateFavStatus.inProgress) {
            widget.onRemoveFromCart();
          }
        } else {
          if (!widget.isProgress && int.parse(widget.controller.text) > 0) {
            widget.onRemoveFromCart();
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
            controller: widget.controller,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
          PopupMenuButton<String>(
            tooltip: '',
            icon: const Icon(Icons.arrow_drop_down, size: 1),
            onSelected: (String value) {
              if (widget.checkFavStatus) {
                if (context.read<UpdateFavProvider>().getCurrentStatus !=
                    UpdateFavStatus.inProgress) {
                  widget.onQuantitySelected(value);
                }
              } else {
                if (!widget.isProgress) {
                  widget.onQuantitySelected(value);
                }
              }
            },
            itemBuilder: (BuildContext context) {
              return widget.itemsCounter
                  .map<PopupMenuItem<String>>((String value) {
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
        if (widget.checkFavStatus) {
          if (context.read<UpdateFavProvider>().getCurrentStatus !=
              UpdateFavStatus.inProgress) {
            widget.onUpdateCart();
          }
        } else {
          if (!widget.isProgress) {
            widget.onUpdateCart();
          }
        }
      },
    );
  }
}
