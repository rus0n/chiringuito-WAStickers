import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerList extends StatelessWidget {
  const ShimmerList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer(
        gradient: LinearGradient(colors: [
          Colors.white54,
          Theme.of(context).primaryColor,
          Colors.white54
        ], begin: Alignment.bottomLeft, end: Alignment.topRight),
        child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: 30,
            itemBuilder: (_, index) => Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)))),
                      )
                    ],
                  ),
                )));
  }
}
