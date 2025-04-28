import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_widget/delayed_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/model/multi_cargo_add_model.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/btn_state/history.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/future_btn_state/return/add.dart';
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

class MultiBtnState extends StatefulWidget {
  final String? callType;
  final Map<String, dynamic>? cargo;
  const MultiBtnState({super.key, this.callType, this.cargo});

  @override
  State<MultiBtnState> createState() => _MultiBtnStateState();
}

class _MultiBtnStateState extends State<MultiBtnState> {
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
              addProvider.locationCount >= 3 &&
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
                  HapticFeedback.lightImpact();
                  // print(addProvider.locations[0].upCargos[0].type);
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
                    await Future.delayed(Duration(seconds: 1));

                    if (checkCoordinatesIncludesAllPoints(addProvider)) {
                      print('경로 업데이트 후에도 좌표 불일치');
                      ScaffoldMessenger.of(context).showSnackBar(errorSnackBar(
                          '경로 업데이트에 실패했습니다. 다시 시도해주세요.', context));
                      return;
                    }
                  }

                  // 3. 멀티 추가 실행
                  if (addProvider.locationCount >= 3) {
                    await _addMulti(mapProvider, addProvider);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        errorSnackBar('다구간은 3곳 이상 지정되어야 합니다.', context));
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
                        text: widget.callType == '수정' ? '운송 정보 수정' : '신규 화물 등록',
                        size: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            )
          else
            _normalState(addProvider),
        ],
      ),
    );
  }

  Future<void> _addMulti(
      MapProvider mapProvider, AddProvider addProvider) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final hashProvider = Provider.of<HashProvider>(context, listen: false);
    mapProvider.isLoadingState(true);
    dataProvider.userProvider();
    try {
      mapProvider.isLoadingState(true);
      print(widget.callType);

      List<CargoPoint> points = addProvider.getDetailedLocationCoordinates();

      if (widget.callType!.contains('완료다시등록')) {
        String uniqueString = await generateUniqueString(
            addProvider.senderType == '일반'
                ? dataProvider.userData!.uid
                : dataProvider.userData!.company[0],
            addProvider.locations[0].date!);
        if (uniqueString.isNotEmpty) {
          if (widget.cargo!['cargoStat'] == '대기' &&
              widget.cargo!['cargoStat'] != '배차') {
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

          if (!success) {
            ScaffoldMessenger.of(context)
                .showSnackBar(currentSnackBar('데이터 처리 중 오류가 발생했습니다.', context));
            return;
          } else {
            Navigator.pop(context);
          }
        }
      } else if (widget.callType!.contains('수정')) {
        print('수정으로 감');
        await returnReInfo(
            addProvider.locations,
            addProvider,
            hashProvider,
            dataProvider,
            mapProvider,
            widget.cargo!,
            widget.callType.toString(),
            context);
      } else if (widget.callType!.contains('재등록')) {
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
            Navigator.pop(context);
            ScaffoldMessenger.of(context)
                .showSnackBar(currentSnackBar('데이터 처리 중 오류가 발생했습니다.', context));
            return;
          } else {
            Navigator.pop(context);
          }
        }
      }

/*       await generateUniqueString(addProvider.senderType == '일반'
              ? dataProvider.userData!.uid
              : dataProvider.userData!.company[0])
          .then((value) async {
        if (value.isNotEmpty) {
          await _updateListState(addProvider.locations, addProvider,
              hashProvider, dataProvider, value);

          // dataProvider.updateCurrentCargo(cargo)
        }
      });  */

      mapProvider.isLoadingState(false);
    } catch (e) {
      print(e);
      mapProvider.isLoadingState(false);
    }
  }

  Widget _normalState(AddProvider addProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
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

bool hasBeforeDateLocations(List<CargoLocation> locations) {
  // 오늘 날짜 (시간 제외)
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);

  // 각 location의 date가 오늘보다 이전인지 확인
  for (var location in locations) {
    final locationDate =
        DateTime(location.date!.year, location.date!.month, location.date!.day);

    // 하나라도 이전 날짜가 있으면 true
    if (locationDate.isBefore(todayDate)) {
      return true;
    }
  }

  // 이전 날짜가 없으면 false
  return false;
}

bool checkCoordinatesIncludesAllPoints(AddProvider addProvider) {
  const double tolerance = 0.001;
  final cargoPoints = addProvider.getDetailedLocationCoordinates();

  for (var location in addProvider.locations) {
    bool found = false;
    for (var point in cargoPoints) {
      if ((point.coordinate.latitude - location.location!.latitude).abs() <
              tolerance &&
          (point.coordinate.longitude - location.location!.longitude).abs() <
              tolerance) {
        found = true;
        break;
      }
    }

    if (!found) return false;
  }
  return true;
}
