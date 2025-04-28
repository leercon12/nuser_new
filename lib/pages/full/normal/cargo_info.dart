import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/model/multi_cargo_add_model.dart';

import 'package:flutter_mixcall_normaluser_new/pages/full/btn/btn_state.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/multi/widget/price.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/normal/bottomSheet/cancel.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/normal/cargo.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/normal/price.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/normal/updown.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/new_add_main.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/hashProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';

class CargoInfoDetailPage extends StatefulWidget {
  final Map<String, dynamic> cargo;
  const CargoInfoDetailPage({super.key, required this.cargo});

  @override
  State<CargoInfoDetailPage> createState() => _CargoInfoDetailPageState();
}

class _CargoInfoDetailPageState extends State<CargoInfoDetailPage> {
  @override
  Widget build(BuildContext context) {
    final addProvider = Provider.of<AddProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final mapProvider = Provider.of<MapProvider>(context);
    final dw = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    const KTextWidget(
                        text: '상, 하자지 정보',
                        size: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (addProvider.isRoad == false) {
                          addProvider.isRoadState(true);
                        } else {
                          addProvider.isRoadState(false);
                        }
                      },
                      child: KTextWidget(
                          text: '도로명 주소',
                          size: 14,
                          fontWeight: null,
                          color: addProvider.isRoad == true
                              ? kOrangeBssetColor
                              : Colors.grey),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                DetailUpDown(
                  cargo: widget.cargo,
                  callType: '상차',
                ),
                const SizedBox(height: 12),
                Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: 36,
                            height: 36,
                            child: Image.asset('asset/img/down_cir.png')),
                      ],
                    ),
                    Positioned(
                        top: 8,
                        left: dw * 0.27,
                        child: Container(
                          height: 20,
                          width: 60,
                          child: KTextWidget(
                              text: widget.cargo['allDis'].toString(),
                              size: 13,
                              textAlign: TextAlign.end,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        )),
                    Positioned(
                        top: 8,
                        right: dw * 0.22,
                        child: Container(
                          height: 20,
                          width: 80,
                          child: KTextWidget(
                              text: widget.cargo['allDur'].toString(),
                              size: 13,
                              textAlign: TextAlign.start,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        )),
                  ],
                ),
                const SizedBox(height: 12),
                DetailUpDown(
                  cargo: widget.cargo,
                  callType: '하차',
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /*  KTextWidget(
                        text: '화물 정보',
                        size: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey), */
                    Container(
                      width: 90,
                      height: 3,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.grey.withOpacity(0.2)),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                DetailCargoCarInfo(cargoData: widget.cargo),
                const SizedBox(height: 16),
                Container(
                  width: 90,
                  height: 3,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.grey.withOpacity(0.2)),
                ),
                const SizedBox(height: 16),
                //DetailPricePage(cargo: widget.cargo),
                FullMultiPricePage(callType: '', cargoData: widget.cargo),
                const SizedBox(height: 8),
                fullCaution(dw),

                /*  const SizedBox(height: 16),
                Container(
                  width: 90,
                  height: 3,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.grey.withOpacity(0.2)),
                ),
                // _newBtnState(),
                const SizedBox(height: 16), */
                const SizedBox(height: 50),
                FullBtnState(
                  cargo: widget.cargo,
                  callType: '일반',
                ),
              ],
            ),
          ),
        ),
        if (widget.cargo['isShow'] == false)
          Positioned.fill(
              child: Container(
            color: msgBackColor.withOpacity(0.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_resetDialog(dw)],
            ),
          ))
      ],
    );
  }

