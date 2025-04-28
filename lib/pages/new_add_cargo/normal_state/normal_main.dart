import 'package:delayed_widget/delayed_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/normal_state/price/price.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/normal_state/cargo/cargomain_page.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/normal_state/up_down/up_down_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/info_set/info_set.dart';

class NormalMainState extends StatelessWidget {
  final String? callType;
  final Map<String, dynamic>? cargo;
  const NormalMainState({super.key, this.callType, this.cargo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AddInfoSet(),
        const SizedBox(height: 16),
        const AddUpDownMainPage(),
        const SizedBox(height: 32),
        AddCargoPage(
          callType: callType,
        ),
        const SizedBox(height: 32),
        DelayedWidget(
            delayDuration: const Duration(milliseconds: 900),
            animation: DelayedAnimations.SLIDE_FROM_BOTTOM,
            animationDuration: const Duration(milliseconds: 500),
            child: AddPricePage(
              callType: callType.toString(),
            )),
        const SizedBox(height: 32),
        const SizedBox(height: 250),
      ],
    );
  }
}
