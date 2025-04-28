import 'package:delayed_widget/delayed_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/multi_state/multi_cargo_set.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/normal_state/up_down/set_page/updown_set.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/normal_state/up_down/up/add_up.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/multimap.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';

class AddUpDownMainPage extends StatefulWidget {
  const AddUpDownMainPage({super.key});

  @override
  State<AddUpDownMainPage> createState() => _AddUpDownMainPageState();
}

class _AddUpDownMainPageState extends State<AddUpDownMainPage> {
  @override
  void initState() {
    super.initState();
    //  final addProvider = Provider.of<AddProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddProvider>().checkAndUpdateSimpleRoute();
    });
    /*  if (addProvider.addMainType == '다구간') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AddProvider>().checkAndUpdateRoute();
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AddProvider>().checkAndUpdateSimpleRoute();
      });
    } */
  }

  @override
  Widget build(BuildContext context) {
    final addProvider = Provider.of<AddProvider>(context);
    final dw = MediaQuery.of(context).size.width;
    bool _isState = addProvider.setLocationUpNLatLng != null &&
        addProvider.setLocationDownNLatLng != null;
    return DelayedWidget(
      animation: DelayedAnimations.SLIDE_FROM_BOTTOM,
      delayDuration: const Duration(milliseconds: 300),
      animationDuration: const Duration(milliseconds: 500),
      child: SizedBox(
        width: dw,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            KTextWidget(
                text: '상, 하차지 등록',
                size: 16,
                fontWeight: FontWeight.bold,
                color: _isState == true
                    ? Colors.grey.withOpacity(0.5)
                    : Colors.white),
            _isState == false
                ? const KTextWidget(
                    text: '운송 화물의 상차지 - 하차지 정보를 등록하세요.',
                    size: 14,
                    fontWeight: null,
                    color: Colors.grey)
                : const SizedBox(),
            const SizedBox(height: 12),
            Column(
              children: [
                _noSetBox('상차', addProvider, context),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    KTextWidget(
                        text: '...',
                        size: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.withOpacity(0.7)),
                    const SizedBox(width: 10),
                    Image.asset('asset/img/down_cir.png', width: 30),
                    const SizedBox(width: 10),
                    KTextWidget(
                        text: addProvider.totalDistance,
                        size: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.withOpacity(0.7)),
                  ],
                ),
                const SizedBox(height: 10),
                _noSetBox('하차', addProvider, context)
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _noSetBox(String callType, AddProvider addProvider, context) {
    bool _isDone = callType == '상차'
        ? addProvider.setLocationCargoUpType == null ||
            addProvider.setLocationUpPhone == null ||
            addProvider.setLocationUpAddress1 == null ||
            addProvider.setUpDate == null ||
            addProvider.addUpSenderType == null
        : addProvider.setLocationCargoDownType == null ||
            addProvider.setLocationDownPhone == null ||
            addProvider.setLocationDownAddress1 == null ||
            addProvider.setDownDate == null ||
            addProvider.addDownSenderType == null;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddUpDownSetPage(callType: callType)),
        );
      },
      child: _isDone
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), color: msgBackColor),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (callType == '상차')
                        Image.asset(
                          'asset/img/cargo_up.png',
                          width: 15,
                        )
                      else
                        Image.asset(
                          'asset/img/cargo_down.png',
                          width: 15,
                        ),
                      const SizedBox(width: 10),
                      KTextWidget(
                          text: callType == '상차'
                              ? '이곳을 클릭하여 상차지 정보를 등록하세요.'
                              : '이곳을 클릭하여 하차지 정보를 등록하세요.',
                          size: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)
                    ],
                  )
                ],
              ),
            )
          : AddUpPage(
              callType: callType,
            ),
    );
  }
}
