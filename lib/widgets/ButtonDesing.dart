import 'package:eshop_multivendor/Helper/String.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';

// Ana buton — hover/tap scale animasyonu (1.0 → 1.05)
class SimBtn extends StatefulWidget {
  final String? title;
  final VoidCallback? onBtnSelected;
  final double? size;
  final double? height;
  final double? paddingvalue;
  final Color? backgroundColor, borderColor, titleFontColor;
  final double? borderWidth, borderRadius;

  const SimBtn({
    super.key,
    this.title,
    this.onBtnSelected,
    this.size,
    this.height,
    this.titleFontColor,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
    this.paddingvalue,
    this.backgroundColor,
  });

  @override
  State<SimBtn> createState() => _SimBtnState();
}

class _SimBtnState extends State<SimBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double computedSize =
        MediaQuery.of(context).size.width * widget.size!;

    return GestureDetector(
      onTapDown: (_) => _scaleCtrl.forward(),
      onTapUp: (_) => _scaleCtrl.reverse(),
      onTapCancel: () => _scaleCtrl.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: _buildBtn(context, computedSize),
      ),
    );
  }

  Widget _buildBtn(BuildContext context, double size) {
    return CupertinoButton(
      padding: widget.paddingvalue != null
          ? EdgeInsets.all(widget.paddingvalue!)
          : null,
      child: Container(
        width: size,
        height: widget.height ?? 35,
        alignment: FractionalOffset.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.grad1Color, colors.grad2Color],
            stops: [0, 1],
          ),
          color: widget.backgroundColor ?? colors.primary,
          borderRadius: BorderRadius.all(
            Radius.circular(widget.borderRadius ?? 0.0),
          ),
          border: Border.all(
            width: widget.borderWidth ?? 0,
            color: widget.borderColor ?? Colors.transparent,
          ),
        ),
        child: Text(
          widget.title!,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: widget.titleFontColor ?? colors.whiteTemp,
                fontWeight: FontWeight.normal,
                fontFamily: 'ubuntu',
              ),
        ),
      ),
      onPressed: () {
        widget.onBtnSelected!();
      },
    );
  }
}

// Giriş ekranı butonu
class LoginButtons extends StatelessWidget {
  final String? label;
  final Color textColour;
  final Color boxColor;
  final Widget? widgets;
  final Function onpressfunction;
  const LoginButtons(
      {super.key,
      this.label,
      required this.textColour,
      required this.boxColor,
      required this.onpressfunction,
      this.widgets});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding:
          const EdgeInsetsDirectional.symmetric(vertical: 15, horizontal: 0),
      onPressed: () => onpressfunction(),
      child: Container(
          height: 50,
          alignment: FractionalOffset.center,
          decoration: BoxDecoration(
              color: boxColor,
              boxShadow: [
                BoxShadow(
                    color: boxColor.withValues(alpha: 0.5),
                    blurRadius: 9.0,
                    spreadRadius: 2),
              ],
              borderRadius: BorderRadius.circular(circularBorderRadius50)),
          child: label != null
              ? Text(
                  label!.translate(context: context),
                  style: TextStyle(
                    color: textColour,
                    fontFamily: 'ubuntu',
                  ),
                )
              : widgets),
    );
  }
}

class AppBtn extends StatelessWidget {
  final String? title;
  final AnimationController? btnCntrl;
  final Animation? btnAnim;
  final VoidCallback? onBtnSelected;
  final bool removeTopPadding;

  const AppBtn({
    super.key,
    this.title,
    this.btnCntrl,
    this.btnAnim,
    this.onBtnSelected,
    this.removeTopPadding = false,
  });

  @override
  Widget build(BuildContext context) {
    final initialWidth = btnAnim!.value;
    return AnimatedBuilder(
      builder: (c, child) => _buildBtnAnimation(
        c,
        child,
        initialWidth: initialWidth,
      ),
      animation: btnCntrl!,
    );
  }

  Widget _buildBtnAnimation(BuildContext context, Widget? child,
      {required double initialWidth}) {
    return CupertinoButton(
      padding: EdgeInsetsDirectional.only(
        top: removeTopPadding ? 0 : 25,
        start: 0,
        end: 0,
      ),
      child: Container(
        height: 50,
        alignment: FractionalOffset.center,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.5),
                  blurRadius: 9.0,
                  spreadRadius: 2),
            ],
            borderRadius: BorderRadius.circular(circularBorderRadius50)),
        child: btnAnim!.value > 75.0
            ? Text(
                title!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: colors.whiteTemp,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'ubuntu',
                    ),
              )
            : const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  colors.whiteTemp,
                ),
              ),
      ),
      onPressed: () {
        if (btnAnim!.value == initialWidth) {
          onBtnSelected!();
        }
      },
    );
  }
}
