import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_widget/delayed_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/future_btn_state/normal/add_new.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/future_btn_state/normal/re_add.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/future_btn_state/normal/reset.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/hashProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/service/add_future_service.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';

class NormalBtnState extends StatefulWidget {
  final String callType;
  final Map<String, dynamic>? cargo;
  const NormalBtnState({super.key, required this.callType, this.cargo});

  @override
  State<NormalBtnState> createState() => _NormalBtnStateState();
}

class _NormalBtnStateState extends State<NormalBtnState> {
  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final mapProvider = Provider.of<MapProvider>(context);
    final addProvider = Provider.of<AddProvider>(context);
    return Column(
      children: [
        if (addProvider.addMainType != null &&
            addProvider.addSubType != null &&
            addProvider.setUpDate != null &&
            addProvider.setDownDate != null &&
            (addProvider.addMainType == '다구간'
                ? addProvider.locationCount >= 3
                : addProvider.setLocationUpNLatLng != null &&
                    addProvider.setLocationDownNLatLng != null) &&
            addProvider.setCarType != null &&
            addProvider.setCarTon.isNotEmpty &&
            (addProvider.isPriceType == '직접 결제'
                ? addProvider.payHowto.length >= 2
                : addProvider.isPriceType == '포인트 결제'))
          DelayedWidget(
            animation: DelayedAnimations.SLIDE_FROM_BOTTOM,
            animationDuration: const Duration(milliseconds: 500),
            child: GestureDetector(
              onTap: () async {
                print('@@');
                print(widget.callType);
                HapticFeedback.lightImpact();
                if (isPassedDate(addProvider.setUpDate!) == true ||
                    isPassedDate(addProvider.setDownDate!) == true) {
                  ScaffoldMessenger.of(context).showSnackBar(errorSnackBar(
                      '상차일 또는 하차일이 이미 지났습니다.\n상차일 또는 하차일을 확인하세요.', context));
                } else {
                  try {
                    mapProvider.isLoadingState(true);
                    if (widget.callType.contains('완료다시등록')) {
                      bool success =
                          await addCargoNor(addProvider, '', context);
                      Navigator.pop(context);
                      if (!success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            currentSnackBar('데이터 처리 중 오류가 발생했습니다.', context));
                        return;
                      }
                    } else if (widget.callType.contains('수정')) {
                      print('@@@@@@@@');
                      print(widget.callType);
                      await resetNormal(addProvider, widget.cargo!['id'],
                          widget.cargo, widget.callType, context);
                    } else if (widget.callType.contains('재등록')) {
                      await reAddNormal(
                          addProvider, widget.cargo!['id'], context);
                    } else {
                      await addCargoNor(addProvider, '', context);
                    }

                    mapProvider.isLoadingState(false);

                    ScaffoldMessenger.of(context).showSnackBar(
                        currentSnackBar('운송 요청이 정상적으로 등록되었습니다.', context));
                  } catch (e) {
                    print('등록 에러 $e');
                    ScaffoldMessenger.of(context).showSnackBar(errorSnackBar(
                        '운송 요청 등록에 실패했습니다.\n잠시 후 다시 시도하세요.', context));
                  }
                }
              },
              child: Container(
                // width: 328,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: kGreenFontColor,
                ),
                child: Center(
                  child: KTextWidget(
                      text: widget.callType.contains('재등록')
                          ? '운송 정보 재등록'
                          : widget.callType.contains('수정')
                              ? '운송 정보 수정'
                              : '신규 화물 등록',
                      size: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          )
        else
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_normalState(addProvider)],
            ),
          )
      ],
    );
  }

  Widget _normalState(AddProvider addProvider) {
    return Row(
      children: [
        _countBox(addProvider.addMainType != null),
        _countBox(addProvider.setLocationUpNLatLng != null &&
            addProvider.setLocationDownNLatLng != null),
        _countBox(
            addProvider.setCarType != null && addProvider.addCargoInfo != null),
        _countBox(false),
      ],
    );
  }

  Widget _countBox(bool isState) {
    return Container(
        margin: const EdgeInsets.only(right: 8),
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: isState ? kGreenFontColor : Colors.grey.withOpacity(0.3),
        ));
  }
}
