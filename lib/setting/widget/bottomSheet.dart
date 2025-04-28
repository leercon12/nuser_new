import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';

class BottomSheetWidget extends StatelessWidget {
  final Widget contents;
  const BottomSheetWidget({super.key, required this.contents});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          color: msgBackColor,
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BottomTobMarker(),
              ],
            ),
            const SizedBox(height: 23),
            contents
          ],
        ),
      ),
    );
  }
}

class BottomTobMarker extends StatelessWidget {
  const BottomTobMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 5,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), color: Colors.grey),
    );
  }
}
