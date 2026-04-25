import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Helper/Constant.dart';
import '../../../Provider/Search/SearchProvider.dart';
import '../../ProductList&SectionView/ProductList.dart';

class TempTagWidget extends StatefulWidget {
  final ScrollController scrollController;
  const TempTagWidget({super.key, required this.scrollController});

  @override
  State<TempTagWidget> createState() => _TempTagWidgetState();
}

class _TempTagWidgetState extends State<TempTagWidget> {
  bool isLoadingMore = false;
  int currentChunkCount = 100;
  int chunkSize = 100;
  List<Widget> chips = [];
  @override
  void initState() {
    super.initState();
    loadChips();
    widget.scrollController.addListener(() {
      if (widget.scrollController.position.pixels >=
              widget.scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore) {
        // Close to bottom, load more
        loadMore();
      }
    });
  }

  Future<void> loadChips() async {
    await Future.delayed(Duration.zero);
    if (context.read<SearchProvider>().tagList.isNotEmpty) {
      for (int i = 0; i < context.read<SearchProvider>().tagList.length; i++) {
        ChoiceChip tagChip = ChoiceChip(
          selected: false,
          label: Text(context.read<SearchProvider>().tagList[i],
              style: TextStyle(
                  color: colors.blackTemp.withValues(alpha: 0.5),
                  fontSize: textFontSize11)),
          backgroundColor: colors.whiteTemp,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular(circularBorderRadius25))),
          side: BorderSide(
              color: Theme.of(context)
                  .colorScheme
                  .fontColor
                  .withValues(alpha: 0.1)),
          onSelected: (bool selected) {
            //if (mounted) {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => ProductList(
                  name: context.read<SearchProvider>().tagList[i],
                  fromSeller: false,
                  tag: true,
                ),
              ),
            );
            // }
          },
        );

        chips.add(Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: tagChip));
      }
    }
  }

  void loadMore() {
    if (currentChunkCount >= chips.length) return;

    setState(() {
      isLoadingMore = true;
    });

    // Simulate async load delay
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        currentChunkCount =
            (currentChunkCount + chunkSize).clamp(0, chips.length);
        isLoadingMore = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleChips = chips.take(currentChunkCount).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Divider(),
      Padding(
        padding: const EdgeInsetsDirectional.only(start: 15.0),
        child: Text(
          'Discover more'.translate(context: context),
          style: const TextStyle(fontSize: textFontSize16),
        ),
      ),
      Wrap(
          children: visibleChips
              .map((chip) => Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: chip,
                  ))
              .toList()),
    ]);
  }
}