/* 

  Widget _btnState(MapProvider mapProvider) {
    return widget.cargo['upTime'] == null
        ? const SizedBox()
        : widget.cargo['pickUserUid'] != null
            ? _btnPickUser(mapProvider)
            : Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Column(
                  children: [
                    if (isPassedDate(widget.cargo['upTime'].toDate()) == false)
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              cargoReset(context, widget.cargo['id'],
                                  widget.cargo['normalUid'], widget.cargo);
                            },
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: kOrangeAssetColor),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  KTextWidget(
                                      text: '운송 정보 수정',
                                      size: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              cargoDelete(context, widget.cargo['id'],
                                  widget.cargo['normalUid']);
                            },
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: kRedColor),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  KTextWidget(
                                      text: '운송 요청 취소',
                                      size: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              mapProvider.isLoadingState(true);

                              try {
                                final docRef = FirebaseFirestore.instance
                                    .collection('cargoLive')
                                    .doc(widget.cargo['id']);

                                final docSnapshot = await docRef.get();

                                if (docSnapshot.exists) {
                                  await docRef.delete();
                                  print('문서가 성공적으로 삭제되었습니다.');
                                } else {
                                  print('삭제할 문서가 존재하지 않습니다.');
                                }
                              } catch (e) {
                                print('문서 삭제 중 오류 발생: $e');
                              }

                              await deleteCargoWithSubcollections(
                                  widget.cargo['normalUid'],
                                  widget.cargo['id']);

                              await resetState(widget.cargo, context)
                                  .then((vlaue) {
                                if (vlaue == true) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => NewAddMainPage(
                                              callType: '재등록',
                                              cargo: widget.cargo,
                                            )),
                                  );
                                }
                              });

                              mapProvider.isLoadingState(false);
                            },
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: kGreenFontColor),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  KTextWidget(
                                      text: '운송 삭제 후 재등록',
                                      size: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              cargoDelete(context, widget.cargo['id'],
                                  widget.cargo['normalUid']);
                            },
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: kRedColor),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  KTextWidget(
                                      text: '운송 요청 삭제',
                                      size: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
  }




  Widget _btnPickUser(MapProvider mapProvider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {},
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: kOrangeAssetColor),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  KTextWidget(
                      text: '운송 정보 수정',
                      size: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {},
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), color: kRedColor),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  KTextWidget(
                      text: '운송 요청 취소',
                      size: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
 */
  Widget _resetDialog(double dw) {
    return Container(
      width: dw * 0.7,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), color: dialogColor),
      child: Column(
        children: [
          const SizedBox(height: 32),
          const Icon(Icons.info, color: kGreenFontColor, size: 60),
          const SizedBox(height: 32),
          const KTextWidget(
              text: '현재 정보 수정 상태입니다.',
              size: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white),
          const KTextWidget(
              text:
                  '기사 또는 전문 주선사에 노출되지 않는\n상태입니다. 정보 수정을 완료한 후,\n아래 버튼으로 상태를 활성하세요.',
              size: 14,
              textAlign: TextAlign.center,
              fontWeight: null,
              color: Colors.grey),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () async {
              HapticFeedback.lightImpact();
              await resetState(widget.cargo, context).then((value) {
                if (value == true) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NewAddMainPage(
                              callType: '수정',
                              cargo: widget.cargo,
                            )),
                  );
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.only(left: 10, right: 10),
              height: 47,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: kGreenFontColor),
              child: const Center(
                child: KTextWidget(
                    text: '운송 정보 활성',
                    size: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool> resetState(Map<String, dynamic> cargo, context) async {
  if (cargo['aloneType'] == '다구간' || cargo['aloneType'] == '왕복') {
    return await reSetReadyEtc(cargo, context);
  } else {
    return await reSetReady(cargo, context);
  }
}

/* Future<bool> reSetReady(Map<String, dynamic> cargoData, context) async {
  final addProvider = Provider.of<AddProvider>(context, listen: false);
  final hashProvider = Provider.of<HashProvider>(context, listen: false);

  try {
    addProvider.addMainTypeState(cargoData['transitType']);
    addProvider.addSubTypeState(cargoData['aloneType']);

    addProvider.cargoStateState(cargoData['cargoStat']);

    // 상차지
    addProvider.setLocationUpNamePhoneState(
        cargoData['upName'], cargoData['upPhone']);

    addProvider.addUpSenderTypeState(cargoData['upComType']);
    addProvider.setLocationCargoUpTypeState(cargoData['upType']);
    addProvider.setLocationUpNLatLngState(
        hashProvider.decLatLng(cargoData['upLocation']['geopoint']));
    addProvider.setLocationUpAddressState(
        cargoData['upAddress'], cargoData['upRoadAddress']);
    addProvider.setLocationUpDisState(cargoData['upAddressDis']);
    addProvider.setUpEtcState(cargoData['upEtc']);

    addProvider.setUpDateState(cargoData['upTime'].toDate());
    addProvider.setLocationUpTimeTypeState(cargoData['upTimeType']);
    addProvider.setUpTimeDoubleStartState(cargoData['upStart']);
    addProvider.setUpTimeDoubleEndState(cargoData['upEnd']);
    addProvider.setUpTimeAloneDateState(cargoData['upAloneType']);

    // 하차지

    addProvider.setLocationDownNamePhoneState(
        cargoData['downName'], cargoData['downPhone']);
    addProvider.addDownSenderTypeState(cargoData['downComType']);
    addProvider.setLocationCargoDownTypeState(cargoData['downType']);
    addProvider.setLocationDownNLatLngState(
        hashProvider.decLatLng(cargoData['downLocation']['geopoint']));
    addProvider.setLocationDownAddressState(
        cargoData['downAddress'], cargoData['downRoadAddress']);
    addProvider.setLocationDownDisState(cargoData['downAddressDis']);
    addProvider.setDownEtcState(cargoData['downEtc']);

    addProvider.setDownDateState(cargoData['downTime'].toDate());
    addProvider.setLocationDownTimeTypeState(cargoData['downTimeType']);
    addProvider.setDownTimeDoubleStartState(cargoData['downStart']);
    addProvider.setDownTimeDoubleEndState(cargoData['downEnd']);
    addProvider.setDownTimeAloneTypeState(cargoData['downAloneType']);

    addProvider.totalDistancedState(cargoData['allDis']);
    addProvider.totalDurationState(cargoData['allDur']);

    List<NLatLng> decryptedPath =
        await hashProvider.fastDecryptPath(cargoData['allRoute']);
    print(cargoData['carOption'].runtimeType);
    print(cargoData['carTon'].runtimeType);
    // 이제 동기 메서드에 반환값 전달
    addProvider.coordSet(decryptedPath);

    // 차량
    addProvider.cargoCategoryState(cargoData['cargoCategory']);

    addProvider.setCarTypeState(cargoData['carType']);
    // Convert List to String using join method
    addProvider.carOptionState(cargoData['carOption'].join(', '));

    addProvider.isWithState(cargoData['isWith']);

    if (cargoData['carTon'] is List) {
      for (var ton in cargoData['carTon']) {
        // String이면 숫자로 변환
        if (ton is String) {
          addProvider.setCarTonState(num.parse(ton));
        }
        // 이미 숫자면 그대로 사용
        else if (ton is num) {
          addProvider.setCarTonState(ton);
        }
      }
    }

    // 화물

    addProvider.addCargoInfoState(cargoData['cargoType']);
    addProvider.addCargoTonState(cargoData['cargoWe']);
    addProvider.addCargotonStringState(cargoData['cargoWeType']);
    addProvider.addCargoImgUrlState(cargoData['cargoPhotoUrl']);
    addProvider.addCargoEtcState(cargoData['cargoEtc']);
    addProvider.addCargoCbmState(cargoData['cbm']);

    addProvider.addCargoSizedState(
        cargoData['garo'], cargoData['sero'], cargoData['he']);

    // 결제

    String clientInfo = cargoData['clientInfo'] ?? '';

    String name = '';
    String phoneNumber = '';

// 정규식을 사용하여 '이름 / 전화번호' 패턴 추출
    RegExp pattern = RegExp(r'(.*?)\s*\/\s*(\d+)');
    Match? match = pattern.firstMatch(clientInfo);

    if (match != null && match.groupCount >= 2) {
      // 그룹 1은 이름, 그룹 2는 전화번호
      name = match.group(1) ?? '';
      phoneNumber = match.group(2) ?? '';
    } else {
      // 패턴에 맞지 않으면 전체를 이름으로 취급
      name = clientInfo;
    }

    addProvider.senderTypeState(cargoData['senderType']);
    /* addProvider.cliname
    addProvider.clientPhoneInfoState('sadasd'); */
    addProvider.isPriceTypeState(cargoData['norPayType']);
    if (cargoData['norPayHowto'] is List) {
      addProvider.payHowtoState(cargoData['norPayHowto']);
    } else if (cargoData['norPayHowto'] is String) {
      // 만약 문자열인 경우 (이전 버전 호환성을 위해)
      addProvider.payHowtoState(cargoData['norPayHowto']);
    }
    addProvider.isDoneRecState(cargoData['doneRec']);
    addProvider.isCashRecState(cargoData['cashRec']);
    addProvider.isNormalEtaxState(cargoData['normalEtax']);

    return true;
  } catch (e, stackTrace) {
    print('Error occurred: $e');
    print('Stack trace: $stackTrace');
    return false;
  }
} */

Future<bool> reSetReady(Map<String, dynamic> cargoData, context) async {
  final addProvider = Provider.of<AddProvider>(context, listen: false);
  final hashProvider = Provider.of<HashProvider>(context, listen: false);
  addProvider.allReset();
  try {
    addProvider.addMainTypeState(cargoData['transitType']);
    addProvider.addSubTypeState(cargoData['aloneType']);

    addProvider.cargoStateState(cargoData['cargoStat']);

    // 상차지
    addProvider.setLocationUpNamePhoneState(
        cargoData['upName'], cargoData['upPhone']);

    addProvider.addUpSenderTypeState(cargoData['upComType']);
    addProvider.setLocationCargoUpTypeState(cargoData['upType']);

    addProvider.setLocationUpNLatLngState(
        hashProvider.decLatLng(cargoData['upLocation']['geopoint']));

    addProvider.setLocationUpAddressState(
        cargoData['upAddress'], cargoData['upRoadAddress']);
    addProvider.setLocationUpDisState(cargoData['upAddressDis']);
    addProvider.setUpEtcState(cargoData['upEtc']);

    addProvider.setUpDateState(cargoData['upTime'].toDate());

    addProvider.setLocationUpTimeTypeState(cargoData['upTimeType']);
    addProvider.setUpTimeDoubleStartState(cargoData['upStart']);
    addProvider.setUpTimeDoubleEndState(cargoData['upEnd']);
    addProvider.setUpTimeAloneTypeState(cargoData['upAloneType']);

    // 하차지
    addProvider.setLocationDownNamePhoneState(
        cargoData['downName'], cargoData['downPhone']);
    addProvider.addDownSenderTypeState(cargoData['downComType']);
    addProvider.setLocationCargoDownTypeState(cargoData['downType']);

    addProvider.setLocationDownNLatLngState(
        hashProvider.decLatLng(cargoData['downLocation']['geopoint']));

    addProvider.setLocationDownAddressState(
        cargoData['downAddress'], cargoData['downRoadAddress']);
    addProvider.setLocationDownDisState(cargoData['downAddressDis']);
    addProvider.setDownEtcState(cargoData['downEtc']);

    addProvider.setDownDateState(cargoData['downTime'].toDate());
    addProvider.setDownTimeEtcState(cargoData['downTimeEtc']);
    addProvider.setUpTimeEtcState(cargoData['upTimeEtc']);

    addProvider.setLocationDownTimeTypeState(cargoData['downTimeType']);
    addProvider.setDownTimeDoubleStartState(cargoData['downStart']);
    addProvider.setDownTimeDoubleEndState(cargoData['downEnd']);
    addProvider.setDownTimeAloneTypeState(cargoData['downAloneType']);

    addProvider.totalDistancedState(cargoData['allDis']);
    addProvider.totalDurationState(cargoData['allDur']);

    List<NLatLng> decryptedPath =
        await hashProvider.fastDecryptPath(cargoData['allRoute']);

    // 이제 동기 메서드에 반환값 전달
    addProvider.coordSet(decryptedPath);

    // 차량
    addProvider.cargoCategoryState(cargoData['cargoCategory']);
    addProvider.setCarTypeState(cargoData['carType']);

    // Convert List to String using join method
    addProvider.carOptionState(cargoData['carOption'].join(', '));

    addProvider.isWithState(cargoData['isWith']);

    if (cargoData['carTon'] is List) {
      print('carTon 처리 시작, 현재 저장된 값: ${addProvider.setCarTon}');

      for (var ton in cargoData['carTon']) {
        // String이면 숫자로 변환
        if (ton is String) {
          print('String 값 처리: $ton');
          num parsedTon = num.parse(ton);
          print('변환된 값: $parsedTon, 호출 전 상태: ${addProvider.setCarTon}');
          addProvider.setCarTonState(parsedTon);
          print('호출 후 상태: ${addProvider.setCarTon}');
        }
        // 이미 숫자면 그대로 사용
        else if (ton is num) {
          print('숫자 값 처리: $ton, 호출 전 상태: ${addProvider.setCarTon}');
          addProvider.setCarTonState(ton);
          print('호출 후 상태: ${addProvider.setCarTon}');
        }
      }

      print('carTon 처리 완료, 최종 상태: ${addProvider.setCarTon}');
    }

    double? cargoWeValue;

    if (cargoData['cargoWe'] != null) {
      try {
        if (cargoData['cargoWe'] is int) {
          cargoWeValue = (cargoData['cargoWe'] as int).toDouble();
        } else if (cargoData['cargoWe'] is double) {
          cargoWeValue = cargoData['cargoWe'] as double;
        } else {
          // String이나 다른 타입인 경우
          cargoWeValue =
              double.tryParse(cargoData['cargoWe'].toString()) ?? 0.0;
        }

        // 변환된 값을 저장
        addProvider.addCargoTonState(cargoWeValue);
        print('cargoWe 변환 성공: $cargoWeValue (원래 값: ${cargoData['cargoWe']})');
      } catch (e) {
        print('cargoWe 처리 중 예외 발생: $e');
        addProvider.addCargoTonState(0.0);
      }
    } else {
      print('cargoWe 값이 null입니다');
      addProvider.addCargoTonState(0.0);
    }
    addProvider.addCargotonStringState(cargoData['cargoWeType']);
    addProvider.addCargoImgUrlState(cargoData['cargoPhotoUrl']);
    addProvider.addCargoEtcState(cargoData['cargoEtc']);
// cbm 처리
    if (cargoData['cbm'] != null) {
      try {
        if (cargoData['cbm'] is int) {
          addProvider.addCargoCbmState((cargoData['cbm'] as int).toDouble());
        } else if (cargoData['cbm'] is double) {
          addProvider.addCargoCbmState(cargoData['cbm'] as double);
        } else {
          addProvider.addCargoCbmState(
              double.tryParse(cargoData['cbm'].toString()) ?? 0.0);
        }
        print('cbm 변환 성공: ${cargoData['cbm']}');
      } catch (e) {
        print('cbm 처리 중 예외 발생: $e');
        addProvider.addCargoCbmState(0.0);
      }
    } else {
      addProvider.addCargoCbmState(0.0);
    }
    addProvider.addCargoInfoState(cargoData['cargoType']);
// garo, sero, he 처리
    double? garo = null;
    double? sero = null;
    double? he = null;

// garo 변환
    if (cargoData['garo'] != null) {
      if (cargoData['garo'] is int) {
        garo = (cargoData['garo'] as int).toDouble();
      } else if (cargoData['garo'] is double) {
        garo = cargoData['garo'] as double;
      } else {
        garo = double.tryParse(cargoData['garo'].toString()) ?? 0.0;
      }
    }

// sero 변환
    if (cargoData['sero'] != null) {
      if (cargoData['sero'] is int) {
        sero = (cargoData['sero'] as int).toDouble();
      } else if (cargoData['sero'] is double) {
        sero = cargoData['sero'] as double;
      } else {
        sero = double.tryParse(cargoData['sero'].toString()) ?? 0.0;
      }
    }

// he 변환
    if (cargoData['he'] != null) {
      if (cargoData['he'] is int) {
        he = (cargoData['he'] as int).toDouble();
      } else if (cargoData['he'] is double) {
        he = cargoData['he'] as double;
      } else {
        he = double.tryParse(cargoData['he'].toString()) ?? 0.0;
      }
    }

    // 결제
    String clientInfo = cargoData['clientInfo'] ?? '';
    print('clientInfo: $clientInfo');

    String name = '';
    String phoneNumber = '';

    // 정규식을 사용하여 '이름 / 전화번호' 패턴 추출
    RegExp pattern = RegExp(r'(.*?)\s*\/\s*(\d+)');
    Match? match = pattern.firstMatch(clientInfo);

    if (match != null && match.groupCount >= 2) {
      // 그룹 1은 이름, 그룹 2는 전화번호
      name = match.group(1) ?? '';
      phoneNumber = match.group(2) ?? '';
    } else {
      // 패턴에 맞지 않으면 전체를 이름으로 취급
      name = clientInfo;
    }

    addProvider.senderTypeState(cargoData['senderType']);

    /* addProvider.cliname
    addProvider.clientPhoneInfoState('sadasd'); */

    addProvider.isPriceTypeState(cargoData['norPayType']);

    try {
      if (cargoData['norPayHowto'] is List) {
        List<dynamic> payHowtoList = cargoData['norPayHowto'];

        // 리스트 전체를 처리하는 메서드가 있다고 가정
        // addProvider.setPayHowtoListState(payHowtoList.map((item) => item.toString()).toList());

        // 위 메서드가 없다면 각 값을 개별적으로 처리
        for (var payMethod in payHowtoList) {
          String payMethodStr = payMethod.toString();

          addProvider.payHowtoState(payMethodStr);
          // 마지막 값만 유지되는 문제가 있을 수 있음
        }

        // 또는 모든 값을 하나의 문자열로 합쳐서 처리
        // String combinedPayHowto = payHowtoList.join(', ');
        // addProvider.payHowtoState(combinedPayHowto);
      } else if (cargoData['norPayHowto'] is String) {
        addProvider.payHowtoState(cargoData['norPayHowto']);
      } else {
        addProvider.payHowtoState('');
      }
    } catch (e) {
      print('payHowto 처리 중 오류: $e');
      addProvider.payHowtoState('');
    }
    addProvider.isDoneRecState(cargoData['doneRec']);
    addProvider.isCashRecState(cargoData['cashRec']);
    addProvider.isNormalEtaxState(cargoData['normalEtax']);

    print('9. 결제 정보 설정 완료');

    print('디버깅 완료: reSetReady 함수 성공');
    return true;
  } catch (e, stackTrace) {
    print('오류 발생: $e');
    print('스택 추적: $stackTrace');
    return false;
  }
}

Future<bool> reSetReadyEtc(Map<String, dynamic> cargo, context) async {
  final addProvider = Provider.of<AddProvider>(context, listen: false);
  final hashProvider = Provider.of<HashProvider>(context, listen: false);

  try {
    addProvider.clearLocations();
    // carTon 처리
    List<dynamic> carTonList = cargo['carTon'];
    addProvider.setCarTon.clear(); // 기존 데이터 초기화
    for (var ton in carTonList) {
      addProvider.setCarTonState(ton.toDouble());
    }

// carOption 처리
    List<dynamic> carOptionList = cargo['carOption'];
    addProvider.carOption.clear(); // 기존 데이터 초기화
    for (var option in carOptionList) {
      addProvider.carOptionState(option.toString());
    }
    addProvider.setIsBlindState(cargo['isBlind']);
    //addProvider.isBidng (widget.cargo['isBiding']);
    addProvider.setCarTypeState(cargo['carType']);

    // 상차 정보
    addProvider.setLocationUpNamePhoneState(cargo['upName'], cargo['upPhone']);
    addProvider.setLocationUpAddressState(
        cargo['upAddress'], cargo['upRoadAddress']);
    addProvider.setLocationUpDisState(cargo['upAddressDis']);
    addProvider.setUpDateState(cargo['upTime']?.toDate());
    addProvider.setLocationUpTimeTypeState(cargo['upTimeType']);
    addProvider.setUpTimeDoubleStartState(cargo['upStart']?.toDate());
    addProvider.setUpTimeDoubleEndState(cargo['upEnd']?.toDate());
    addProvider.setUpEtcState(cargo['upEtc']);
    addProvider.setLocationCargoUpTypeState(cargo['upType']);

    // 하차 정보
    addProvider.setLocationDownNamePhoneState(
        cargo['downName'], cargo['downPhone']);
    addProvider.setLocationDownAddressState(
        cargo['downAddress'], cargo['downRoadAddress']);
    addProvider.setLocationDownDisState(cargo['downAddressDis']);
    addProvider.setDownDateState(cargo['downTime']?.toDate());
    addProvider.setLocationDownTimeTypeState(cargo['downTimeType']);
    addProvider.setDownTimeDoubleStartState(cargo['downStart']?.toDate());
    addProvider.setDownTimeDoubleEndState(cargo['downEnd']?.toDate());
    addProvider.setDownEtcState(cargo['downEtc']);
    addProvider.setLocationCargoDownTypeState(cargo['downType']);
    addProvider.setDownTimeEtcState(cargo['downTimeEtc']);
    addProvider.setUpTimeEtcState(cargo['upTimeEtc']);
    // 화물 정보
    final List<NLatLng> decryptedPath =
        await hashProvider.fastDecryptPath(cargo['allRoute']);

    addProvider.disDur(cargo['allDis'], cargo['allDur']);
    addProvider.coordSet(decryptedPath);

    addProvider.isTmmState(cargo['isDownTmm']);
    addProvider.isWithState(cargo['isWith']);
    addProvider.cargoCategoryState(cargo['cargoCategory']);

    addProvider.addSubTypeState(cargo['transitType']);
    addProvider.addMainTypeState(cargo['aloneType']);

    addProvider.isPriceTypeState(cargo['norPayType']);
    List<dynamic> payHowtoList = cargo['norPayHowto'];
    for (var howto in payHowtoList) {
      addProvider.payHowtoState(howto.toString());
    }
    addProvider.resetImgUrlState(cargo['cargoPhotoUrl']);
    addProvider.isNormalEtaxState(cargo['normalEtax']);
    addProvider.isDoneRecState(cargo['doneRec']);
    addProvider.isCashRecState(cargo['cashRec']);
    addProvider.senderTypeState(cargo['senderType']);

    List<dynamic> rawLocations = cargo['locations'] as List;
    rawLocations.forEach((locationData) {
      print('위치 처리 중: ${locationData['type']}');
      // location 필드만 복호화
      NLatLng decryptedLocation =
          hashProvider.decLatLng(locationData['location'].toString());

      // downCargos와 upCargos를 CargoInfo 리스트로 변환
      List<CargoInfo> downCargosList = (locationData['downCargos'] as List?)
              ?.map((cargo) => CargoInfo.fromMap(cargo as Map<String, dynamic>))
              ?.toList() ??
          [];

      List<CargoInfo> upCargosList = (locationData['upCargos'] as List?)
              ?.map((cargo) => CargoInfo.fromMap(cargo as Map<String, dynamic>))
              ?.toList() ??
          [];

      CargoLocation cargoLocation = CargoLocation(
        type: locationData['type'],
        address1: locationData['address1'],
        address2: locationData['address2'],
        addressDis: locationData['addressDis'],
        location: decryptedLocation,
        howTo: locationData['howTo'],
        senderType: locationData['senderType'],
        senderName: locationData['senderName'],
        senderPhone: locationData['senderPhone'],
        dateType: locationData['dateType'],
        dateAloneString: locationData['dateAloneString'],
        dateStart: locationData['dateStart']?.toDate(),
        dateEnd: locationData['dateEnd']?.toDate(),
        date: locationData['date']?.toDate(),
        etc: locationData['etc'],
        becareful: locationData['becareful'],
        isDone: locationData['isDone'],
        isDoneTime: locationData['isDoneTime']?.toDate(),
        downCargos: downCargosList,
        upCargos: upCargosList,
      );

      addProvider.addLocation(cargoLocation);
      print('위치 추가 후 locations 길이: ${addProvider.locations.length}');
    });

    print('rawLocations 길이: ${rawLocations.length}');

    return true;
  } catch (e, stackTrace) {
    print('Error occurred: $e');
    print('Stack trace: $stackTrace');
    return false;
  }
}

Widget fullCaution(double dw) {
  return Padding(
    padding: const EdgeInsets.only(left: 8, right: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.info, color: Colors.grey.withOpacity(0.5), size: 12),
            const SizedBox(width: 5),
            KTextWidget(
                text: '운송 정보를 다시 한번 확인하세요.',
                size: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey.withOpacity(0.5)),
          ],
        ),
        Row(
          children: [
            Icon(Icons.info, color: Colors.grey.withOpacity(0.5), size: 12),
            const SizedBox(width: 5),
            SizedBox(
              width: dw - 49,
              child: KTextWidget(
                  text: '운송 정보 오류로 발생되는 문재의 책임은 본인에게 있습니다.',
                  size: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.withOpacity(0.5)),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                const SizedBox(height: 3),
                Icon(Icons.info, color: Colors.grey.withOpacity(0.5), size: 12),
              ],
            ),
            const SizedBox(width: 5),
            SizedBox(
              width: dw - 49,
              child: KTextWidget(
                  text:
                      '혼적콜은 화물 정보를 제공할뿐, 운송 위탁 과정에 참여하지 않습니다. 따라서, 운송료를 책정하는 등의 과정이나 화물의 상태 및 운송을 책임지지 않습니다.',
                  size: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.withOpacity(0.5)),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                const SizedBox(height: 3),
                Icon(Icons.info, color: Colors.grey.withOpacity(0.5), size: 12),
              ],
            ),
            const SizedBox(width: 5),
            SizedBox(
              width: dw - 49,
              child: KTextWidget(
                  text:
                      '혼적콜을 통한 화물 운송 위탁은 고객과 기사 또는 주선사의 직접 위탁으로, 혼적콜은 이과정에서 고객, 기사 또는 주선사로부터 일체의 금액(수수료)을 요구하지 않습니다. 만약, 수수료 등을 요구하는 경우가 있다면 032-227-1107로 문의해주세요.',
                  size: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.withOpacity(0.5)),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                const SizedBox(height: 3),
                Icon(Icons.info, color: Colors.grey.withOpacity(0.5), size: 12),
              ],
            ),
            const SizedBox(width: 5),
            SizedBox(
              width: dw - 49,
              child: KTextWidget(
                  text:
                      '단, 혼적콜을 이용하며 발생된 문제의 해결에 있어 해당 운송건의 전자적 자료가 필요한 경우 요청에 따라 정보를 제공합니다.',
                  size: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.withOpacity(0.5)),
            ),
          ],
        ),
      ],
    ),
  );
}
