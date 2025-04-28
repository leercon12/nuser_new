import 'package:delayed_widget/delayed_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/info_set/info_set.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/multi_state/car/car_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/multi_state/updown/updown_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/multi_state/multi_cargo_set.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/normal_state/price/price.dart';

class MultiMainPage extends StatelessWidget {
  final String? callType;
  final Map<String, dynamic>? cargo;
  const MultiMainPage({super.key, this.callType, this.cargo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AddInfoSet(),
        const SizedBox(height: 28),
        DelayedWidget(
          delayDuration: const Duration(milliseconds: 300),
          animation: DelayedAnimations.SLIDE_FROM_BOTTOM,
          animationDuration: const Duration(milliseconds: 500),
          child: MultiUpDownMainPage(
            callType: callType,
            cargo: cargo,
          ),
        ),
        const SizedBox(height: 32),
        DelayedWidget(
            delayDuration: const Duration(milliseconds: 600),
            animation: DelayedAnimations.SLIDE_FROM_BOTTOM,
            animationDuration: const Duration(milliseconds: 500),
            child: const MultiCarMain()),
        const SizedBox(height: 32),
        DelayedWidget(
            delayDuration: const Duration(milliseconds: 900),
            animation: DelayedAnimations.SLIDE_FROM_BOTTOM,
            animationDuration: const Duration(milliseconds: 500),
            child: AddPricePage(
              callType: callType.toString(),
            )),
        const SizedBox(height: 250),
      ],
    );
  }
}
