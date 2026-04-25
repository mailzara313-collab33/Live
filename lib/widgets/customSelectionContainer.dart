import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';

class CustomSelectionContainer extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Function() onTap;
  final double radius;
  final Widget? customChild;
  const CustomSelectionContainer(
      {super.key,
      required this.title,
      required this.isSelected,
      required this.onTap,
      this.radius = 40,
      this.customChild});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.black.withValues(alpha: 0.4),
          ),
        ),
        child: customChild ??
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: isSelected
                          ? colors.whiteTemp
                          : Theme.of(context).colorScheme.fontColor,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontFamily: 'ubuntu',
                      fontSize: 14,
                    ),
              ),
            ),
      ),
    );
  }
}
