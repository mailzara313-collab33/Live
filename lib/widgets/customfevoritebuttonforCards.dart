import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Provider/Favourite/FavoriteProvider.dart';
import 'package:eshop_multivendor/Provider/Favourite/UpdateFavProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/Dashboard/Dashboard.dart';
import 'package:eshop_multivendor/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Favori butonu — kalp/pati bounce animasyonu ile
class CustomFevoriteButtonForCart extends StatefulWidget {
  final Product model;
  const CustomFevoriteButtonForCart({super.key, required this.model});

  @override
  State<CustomFevoriteButtonForCart> createState() =>
      _CustomFevoriteButtonForCartState();
}

class _CustomFevoriteButtonForCartState
    extends State<CustomFevoriteButtonForCart>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
    // Pati bounce: 1.0 → 1.38 → 0.85 → 1.0
    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.38)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.38, end: 0.85)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.85, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
    ]).animate(_bounceCtrl);
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  void _triggerBounce() {
    _bounceCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.gray, width: 1),
        color: Theme.of(context).colorScheme.white,
        borderRadius: const BorderRadius.all(
          Radius.circular(circularBorderRadius50),
        ),
      ),
      child: widget.model.isFavLoading!
          ? const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 0.7,
                ),
              ),
            )
          : Selector<FavoriteProvider, List<String?>>(
              builder: (context, data, child) {
                final isFav = data.contains(widget.model.id);
                return InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ScaleTransition(
                      scale: _bounceAnim,
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isFav ? colors.primary : null,
                      ),
                    ),
                  ),
                  onTap: () {
                    _triggerBounce();
                    if (context.read<UserProvider>().userId != '') {
                      if (!isFav) {
                        widget.model.isFavLoading = true;
                        widget.model.isFav = '1';

                        Future.delayed(Duration.zero)
                            .then((value) => context
                                .read<UpdateFavProvider>()
                                .addFav(context, widget.model.id!, 1,
                                    model: widget.model))
                            .then(
                          (value) {
                            widget.model.isFavLoading = false;
                          },
                        );
                      } else {
                        widget.model.isFavLoading = true;
                        widget.model.isFav = '0';
                        Future.delayed(Duration.zero)
                            .then(
                          (value) =>
                              context.read<UpdateFavProvider>().removeFav(
                                    widget.model.id!,
                                    widget.model.prVarientList![0].id!,
                                    context,
                                  ),
                        )
                            .then(
                          (value) {
                            widget.model.isFavLoading = false;
                          },
                        );
                      }
                    } else {
                      if (!isFav) {
                        widget.model.isFavLoading = true;
                        widget.model.isFav = '1';
                        context
                            .read<FavoriteProvider>()
                            .addFavItem(widget.model);
                        db.addAndRemoveFav(widget.model.id!, true);
                        widget.model.isFavLoading = false;
                        setSnackbar(
                            'Added to favorite'.translate(context: context),
                            context);
                      } else {
                        widget.model.isFavLoading = true;
                        widget.model.isFav = '0';
                        context
                            .read<FavoriteProvider>()
                            .removeFavItem(
                                widget.model.prVarientList![0].id!);
                        db.addAndRemoveFav(widget.model.id!, false);
                        widget.model.isFavLoading = false;
                        setSnackbar(
                          'Removed from favorite'.translate(context: context),
                          context,
                        );
                      }
                    }
                  },
                );
              },
              selector: (_, provider) => provider.favIdList,
            ),
    );
  }
}
