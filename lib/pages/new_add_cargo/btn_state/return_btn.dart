import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/model/multi_cargo_add_model.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/normal/bottomSheet/cancel.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/btn_state/history.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/btn_state/multi_btn.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/future_btn_state/return/add.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/future_btn_state/return/com_re.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/future_btn_state/return/reAdd.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/future_btn_state/return/reset.dart';
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

class ReturnBtnState extends StatefulWidget {
  final String callType;
  final Map<String, dynamic>? cargo;
  const ReturnBtnState({
    super.key,
    required this.callType,
    this.cargo,
  });

  @override
  State<ReturnBtnState> createState() => _ReturnBtnStateState();
}

class _ReturnBtnStateState extends State<ReturnBtnState> {
  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);
    final addProvider = Provider.of<AddProvider>(context);
    final dw = MediaQuery.of(context).size.width;
    return SizedBox(
      width: dw,
      child: Column(
        children: [
          if (addProvider.addMainType != null &&
              addProvider.addSubType != null &&
              addProvider.locationCount == 3 &&
              addProvider.setCarType != null &&
              addProvider.setCarTon.isNotEmpty &&
              (addProvider.isPriceType == '직접 결제'
                  ? addProvider.payHowto.length >= 2
                  : addProvider.isPriceType == '포인트 결제'))
            GestureDetector(
              onTap: () async {
                HapticFeedback.lightImpact();
                print(widget.callType);
                // 1. 날짜 유효성 검사
                if (hasBeforeDateLocations(addProvider.locations)) {
                  ScaffoldMessenger.of(context).showSnackBar(errorSnackBar(
                      '구성건 중, 오늘 이전일이 포함되었습니다.\n상, 하차일자를 확인하세요.', context));
                  return;
                }

                // 2. 경로 좌표 검증 및 업데이트
                if (!checkCoordinatesIncludesAllPoints(addProvider)) {
                  print('경로 좌표 불일치 감지, 경로 업데이트 시도...');

                  await addProvider.checkAndUpdateRoute();
                  await Future.delayed(const Duration(seconds: 1));

                  if (checkCoordinatesIncludesAllPoints(addProvider)) {
                    print('경로 업데이트 후에도 좌표 불일치');
                    ScaffoldMessenger.of(context).showSnackBar(
                        errorSnackBar('경로 업데이트에 실패했습니다. 다시 시도해주세요.', context));
                    return;
                  }
                }

                await _setReturn(mapProvider, addProvider);
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
            )
          else
            _normalState(addProvider),
        ],
      ),
    );
  }

  Widget _normalState(AddProvider addProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _countBox(addProvider.addMainType != null),
        _countBox(addProvider.locationCount == 3),
        _countBox(
            addProvider.setCarType != null && addProvider.carOption.isNotEmpty),
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

  Future _setReturn(MapProvider mapProvider, AddProvider addProvider) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final hashProvider = Provider.of<HashProvider>(context, listen: false);

    print(widget.callType);

    try {
      mapProvider.isLoadingState(true);
      dataProvider.userProvider();
      List<CargoPoint> points = addProvider.getDetailedLocationCoordinates();
      if (widget.callType.contains('완료다시등록')) {
        String uniqueString = await generateUniqueString(
            addProvider.senderType == '일반'
                ? dataProvider.userData!.uid
                : dataProvider.userData!.company[0],
            addProvider.locations[0].date!);
        if (uniqueString.isNotEmpty) {
          /*      bool success = await ComReInfo(
              addProvider.locations,
              addProvider,
              hashProvider,
              dataProvider,
              mapProvider,
              widget.cargo!,
              widget.callType,
              context); */

          if (widget.cargo!['cargoStat'] != '운송완료' ||
              widget.cargo!['cargoStat'] != '하차완료') {
            await FirebaseFirestore.instance
                .collection('cargoInfo')
                .doc(addProvider.senderType == '일반'
                    ? dataProvider.userData!.uid
                    : dataProvider.userData!.company[0])
                .collection(extractFour(widget.cargo!['id']))
                .doc(widget.cargo!['id'])
                .update({'cargoStat': '취소'});
          }
          bool success = await updateListState(
              addProvider.locations,
              addProvider,
              hashProvider,
              dataProvider,
              mapProvider,
              uniqueString,
              context);
          Navigator.pop(context);
          if (!success) {
            ScaffoldMessenger.of(context)
                .showSnackBar(currentSnackBar('데이터 처리 중 오류가 발생했습니다.', context));
            return;
          }
        }
      } else if (widget.callType.contains('수정')) {
        print('수정으로 감');
        await returnReInfo(addProvider.locations, addProvider, hashProvider,
            dataProvider, mapProvider, widget.cargo!, widget.callType, context);
      } else if (widget.callType.contains('재등록')) {
        await returnReSet(addProvider.locations, addProvider, hashProvider,
            dataProvider, mapProvider, widget.cargo!, context);
      } else {
        String uniqueString = await generateUniqueString(
            addProvider.senderType == '일반'
                ? dataProvider.userData!.uid
                : dataProvider.userData!.company[0],
            addProvider.locations[0].date!);
        if (uniqueString.isNotEmpty) {
          bool success = await updateListState(
              addProvider.locations,
              addProvider,
              hashProvider,
              dataProvider,
              mapProvider,
              uniqueString,
              context);

          if (!success) {
            ScaffoldMessenger.of(context)
                .showSnackBar(currentSnackBar('데이터 처리 중 오류가 발생했습니다.', context));
            return;
          }
        }
      }

      mapProvider.isLoadingState(false);
      Navigator.pop(context);
    } catch (e) {
      mapProvider.isLoadingState(false);
      print('_updateReturn 에러: $e');
      mapProvider.isLoadingState(false);
      ScaffoldMessenger.of(context)
          .showSnackBar(currentSnackBar('오류가 발생했습니다.', context));
    }
  }
}
