import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerEffect extends StatelessWidget {
  const ShimmerEffect({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: SingleChildScrollView(
          child: Column(
            children: List.generate(10, (index) {
              return Padding(
                padding: const EdgeInsetsDirectional.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100.0,
                      height: 120.0,
                      color: Theme.of(context).colorScheme.white,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 18.0,
                            color: Theme.of(context).colorScheme.white,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.0),
                          ),
                          Container(
                            width: double.infinity,
                            height: 8.0,
                            color: Theme.of(context).colorScheme.white,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.0),
                          ),
                          Container(
                            width: 100.0,
                            height: 8.0,
                            color: Theme.of(context).colorScheme.white,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.0),
                          ),
                          Container(
                            width: 20.0,
                            height: 8.0,
                            color: Theme.of(context).colorScheme.white,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class SingleItemSimmer extends StatelessWidget {
  const SingleItemSimmer({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80.0,
                height: 80.0,
                color: Theme.of(context).colorScheme.white,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 18.0,
                      color: Theme.of(context).colorScheme.white,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                    ),
                    Container(
                      width: double.infinity,
                      height: 8.0,
                      color: Theme.of(context).colorScheme.white,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                    ),
                    Container(
                      width: 100.0,
                      height: 8.0,
                      color: Theme.of(context).colorScheme.white,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                    ),
                    Container(
                      width: 20.0,
                      height: 8.0,
                      color: Theme.of(context).colorScheme.white,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SimmerSingleProduct extends StatelessWidget {
  const SimmerSingleProduct({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          color: Theme.of(context).colorScheme.white,
        ),
      ),
    );
  }
}

class ShimmerEffectGrid extends StatelessWidget {
  const ShimmerEffectGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Adjust the number of columns here
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 3 / 4, // Adjust aspect ratio if needed
          ),
          itemCount: 10,
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 150.0,
                  color: Theme.of(context).colorScheme.surface,
                ),
                const SizedBox(height: 8.0),
                Container(
                  width: double.infinity,
                  height: 18.0,
                  color: Theme.of(context).colorScheme.surface,
                ),
                const SizedBox(height: 8.0),
                Container(
                  width: 100.0,
                  height: 8.0,
                  color: Theme.of(context).colorScheme.surface,
                ),
                const SizedBox(height: 8.0),
                Container(
                  width: 50.0,
                  height: 8.0,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
