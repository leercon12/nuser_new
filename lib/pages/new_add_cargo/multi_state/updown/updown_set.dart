import 'dart:io';

import 'package:delayed_widget/delayed_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/model/multi_cargo_add_model.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/multi_state/updown/cargo_dialog/multi_cargo.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/multi_state/updown/cargo_dialog/multi_down.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/multi_state/updown/updown_cargo_add/up_cargo_add.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/normal_state/up_down/set_page/address.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/search/search_main.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/service/pick_image_service.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/add_cargo_date.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';

class MultiUpDownSetPage extends StatefulWidget {
  final int? no;
  final String callType;
  final CargoLocation? cargo;
  final bool isMidUpdate;
  const MultiUpDownSetPage(
      {super.key,
      required this.callType,
      this.no,
      this.cargo,
      required this.isMidUpdate});

  @override
  State<MultiUpDownSetPage> createState() => _MultiUpDownSetPageState();
}

class _MultiUpDownSetPageState extends State<MultiUpDownSetPage> {
  bool isUpDown = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addProvider = Provider.of<AddProvider>(context, listen: false);
      isUpDown = widget.callType.contains('상차');
      addProvider.clearCargos();
      if (widget.cargo != null) {
        if (isUpDown) {
          _senderText.text = widget.cargo!.senderName.toString();
          _phoneText.text = widget.cargo!.senderPhone.toString();
          _multiText.text = widget.cargo!.becareful.toString();

          addProvider.addUpSenderTypeState(widget.cargo!.senderType);
          addProvider.setLocationUpAddressState(
              widget.cargo!.address1, widget.cargo!.address2);
          addProvider.setLocationUpDisState(widget.cargo!.addressDis);
          addProvider.setLocationUpNLatLngState(widget.cargo!.location);
          addProvider.setLocationCargoUpTypeState(widget.cargo!.howTo);
          addProvider.setUpCargos(widget.cargo!.upCargos);
          addProvider.setDownCargos(widget.cargo!.downCargos);

          addProvider.setLocationUpTimeTypeState(widget.cargo!.dateType);
          addProvider.setUpTimeAloneDateState(widget.cargo!.dateStart);
          addProvider.setUpTimeDoubleStartState(widget.cargo!.dateStart);
          addProvider.setUpTimeDoubleEndState(widget.cargo!.dateStart);
          addProvider.setUpTimeAloneTypeState(widget.cargo!.dateAloneString);
          addProvider.setUpDateState(widget.cargo!.date);

          addProvider.setUpTimeEtcState(widget.cargo!.etc);
        } else {
          _senderText.text = widget.cargo!.senderName.toString();
          _phoneText.text = widget.cargo!.senderPhone.toString();
          _multiText.text = widget.cargo!.becareful.toString();

          addProvider.addDownSenderTypeState(widget.cargo!.senderType);
          addProvider.setLocationDownAddressState(
              widget.cargo!.address1, widget.cargo!.address2);
          addProvider.setLocationDownDisState(widget.cargo!.addressDis);
          addProvider.setLocationDownNLatLngState(widget.cargo!.location);
          addProvider.setLocationCargoDownTypeState(widget.cargo!.howTo);
          addProvider.setUpCargos(widget.cargo!.upCargos);
          addProvider.setDownCargos(widget.cargo!.downCargos);

          addProvider.setLocationDownTimeTypeState(widget.cargo!.dateType);
          addProvider.setDownTimeAloneDateState(widget.cargo!.dateStart);
          addProvider.setDownTimeDoubleStartState(widget.cargo!.dateStart);
          addProvider.setDownTimeDoubleEndState(widget.cargo!.dateStart);
          addProvider.setDownTimeAloneTypeState(widget.cargo!.dateAloneString);
          addProvider.setDownDateState(widget.cargo!.date);

          addProvider.setDownTimeEtcState(widget.cargo!.etc);
        }

        _input = _senderText.text.length;
        _inputPhone = _phoneText.text.length;

        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _senderText.dispose();
    _phoneText.dispose();
    _addressDis.dispose();
    _searchText.dispose();
    _multiText.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final addProvider = Provider.of<AddProvider>(context);
    bool _isDone = isUpDown
        ? addProvider.setLocationCargoUpType != null &&
            _inputPhone > 0 &&
            _input > 0 &&
            addProvider.setLocationUpAddress1 != null &&
            addProvider.setUpDate != null &&
            addProvider.addUpSenderType != null &&
            addProvider.cargoCategory != null
        : addProvider.setLocationCargoDownType != null &&
            _inputPhone > 0 &&
            _input > 0 &&
            addProvider.setLocationDownAddress1 != null &&
            addProvider.setDownDate != null &&
            addProvider.cargoCategory != null &&
            addProvider.addDownSenderType != null;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            widget.callType.contains('회차')
                ? '경유지 등록'
                : widget.callType.contains('상차')
                    ? '상차지 등록'
                    : '하차지 등록',
            style: const TextStyle(fontSize: 20),
          ),
          actions: [
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchMainPage(
                      callType: '주소',
                      type: widget.callType,
                    ),
                  ),
                );

                // 결과 데이터가 있으면 TextController에 설정
                if (result != null) {
                  setState(() {
                    _senderText.text = result['name'] ?? '';
                    _phoneText.text = result['phone'] ?? '';
                    _addressDis.text = result['addressDis'] ?? '';

                    _input = _senderText.text.length;
                    _inputPhone = _phoneText.text.length;
                  });
                }
              },
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                child: const KTextWidget(
                    text: '검색',
                    size: 14,
                    fontWeight: FontWeight.bold,
                    color: kOrangeBssetColor),
              ),
            ),
          ],
        ),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(children: [
                    _placeType(addProvider),
                    _senderInfo(addProvider),
                    _addressInfo(addProvider),
                    _cargoDate(addProvider),
                    _cargoSelType(addProvider),
                    /*  if (!isUpDown) _downCargo(addProvider),
                    _cargoSet(addProvider), */
                    MultiUpDownAddCargo(
                      callType: widget.callType.contains('회차')
                          ? '하차'
                          : widget.callType,
                      no: widget.no,
                    ),
                    _multiEtc(addProvider),
                    _caution(),
                    const SizedBox(height: 250),
                  ]),
                ),
              ),
              if (_isDone) _btnMain(addProvider)
            ],
          ),
        )),
      ),
    );
  }

  Widget _caution() {
    final dw = MediaQuery.of(context).size.width;
    return SizedBox(
      width: dw,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 32),
          Row(
            children: [
              Icon(
                Icons.info,
                size: 14,
                color: Colors.grey,
              ),
              SizedBox(width: 5),
              KTextWidget(
                  text: '입력한 정보를 꼭 다시 확인하세요.',
                  size: 13,
                  fontWeight: null,
                  color: Colors.grey),
            ],
          ),
          Row(
            children: [
              Icon(
                Icons.info,
                size: 14,
                color: Colors.grey,
              ),
              SizedBox(width: 5),
              KTextWidget(
                  text: '잘못된 정보로 인한 문제는 혼적콜이 책임지지 않습니다.',
                  size: 13,
                  fontWeight: null,
                  color: Colors.grey),
            ],
          ),
          Row(
            children: [
              Icon(
                Icons.info,
                size: 14,
                color: Colors.grey,
              ),
              SizedBox(width: 5),
              KTextWidget(
                  text: '상, 하차 시간 정보가 상세할 수록 제안 가능성이 높아집니다.',
                  size: 13,
                  fontWeight: null,
                  color: Colors.grey),
            ],
          )
        ],
      ),
    );
  }

  Widget _btnMain(AddProvider addProvider) {
    return DelayedWidget(
      animation: DelayedAnimations.SLIDE_FROM_BOTTOM,
      animationDuration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: () async {
          if (widget.callType.contains('왕복')) {
            print(widget.callType);
            print(widget.no);
            if (widget.callType.contains('상차')) {
              if (addProvider.downCargos.isEmpty)
                await _returnFirst(addProvider);
              addProvider.clearCargos();
              Navigator.pop(context);
            } else if (widget.callType.contains('회차')) {
              await _returnSec(addProvider);
              addProvider.clearCargos();
              Navigator.pop(context);
            } else {
              if (addProvider.downCargos.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    errorSnackBar('하차지에 하차할 화물이 등록되지 않았습니다.', context));
              } else {
                await _returnThri(addProvider);
                addProvider.clearCargos();
                Navigator.pop(context);
              }
            }
          } else {
            if (widget.callType.contains('다구간_수정')) {
              if (widget.callType.contains('상차')) {
                await _multiReSet(addProvider);
                addProvider.clearCargos();
                Navigator.pop(context);
              } else {
                if (addProvider.downCargos.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      errorSnackBar('하차지에 하차할 화물이 등록되지 않았습니다.', context));
                } else {
                  await _multiReSet(addProvider);
                  addProvider.clearCargos();
                  Navigator.pop(context);
                }
              }

              addProvider.clearCargos();
            } else if (widget.callType.contains('다구간')) {
              if (widget.callType.contains('상차')) {
                await _multiAdd(addProvider);
                addProvider.clearCargos();
                Navigator.pop(context);
              } else {
                if (addProvider.downCargos.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      errorSnackBar('하차지에 하차할 화물이 등록되지 않았습니다.', context));
                } else {
                  await _multiAdd(addProvider);
                  addProvider.clearCargos();
                  Navigator.pop(context);
                }
              }
            }
          }
        },
        child: Container(
          height: 56,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12), color: kGreenFontColor),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KTextWidget(
                  text: isUpDown
                      ? '상차 정보 등록'
                      : widget.callType.contains('하차')
                          ? '하차 정보 등록'
                          : '경유지 정보 등록',
                  size: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)
            ],
          ),
        ),
      ),
    );
  }

  Future _multiReSet(AddProvider addProvider) async {
    if (widget.callType.contains('상차')) {
      print('@@@@@@@@@@@@@@@');
      addProvider.updateLocation(
        widget.no as int,
        type: '상차',
        address1: addProvider.setLocationUpAddress1.toString(),
        address2: addProvider.setLocationUpAddress2.toString(),
        addressDis: _addressDis.text.trim(),
        location: addProvider.setLocationUpNLatLng as NLatLng,
        howTo: addProvider.setLocationCargoUpType.toString(),
        senderType: addProvider.addUpSenderType ?? [],
        senderName: _senderText.text.trim(),
        snederPhone: _phoneText.text.trim(),
        dateType: addProvider.setUpTimeType.toString(),
        date: addProvider.setUpDate as DateTime,
        dateAloneString: addProvider.setUpTimeAloneType.toString(),
        dateStart: addProvider.setUpDateDoubleStart,
        dateEnd: addProvider.setUpDateDoubleEnd,
        etc: addProvider.setUpTimeEtc.toString(),
        becareful: _multiText.text.trim(),
        upCargos: List<CargoInfo>.from(addProvider.upCargos),
        downCargos: List<CargoInfo>.from(addProvider.downCargos),
      );
      addProvider.clearCargos();
    } else {
      addProvider.updateLocation(
        widget.no as int,
        type: '하차',
        address1: addProvider.setLocationDownAddress1.toString(),
        address2: addProvider.setLocationDownAddress2.toString(),
        addressDis: _addressDis.text.trim(),
        location: addProvider.setLocationDownNLatLng as NLatLng,
        howTo: addProvider.setLocationCargoDownType.toString(),
        senderType: addProvider.addDownSenderType ?? [],
        senderName: _senderText.text.trim(),
        snederPhone: _phoneText.text.trim(),
        dateType: addProvider.setDownTimeType.toString(),
        date: addProvider.setDownDate as DateTime,
        dateAloneString: addProvider.setDownTimeAloneType.toString(),
        dateStart: addProvider.setDownDateDoubleStart,
        dateEnd: addProvider.setDownDateDoubleEnd,
        etc: addProvider.setDownTimeEtc.toString(),
        becareful: _multiText.text.trim(),
        upCargos: List<CargoInfo>.from(addProvider.upCargos),
        downCargos: List<CargoInfo>.from(addProvider.downCargos),
      );
      addProvider.clearCargos();
    }
  }

  Future _multiAdd(AddProvider addProvider) async {
    if (widget.callType.contains('상차')) {
      print(addProvider.upCargos.length);
      if (widget.isMidUpdate == true) {
        addProvider.insertLocation(
            addProvider.locationsIndex! + 1,
            CargoLocation(
              type: '상차',
              address1: addProvider.setLocationUpAddress1,
              address2: addProvider.setLocationUpAddress2,
              addressDis: _addressDis.text.trim(),
              location: addProvider.setLocationUpNLatLng,
              howTo: addProvider.setLocationCargoUpType,
              senderType: addProvider.addUpSenderType,
              senderName: _senderText.text.trim(),
              senderPhone: _phoneText.text.trim(),
              dateType: addProvider.setUpTimeType,
              date: addProvider.setUpDate,
              dateAloneString: addProvider.setUpTimeAloneType,
              dateStart: addProvider.setUpDateDoubleStart,
              dateEnd: addProvider.setUpDateDoubleEnd,
              etc: addProvider.setUpTimeEtc,
              becareful: _multiText.text.trim(),
              upCargos: List<CargoInfo>.from(addProvider.upCargos),
              downCargos: List<CargoInfo>.from(addProvider.downCargos),
            ));
      } else {
        addProvider.addLocation(CargoLocation(
          type: '상차',
          address1: addProvider.setLocationUpAddress1,
          address2: addProvider.setLocationUpAddress2,
          addressDis: _addressDis.text.trim(),
          location: addProvider.setLocationUpNLatLng,
          howTo: addProvider.setLocationCargoUpType,
          senderType: addProvider.addUpSenderType,
          senderName: _senderText.text.trim(),
          senderPhone: _phoneText.text.trim(),
          dateType: addProvider.setUpTimeType,
          date: addProvider.setUpDate,
          dateAloneString: addProvider.setUpTimeAloneType,
          dateStart: addProvider.setUpDateDoubleStart,
          dateEnd: addProvider.setUpDateDoubleEnd,
          etc: addProvider.setUpTimeEtc,
          becareful: _multiText.text.trim(),
          upCargos: List<CargoInfo>.from(addProvider.upCargos),
          downCargos: List<CargoInfo>.from(addProvider.downCargos),
        ));
      }

      addProvider.clearCargos();
    } else {
      if (widget.isMidUpdate == true) {
        addProvider.insertLocation(
            addProvider.locationsIndex! + 1,
            CargoLocation(
              type: '하차',
              address1: addProvider.setLocationDownAddress1,
              address2: addProvider.setLocationDownAddress2,
              addressDis: _addressDis.text.trim(),
              location: addProvider.setLocationDownNLatLng,
              howTo: addProvider.setLocationCargoDownType,
              senderType: addProvider.addDownSenderType,
              senderName: _senderText.text.trim(),
              senderPhone: _phoneText.text.trim(),
              dateType: addProvider.setDownTimeType,
              date: addProvider.setDownDate,
              dateAloneString: addProvider.setDownTimeAloneType,
              dateStart: addProvider.setDownDateDoubleStart,
              dateEnd: addProvider.setDownDateDoubleEnd,
              etc: addProvider.setDownTimeEtc,
              becareful: _multiText.text.trim(),
              upCargos: List<CargoInfo>.from(addProvider.upCargos),
              downCargos: List<CargoInfo>.from(addProvider.downCargos),
            ));
      } else {
        addProvider.addLocation(CargoLocation(
          type: '하차',
          address1: addProvider.setLocationDownAddress1,
          address2: addProvider.setLocationDownAddress2,
          addressDis: _addressDis.text.trim(),
          location: addProvider.setLocationDownNLatLng,
          howTo: addProvider.setLocationCargoDownType,
          senderType: addProvider.addDownSenderType,
          senderName: _senderText.text.trim(),
          senderPhone: _phoneText.text.trim(),
          dateType: addProvider.setDownTimeType,
          date: addProvider.setDownDate,
          dateAloneString: addProvider.setDownTimeAloneType,
          dateStart: addProvider.setDownDateDoubleStart,
          dateEnd: addProvider.setDownDateDoubleEnd,
          etc: addProvider.setDownTimeEtc,
          becareful: _multiText.text.trim(),
          upCargos: List<CargoInfo>.from(addProvider.upCargos),
          downCargos: List<CargoInfo>.from(addProvider.downCargos),
        ));
      }

      addProvider.clearCargos();
    }
  }

  Future _returnFirst(AddProvider addProvider) async {
    // 상차 정보 생성
    final newLocation = CargoLocation(
      type: '상차',
      address1: addProvider.setLocationUpAddress1,
      address2: addProvider.setLocationUpAddress2,
      addressDis: _addressDis.text.trim(),
      location: addProvider.setLocationUpNLatLng,
      howTo: addProvider.setLocationCargoUpType,
      senderType: addProvider.addUpSenderType,
      senderName: _senderText.text.trim(),
      senderPhone: _phoneText.text.trim(),
      dateType: addProvider.setUpTimeType,
      date: addProvider.setUpDate,
      dateAloneString: addProvider.setUpTimeAloneType,
      dateStart: addProvider.setUpDateDoubleStart,
      dateEnd: addProvider.setUpDateDoubleEnd,
      etc: addProvider.setUpTimeEtc,
      becareful: _multiText.text.trim(),
      upCargos: List<CargoInfo>.from(addProvider.upCargos),
      downCargos: List<CargoInfo>.from(addProvider.downCargos),
    );

    // 회차 정보 생성
    final returnLocation = CargoLocation(
      type: '하차',
      address1: addProvider.setLocationUpAddress1,
      address2: addProvider.setLocationUpAddress2,
      addressDis: _addressDis.text.trim(),
      location: addProvider.setLocationUpNLatLng,
      howTo: addProvider.setLocationCargoUpType,
      senderType: addProvider.addUpSenderType,
      senderName: _senderText.text.trim(),
      senderPhone: _phoneText.text.trim(),
      dateType: addProvider.locations.length > 2
          ? (addProvider.locations[2].dateType ?? newLocation.dateType)
          : newLocation.dateType,
      date: addProvider.locations.length > 2
          ? (addProvider.locations[2].date ?? newLocation.date)
          : newLocation.date,
      dateAloneString: addProvider.locations.length > 2
          ? (addProvider.locations[2].dateAloneString ??
              newLocation.dateAloneString)
          : newLocation.dateAloneString,
      dateStart: addProvider.locations.length > 2
          ? (addProvider.locations[2].dateStart ?? newLocation.dateStart)
          : newLocation.dateStart,
      dateEnd: addProvider.locations.length > 2
          ? (addProvider.locations[2].dateEnd ?? newLocation.dateEnd)
          : newLocation.dateEnd,
      etc: addProvider.locations.length > 2
          ? (addProvider.locations[2].etc ?? newLocation.etc)
          : newLocation.etc,
      becareful: addProvider.locations.length > 2
          ? (addProvider.locations[2].becareful ?? newLocation.becareful)
          : newLocation.becareful,
      upCargos: null,
      downCargos: addProvider.locations.length > 2 &&
              addProvider.locations[2].downCargos?.isNotEmpty == true
          ? addProvider.locations[2].downCargos
          : null,
    );

    final downLocation = CargoLocation(
      type: '하차',
      address1: null,
      address2: null,
      addressDis: null,
      location: null,
      howTo: null,
      senderType: null,
      senderName: null,
      senderPhone: null,
      dateType: null,
      date: DateTime.now(),
      dateAloneString: null,
      dateStart: null,
      dateEnd: null,
      etc: null,
      becareful: null,
      upCargos: null,
      downCargos: null,
    );

    // locations가 비어있으면 추가, 있으면 업데이트
    if (addProvider.locations.isEmpty) {
      // 처음 생성 시
      addProvider.addLocation(newLocation); // 상차 정보
      addProvider.addLocation(downLocation); // 빈 하차 정보
      addProvider.addLocation(returnLocation); // 회차 정보

      for (int i = 0; i < addProvider.locations.length; i++) {
        final location = addProvider.locations[i];

        if (location.upCargos.isNotEmpty || location.downCargos.isNotEmpty) {
          // upCargos가 있는 경우
          for (var j = 0; j < addProvider.upCargos.length; j++) {
            addProvider.upCargos[j].locationIndex = i;
            addProvider.upCargos[j].cargoIndex = j;
          }
          // downCargos가 있는 경우
          for (var j = 0; j < addProvider.downCargos.length; j++) {
            addProvider.downCargos[j].locationIndex = i;
            addProvider.downCargos[j].cargoIndex = j;
          }
        }
      }
    } else {
      // 이미 존재하면 업데이트

      addProvider.updateLocation(
        0,
        type: '상차',
        address1: addProvider.setLocationUpAddress1.toString(),
        address2: addProvider.setLocationUpAddress2.toString(),
        addressDis: _addressDis.text.trim(),
        location: addProvider.setLocationUpNLatLng as NLatLng,
        howTo: addProvider.setLocationCargoUpType.toString(),
        senderType: addProvider.addUpSenderType ?? [],
        senderName: _senderText.text.trim(),
        snederPhone: _phoneText.text.trim(),
        dateType: addProvider.setUpTimeType.toString(),
        date: addProvider.setUpDate as DateTime,
        dateAloneString: addProvider.setUpTimeAloneType.toString(),
        dateStart: addProvider.setUpDateDoubleStart,
        dateEnd: addProvider.setUpDateDoubleEnd,
        etc: addProvider.setUpTimeEtc.toString(),
        becareful: _multiText.text.trim(),
        upCargos: List<CargoInfo>.from(addProvider.upCargos),
        downCargos: List<CargoInfo>.from(addProvider.downCargos),
      );

      addProvider.updateLocation(
        2,
        type: '하차',
        address1: addProvider.setLocationUpAddress1.toString(),
        address2: addProvider.setLocationUpAddress2.toString(),
        addressDis: _addressDis.text.trim(),
        location: addProvider.setLocationUpNLatLng as NLatLng,
        howTo: addProvider.setLocationCargoUpType.toString(),
        senderType: addProvider.addUpSenderType ?? [],
        senderName: _senderText.text.trim(),
        snederPhone: _phoneText.text.trim(),
        dateType: addProvider.locations[2].dateType.toString(),
        date: addProvider.locations[2].date as DateTime,
        dateAloneString: addProvider.locations[2].dateAloneString.toString(),
        dateStart: addProvider.locations[2].dateType == '시간 선택'
            ? addProvider.locations[2].dateStart
            : addProvider.locations[2].dateEnd,
        dateEnd: addProvider.locations[2].dateEnd,
        etc: addProvider.locations[2].etc.toString(),
        becareful: addProvider.locations[2].becareful.toString(),
        upCargos: List<CargoInfo>.from(addProvider.locations[2].upCargos),
        downCargos: List<CargoInfo>.from(addProvider.locations[2].downCargos),
      );
    }

    addProvider.clearCargos();
  }

  Future _returnSec(AddProvider addProvider) async {
    print('@@@@@@@ 두번째 업데이트');

    addProvider.updateLocation(
      1,
      type: '하차',
      address1: addProvider.setLocationDownAddress1.toString(),
      address2: addProvider.setLocationDownAddress2.toString(),
      addressDis: _addressDis.text.trim(),
      location: addProvider.setLocationDownNLatLng as NLatLng,
      howTo: addProvider.setLocationCargoDownType.toString(),
      senderType: addProvider.addDownSenderType ?? [],
      senderName: _senderText.text.trim(),
      snederPhone: _phoneText.text.trim(),
      dateType: addProvider.setDownTimeType.toString(),
      dateAloneString: addProvider.setDownTimeAloneType.toString(),
      date: addProvider.setDownDate as DateTime,
      etc: addProvider.setDownTimeEtc.toString(),
      becareful: _multiText.text.trim(),
      upCargos: List<CargoInfo>.from(addProvider.upCargos),
      downCargos: List<CargoInfo>.from(addProvider.downCargos),
      dateStart: addProvider.setDownDateDoubleStart,
      dateEnd: addProvider.setDownDateDoubleEnd,
    );

/* // 3. 모든 locations의 upCargos 중 하차 안된 항목 찾기
    Set<String> allDownCargoIds =
        Set.from(addProvider.locations[1].downCargos.map((cargo) => cargo.id));

// 모든 location의 upCargos를 확인
    List<CargoInfo> unfinishedCargos = [];
    for (var location in addProvider.locations) {
      if (location.upCargos.isNotEmpty) {
        unfinishedCargos.addAll(location.upCargos
            .where((upCargo) => !allDownCargoIds.contains(upCargo.id)));
      }
    }

// 4. 찾은 항목들을 회차 정보의 downCargos에 추가
    addProvider.setdownCargoList(2, unfinishedCargos); */

    addProvider.clearCargos();
  }

  Future _returnThri(AddProvider addProvider) async {
    addProvider.updateLocation(
      2,
      type: '하차',
      address1: addProvider.locations[0].address1.toString(),
      address2: addProvider.locations[0].address2.toString(),
      addressDis: addProvider.locations[0].addressDis.toString(),
      location: addProvider.locations[0].location as NLatLng,
      howTo: addProvider.setLocationCargoDownType.toString(),
      senderType: addProvider.addDownSenderType ?? [],
      senderName: _senderText.text.trim(),
      snederPhone: _phoneText.text.trim(),
      dateType: addProvider.setDownTimeType.toString(),
      dateAloneString: addProvider.setDownTimeAloneType.toString(),
      date: addProvider.setDownDate as DateTime,
      etc: addProvider.setDownTimeEtc.toString(),
      becareful: _multiText.text.trim(),
      upCargos: List<CargoInfo>.from(addProvider.upCargos),
      downCargos: List<CargoInfo>.from(addProvider.downCargos),
      dateStart: addProvider.setDownDateDoubleStart,
      dateEnd: addProvider.setDownDateDoubleEnd,
    );

    addProvider.clearCargos();
  }

  //////////////////////////////////////////////////
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////

  Widget _placeType(AddProvider addProvider) {
    final dw = MediaQuery.of(context).size.width;
    return SizedBox(
      width: dw,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KTextWidget(
              text: isUpDown ? '상차지 정보(최대 3개)' : '하차지 정보(최대 3개)',
              size: 16,
              fontWeight: FontWeight.bold,
              color: isUpDown
                  ? addProvider.addUpSenderType == null
                      ? Colors.white
                      : Colors.grey.withOpacity(0.5)
                  : addProvider.addDownSenderType == null
                      ? Colors.white
                      : Colors.grey.withOpacity(0.5)),
          KTextWidget(
              text: isUpDown
                  ? '상차지 유형을 최대 3개까지 선택하세요.'
                  : '하차지 유형을 최대 3개까지 선택하세요.',
              size: 12,
              fontWeight: null,
              color: isUpDown
                  ? addProvider.addUpSenderType == null
                      ? Colors.grey
                      : Colors.grey.withOpacity(0.5)
                  : addProvider.addDownSenderType == null
                      ? Colors.grey
                      : Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 5,
            runSpacing: 8,
            children: [
              _senderPick('정보 없음'),
              _senderPick('대기업'),
              _senderPick('중소 기업'),
              _senderPick('물류 창고'),
              _senderPick('공사 현장'),
              _senderPick('아파트 단지'),
              _senderPick('일반 장소'),
              _senderPick('대로변 주차'),
              _senderPick('골목길 주차'),
              _senderPick('주차장 주차'),
              _senderPick('큰차 진입 불가'),
              _senderPick('대기 있음'),
              _senderPick('안전장비 지참'),
              _senderPick('지게차 운전 가능'),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _senderPick(String text) {
    final addProvider = Provider.of<AddProvider>(context);
    Color _isColor = isUpDown == false ? kRedColor : kBlueBssetColor;

    bool isContainText(List<String>? list, String text) {
      if (list == null) return false;
      return list.any((element) => element.contains(text));
    }

    return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          if (isUpDown) {
            addProvider.addUpSenderTypeState([text]);
          } else {
            addProvider.addDownSenderTypeState([text]);
          }
        },
        child: !isUpDown
            ? Container(
                padding: const EdgeInsets.only(
                    top: 12, bottom: 12, right: 10, left: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isContainText(addProvider.addDownSenderType, text)
                        ? _isColor.withOpacity(0.16)
                        : btnColor,
                    border: Border.all(
                      color: isContainText(addProvider.addDownSenderType, text)
                          ? _isColor
                          : Colors.grey.withOpacity(0.3),
                    )),
                child: Column(
                  children: [
                    KTextWidget(
                        text: text,
                        size: 15,
                        fontWeight:
                            isContainText(addProvider.addDownSenderType, text)
                                ? FontWeight.bold
                                : null,
                        color:
                            isContainText(addProvider.addDownSenderType, text)
                                ? _isColor
                                : Colors.grey)
                  ],
                ),
              )
            : Container(
                // 상단 코드와 동일한 패턴으로 isContainText 사용
                padding: const EdgeInsets.only(
                    top: 12, bottom: 12, right: 10, left: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isContainText(addProvider.addUpSenderType, text)
                        ? _isColor.withOpacity(0.16)
                        : btnColor,
                    border: Border.all(
                        color: isContainText(addProvider.addUpSenderType, text)
                            ? _isColor
                            : Colors.grey.withOpacity(0.3))),
                child: Column(
                  children: [
                    KTextWidget(
                        text: text,
                        size: 15,
                        fontWeight:
                            isContainText(addProvider.addUpSenderType, text)
                                ? FontWeight.bold
                                : null,
                        color: isContainText(addProvider.addUpSenderType, text)
                            ? _isColor
                            : Colors.grey),
                  ],
                ),
              ));
  }

//////////////////////////////////////////////////
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////

  TextEditingController _senderText = TextEditingController();
  TextEditingController _phoneText = TextEditingController();
  TextEditingController _addressDis = TextEditingController();
  TextEditingController _searchText = TextEditingController();

  int _input = 0;
  int _inputPhone = 0;

  Widget _senderInfo(AddProvider addProvider) {
    Color _isColor = !isUpDown == true ? kRedColor : kBlueBssetColor;
    final dataProvider = Provider.of<DataProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KTextWidget(
            text: isUpDown ? '상차지 명 / 연락처' : '하차지 명 / 연락처',
            size: 16,
            fontWeight: FontWeight.bold,
            color: _input > 0 && _inputPhone > 0
                ? Colors.grey.withOpacity(0.5)
                : Colors.white),
        KTextWidget(
            text: isUpDown
                ? '상차지 명칭과 담당자 연락처를 입력하세요.'
                : '하차지 명칭과 담당자 연락처를 입력하세요.',
            size: 12,
            fontWeight: null,
            color: _input > 0 && _inputPhone > 0
                ? Colors.grey.withOpacity(0.5)
                : Colors.grey),
        const SizedBox(height: 16),
        Container(
          height: 56,
          child: TextFormField(
            controller: _senderText,
            autocorrect: false,
            maxLength: 30,
            cursorColor: _isColor,
            minLines: 1,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              suffixIcon: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _senderText.clear();
                  _input = 0;
                  setState(() {});
                },
                child: Icon(
                  Icons.remove_circle,
                  color:
                      _input == 0 ? Colors.grey.withOpacity(0.3) : Colors.grey,
                ),
              ),
              counterText: '',
              hintText: isUpDown
                  ? '상차지 담당자 또는 회사 명을 입력하세요!'
                  : '하차지 담당자 또는 회사 명을 입력하세요!',
              hintStyle: const TextStyle(fontSize: 16),
              filled: true,
              fillColor: btnColor,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(16),
              ),
              focusedBorder: OutlineInputBorder(
                // 선택되었을 때 보덕색으로 표시됨
                borderSide: BorderSide(color: _isColor, width: 1.0),
                borderRadius: BorderRadius.circular(16),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _input = _senderText.text.length;
              });
            },
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          child: TextFormField(
            controller: _phoneText,
            autocorrect: false,
            cursorColor: _isColor,
            maxLength: 12,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              suffixIcon: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _phoneText.clear();
                  _inputPhone = 0;
                  setState(() {});
                },
                child: Icon(
                  Icons.remove_circle,
                  color: _inputPhone == 0
                      ? Colors.grey.withOpacity(0.3)
                      : Colors.grey,
                ),
              ),
              counterText: '',
              hintText: '받으시는 분 또는 회사의 연락처를 입력하세요!',
              hintStyle: const TextStyle(fontSize: 16),
              filled: true,
              fillColor: btnColor,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(16),
              ),
              focusedBorder: OutlineInputBorder(
                // 선택되었을 때 보덕색으로 표시됨
                borderSide: BorderSide(color: _isColor, width: 1.0),
                borderRadius: BorderRadius.circular(16),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _inputPhone = _phoneText.text.length;
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            if (widget.callType.contains('상차')) {
              if (addProvider.senderUpType == true) {
                addProvider.setSenderUpTypeState(null);
                addProvider.setLocationUpNamePhoneState(null, null);
                _senderText.clear();
                _phoneText.clear();
                _input = 0;
                _inputPhone = 0;
              } else {
                addProvider.setSenderUpTypeState(true);
                addProvider.setLocationUpNamePhoneState(
                    dataProvider.name, dataProvider.phone);

                setState(() {
                  _senderText.text = addProvider.setLocationUpName.toString();
                  _phoneText.text = addProvider.setLocationUpPhone.toString();
                });
              }
            } else {
              if (addProvider.senderDownType == true) {
                addProvider.setSenderDownTypeState(null);
                addProvider.setLocationUpNamePhoneState(null, null);
                _senderText.clear();
                _phoneText.clear();
                _input = 0;
                _inputPhone = 0;
              } else {
                addProvider.setSenderDownTypeState(true);
                addProvider.setLocationDownNamePhoneState(
                    dataProvider.name, dataProvider.phone);

                setState(() {
                  _senderText.text = addProvider.setLocationDownName.toString();
                  _phoneText.text = addProvider.setLocationDownPhone.toString();
                });
              }
            }
          },
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 15,
                color: widget.callType.contains('상차')
                    ? addProvider.senderUpType == true
                        ? kBlueBssetColor
                        : _input > 0 && _inputPhone > 0
                            ? Colors.grey.withOpacity(0.5)
                            : Colors.white
                    : addProvider.senderDownType == true
                        ? kRedColor
                        : _input > 0 && _inputPhone > 0
                            ? Colors.grey.withOpacity(0.5)
                            : Colors.white,
              ),
              const SizedBox(width: 5),
              KTextWidget(
                text: '고객 정보와 동일',
                size: 15,
                fontWeight: FontWeight.bold,
                color: widget.callType.contains('상차')
                    ? addProvider.senderUpType == true
                        ? kBlueBssetColor
                        : _input > 0 && _inputPhone > 0
                            ? Colors.grey.withOpacity(0.5)
                            : Colors.white
                    : addProvider.senderDownType == true
                        ? kRedColor
                        : _input > 0 && _inputPhone > 0
                            ? Colors.grey.withOpacity(0.5)
                            : Colors.white,
              )
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

//////////////////////////////////////////////////
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////

  Widget _addressInfo(AddProvider addProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            KTextWidget(
                text: isUpDown ? '상차지 주소' : '하차지 주소',
                size: 16,
                fontWeight: FontWeight.bold,
                color: isUpDown
                    ? addProvider.setLocationUpAddress1 == null
                        ? Colors.white
                        : Colors.grey.withOpacity(0.5)
                    : addProvider.setLocationDownAddress1 == null
                        ? Colors.white
                        : Colors.grey.withOpacity(0.5)),
            const Expanded(child: SizedBox()),
          ],
        ),
        KTextWidget(
            text:
                isUpDown ? '버튼을 클릭하여 상차 주소를 검색하세요.' : '버튼을 클릭하여 하차 주소를 검색하세요.',
            size: 12,
            fontWeight: null,
            color: isUpDown
                ? addProvider.setLocationUpAddress1 == null
                    ? Colors.grey
                    : Colors.grey.withOpacity(0.5)
                : addProvider.setLocationDownAddress1 == null
                    ? Colors.grey
                    : Colors.grey.withOpacity(0.5)),
        const SizedBox(height: 16),
        _addressSet(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _addressSet() {
    final dw = MediaQuery.of(context).size.width;
    bool _isT = widget.callType.contains('상차');
    return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          hideKeyboard(context);
          if (widget.callType == '왕복_하차') {
            ScaffoldMessenger.of(context).showSnackBar(errorSnackBar(
                '왕복 배송지의 하차를 변경할 수 없습니다.\n시작 상차지를 변경하거나 다구간 운송을 이용하세요.',
                context));
          } else {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DelayedWidget(
                        animation: DelayedAnimations.SLIDE_FROM_BOTTOM,
                        animationDuration: const Duration(milliseconds: 500),
                        child: Container(
                            width: dw,
                            height: 654,
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: msgBackColor),
                            child: AddressDialog(
                                callType: widget.callType.contains('회차')
                                    ? '하차'
                                    : widget.callType)),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
        child: isUpDown ? _upAdsState() : _downAdsState());
  }

  Widget _upAdsState() {
    final dw = MediaQuery.of(context).size.width;
    final addProvider = Provider.of<AddProvider>(context);
    bool _isAds = addProvider.setLocationUpAddress1 == null;
    Color _isColor = isUpDown == false ? kRedColor : kBlueBssetColor;
    return Column(
      children: [
        Container(
          height: 52,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: _isAds ? noState : msgBackColor),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_sharp,
                color: !_isAds ? Colors.white : Colors.grey,
                size: 18,
              ),
              const SizedBox(width: 8),
              if (addProvider.setLocationUpAddress1 == null)
                SizedBox(
                  child: KTextWidget(
                      text: '상차지 주소를 등록하세요.',
                      size: 16,
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.bold,
                      color: !_isAds ? Colors.white : Colors.grey),
                )
              else
                SizedBox(
                  width: dw - 66,
                  child: KTextWidget(
                      text: addProvider.setLocationUpAddress1.toString(),
                      size: 16,
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.bold,
                      color: !_isAds ? Colors.white : Colors.grey),
                )
            ],
          ),
        ),
        if (addProvider.setLocationUpAddress1 != null)
          Column(
            children: [
              const SizedBox(height: 12),
              Container(
                height: 56,
                child: TextFormField(
                  controller: _addressDis,
                  autocorrect: false,
                  maxLength: 50,
                  cursorColor: _isColor,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    suffixIcon: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _addressDis.clear();
                        _inputAds = 0;
                        setState(() {});
                      },
                      child: Icon(
                        Icons.remove_circle,
                        color: _inputAds == 0
                            ? Colors.grey.withOpacity(0.3)
                            : Colors.grey,
                      ),
                    ),
                    counterText: '',
                    hintText: '상세주소를 입력하세요.(필요 시)',
                    hintStyle: const TextStyle(fontSize: 16),
                    filled: true,
                    fillColor: btnColor,
                    border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      // 선택되었을 때 보덕색으로 표시됨
                      borderSide: BorderSide(color: _isColor, width: 1.0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _inputAds = _addressDis.text.length;
                    });
                  },
                ),
              ),
            ],
          )
      ],
    );
  }

  int _inputAds = 0;

  Widget _downAdsState() {
    final dw = MediaQuery.of(context).size.width;
    final addProvider = Provider.of<AddProvider>(context);
    bool _isAds = addProvider.setLocationDownAddress1 != null;
    Color _isColor = isUpDown == false ? kRedColor : kBlueBssetColor;
    return Column(
      children: [
        Center(
          child: Container(
            height: 52,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: !_isAds ? noState : msgBackColor),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_sharp,
                  color: _isAds ? Colors.white : Colors.grey,
                  size: 18,
                ),
                const SizedBox(width: 8),
                if (addProvider.setLocationDownAddress1 == null)
                  SizedBox(
                    child: KTextWidget(
                        text: '하차지 주소를 등록하세요.',
                        size: 16,
                        textAlign: TextAlign.center,
                        fontWeight: FontWeight.bold,
                        color: _isAds ? Colors.white : Colors.grey),
                  )
                else
                  SizedBox(
                    width: dw - 66,
                    child: KTextWidget(
                        text: addProvider.setLocationDownAddress1.toString(),
                        size: 16,
                        textAlign: TextAlign.center,
                        fontWeight: FontWeight.bold,
                        color: _isAds ? Colors.white : Colors.grey),
                  )
              ],
            ),
          ),
        ),
        if (addProvider.setLocationDownAddress1 != null)
          Column(
            children: [
              const SizedBox(height: 12),
              Container(
                height: 56,
                child: TextFormField(
                  controller: _addressDis,
                  autocorrect: false,
                  cursorColor: _isColor,
                  maxLength: 70,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    suffixIcon: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _addressDis.clear();
                        _inputAds = 0;
                        setState(() {});
                      },
                      child: Icon(
                        Icons.remove_circle,
                        color: _inputAds == 0
                            ? Colors.grey.withOpacity(0.3)
                            : Colors.grey,
                      ),
                    ),
                    counterText: '',
                    hintText: '상세주소를 입력하세요.(필요 시)',
                    hintStyle: const TextStyle(fontSize: 16),
                    filled: true,
                    fillColor: btnColor,
                    border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      // 선택되었을 때 보덕색으로 표시됨
                      borderSide: BorderSide(color: _isColor, width: 1.0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _inputAds = _addressDis.text.length;
                    });
                  },
                ),
              ),
            ],
          )
      ],
    );
  }

//////////////////////////////////////////////////
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////

  Widget _cargoDate(AddProvider addProvider) {
    final dw = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KTextWidget(
            text: isUpDown ? '상차 일시' : '하차 일시',
            size: 16,
            fontWeight: FontWeight.bold,
            color: isUpDown
                ? addProvider.setUpDate == null
                    ? Colors.white
                    : Colors.grey.withOpacity(0.5)
                : addProvider.setDownDate == null
                    ? Colors.white
                    : Colors.grey.withOpacity(0.5)),
        KTextWidget(
            text: isUpDown
                ? '화물 상차일 및 상차 시간정보를 입력하세요.'
                : '화물 하차일 및 하차 시간정보를 입력하세요.',
            size: 12,
            fontWeight: null,
            color: isUpDown
                ? addProvider.setUpDate == null
                    ? Colors.grey
                    : Colors.grey.withOpacity(0.5)
                : addProvider.setDownDate == null
                    ? Colors.grey
                    : Colors.grey.withOpacity(0.5)),
        const SizedBox(height: 16),
        GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              hideKeyboard(context);
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return Material(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DelayedWidget(
                          animation: DelayedAnimations.SLIDE_FROM_BOTTOM,
                          animationDuration: const Duration(milliseconds: 500),
                          child: Container(
                            width: dw,
                            height: 654,
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: msgBackColor),
                            child: DialogTimeSet(
                              callType: widget.callType.contains('회차')
                                  ? '하차'
                                  : widget.callType,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: Container(
                height: 52,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isUpDown
                        ? addProvider.setUpDate == null
                            ? noState
                            : msgBackColor
                        : addProvider.setDownDate == null
                            ? noState
                            : msgBackColor),
                child: isUpDown
                    ? addProvider.setUpDate == null
                        ? _btn()
                        : _setUpDone()
                    : addProvider.setDownDate == null
                        ? _btn()
                        : _setDownDone())),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _btn() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), color: noState),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.date_range,
            color: Colors.grey,
            size: 18,
          ),
          SizedBox(width: 8),
          /*  addProvider.
                  isUpDown == false ? */
          KTextWidget(
              text: '일시 등록',
              size: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey)
        ],
      ),
    );
  }

  Widget _setUpDone() {
    final addProvider = Provider.of<AddProvider>(context);

    return Container(
      height: 62,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.date_range,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              /*  addProvider.
                    isUpDown == false ? */
              Row(
                children: [
                  KTextWidget(
                      text: formatDate(addProvider.setUpDate as DateTime) +
                          ' ${getDayName(addProvider.setUpDate as DateTime)}',
                      size: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  if (isToday(addProvider.setUpDate as DateTime))
                    const KTextWidget(
                        text: ' (오늘)',
                        size: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                ],
              )
            ],
          ),
          if (addProvider.setUpTimeType == '시간 선택')
            KTextWidget(
                text:
                    '${fase3String(addProvider.setUpDateDoubleStart as DateTime)} ${addProvider.setUpDateDoubleStart!.hour} 시 : ${addProvider.setUpDateDoubleStart!.minute == 0 ? 00 : addProvider.setUpDateDoubleStart!.minute} 분 ${addProvider.setUpTimeAloneType}',
                size: 14,
                fontWeight: null,
                color: Colors.white)
          else if (addProvider.setUpTimeType == '시간대 선택')
            KTextWidget(
                text:
                    '${fase3String(addProvider.setUpDateDoubleStart as DateTime)} ${addProvider.setUpDateDoubleStart!.hour}시 : ${addProvider.setUpDateDoubleStart!.minute == 0 ? 00 : addProvider.setUpDateDoubleStart!.minute}분 부터 ~ ${fase3String(addProvider.setUpDateDoubleEnd as DateTime)} ${addProvider.setUpDateDoubleEnd!.hour}시 : ${addProvider.setUpDateDoubleEnd!.minute == 0 ? 00 : addProvider.setUpDateDoubleEnd!.minute}분 까지',
                size: 14,
                fontWeight: null,
                color: Colors.white)
          else
            KTextWidget(
                text: addProvider.setUpTimeType.toString(),
                size: 14,
                fontWeight: null,
                color: Colors.white),
        ],
      ),
    );
  }

  Widget _setDownDone() {
    final addProvider = Provider.of<AddProvider>(context);

    return Container(
      height: 62,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.date_range,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              /*  addProvider.
                    isUpDown == false ? */
              Row(
                children: [
                  KTextWidget(
                      text: formatDate(addProvider.setDownDate as DateTime) +
                          ' ${getDayName(addProvider.setDownDate as DateTime)}',
                      size: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  if (isToday(addProvider.setDownDate as DateTime))
                    const KTextWidget(
                        text: ' (오늘)',
                        size: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                ],
              )
            ],
          ),
          if (addProvider.setDownTimeType == '시간 선택')
            KTextWidget(
                text:
                    '${fase3String(addProvider.setDownDateDoubleStart as DateTime)} ${addProvider.setDownDateDoubleStart!.hour} 시 : ${addProvider.setDownDateDoubleStart!.minute == 0 ? 00 : addProvider.setDownDateDoubleStart!.minute} 분 ${addProvider.setDownTimeAloneType}',
                size: 14,
                fontWeight: null,
                color: Colors.white)
          else if (addProvider.setDownTimeType == '시간대 선택')
            KTextWidget(
                text:
                    '${fase3String(addProvider.setDownDateDoubleStart as DateTime)} ${addProvider.setDownDateDoubleStart!.hour}시 : ${addProvider.setDownDateDoubleStart!.minute == 0 ? 00 : addProvider.setDownDateDoubleStart!.minute}분 부터 ~ ${fase3String(addProvider.setDownDateDoubleEnd as DateTime)} ${addProvider.setDownDateDoubleEnd!.hour}시 : ${addProvider.setDownDateDoubleEnd!.minute == 0 ? 00 : addProvider.setDownDateDoubleEnd!.minute}분 까지',
                size: 14,
                fontWeight: null,
                color: Colors.white)
          else
            KTextWidget(
                text: addProvider.setDownTimeType.toString(),
                size: 14,
                fontWeight: null,
                color: Colors.white),
        ],
      ),
    );
  }

//////////////////////////////////////////////////
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////

  Widget _cargoSelType(AddProvider addProvider) {
    final dw = MediaQuery.of(context).size.width;
    return SizedBox(
      width: dw,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KTextWidget(
              text: isUpDown ? '상차 방법' : '하차 방법',
              size: 16,
              fontWeight: FontWeight.bold,
              color: isUpDown
                  ? addProvider.setLocationCargoUpType == null
                      ? Colors.white
                      : Colors.grey.withOpacity(0.5)
                  : addProvider.setLocationCargoDownType == null
                      ? Colors.white
                      : Colors.grey.withOpacity(0.5)),
          KTextWidget(
              text: isUpDown ? '화물 상차 방법을 선택하세요.' : '화물 하차 방법을 선택하세요.',
              size: 12,
              fontWeight: null,
              color: isUpDown
                  ? addProvider.setLocationCargoUpType == null
                      ? Colors.grey
                      : Colors.grey.withOpacity(0.5)
                  : addProvider.setLocationCargoDownType == null
                      ? Colors.grey
                      : Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Wrap(
            runSpacing: 8,
            spacing: 5,
            children: [
              _upTypeWidget('수작업'),
              _upTypeWidget('지게차'),
              _upTypeWidget('호이스트'),
              _upTypeWidget('컨베이어'),
              _upTypeWidget('크레인'),
              _upTypeWidget('미정'),
              _upTypeWidget('전화로 확인'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _upTypeWidget(String text) {
    final addProvider = Provider.of<AddProvider>(context);
    Color _isColor =
        widget.callType.contains('상차') ? kBlueBssetColor : kRedColor;
    return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          if (isUpDown) {
            addProvider.setLocationCargoUpTypeState(text);
          } else {
            addProvider.setLocationCargoDownTypeState(text);
          }
        },
        child: Container(
          //height: 40,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: !isUpDown
                  ? addProvider.setLocationCargoDownType == text
                      ? _isColor.withOpacity(0.16)
                      : btnColor
                  : addProvider.setLocationCargoUpType == text
                      ? _isColor.withOpacity(0.16)
                      : btnColor,
              border: Border.all(
                  color: !isUpDown
                      ? addProvider.setLocationCargoDownType == text
                          ? _isColor
                          : Colors.grey.withOpacity(0.5)
                      : addProvider.setLocationCargoUpType == text
                          ? _isColor
                          : Colors.grey.withOpacity(0.5))),
          child: Padding(
            padding:
                const EdgeInsets.only(top: 12, bottom: 12, right: 10, left: 10),
            child: Column(
              children: [
                KTextWidget(
                    text: text,
                    size: 16,
                    fontWeight: !isUpDown
                        ? addProvider.setLocationCargoDownType == text
                            ? FontWeight.bold
                            : null
                        : addProvider.setLocationCargoUpType == text
                            ? FontWeight.bold
                            : null,
                    color: !isUpDown
                        ? addProvider.setLocationCargoDownType == text
                            ? _isColor
                            : Colors.grey
                        : addProvider.setLocationCargoUpType == text
                            ? _isColor
                            : Colors.grey),
              ],
            ),
          ),
        ));
  }

//////////////////////////////////////////////////
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////

  TextEditingController _multiText = TextEditingController();

  Widget _multiEtc(AddProvider addProvider) {
    final dw = MediaQuery.of(context).size.width;
    return SizedBox(
      width: dw,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          KTextWidget(
              text: isUpDown ? '상차 안내' : '하차 안내',
              size: 16,
              fontWeight: null,
              color: Colors.grey.withOpacity(0.7)),
          KTextWidget(
              text: isUpDown
                  ? '화물 상차시 주의사항 또는 안내사항을 입력하세요.'
                  : '화물 하차시 주의사항 또는 안내사항을 입력하세요.',
              size: 12,
              fontWeight: null,
              color: Colors.grey.withOpacity(0.7)),
          const SizedBox(height: 12),
          Container(
              //height: 56,
              child: TextFormField(
            controller: _multiText,
            cursorColor:
                widget.callType.contains('상차') ? kBlueBssetColor : kRedColor,
            autocorrect: false,
            maxLength: 100,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            minLines: 3,
            maxLines: 3,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterStyle: const TextStyle(fontSize: 0),
              errorStyle:
                  const TextStyle(fontSize: 0, height: 0), // 기본 에러 스타일 완전히 숨기기
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: kRedColor)),
              errorText: null, // 기본 에러 텍스트 비활성화
              filled: true,
              fillColor: btnColor,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 10,
              ),
              hintText:
                  '화물 특성 또는 참고사항은 입력하세요.(필요 시)\n"대로변에 주차하고 상, 하차", "5층까지 함께 올려주세요, 엘리베이터 없어요.", "대기시간 있어요."',
              hintStyle: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: Colors.grey,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: widget.callType.contains('상차')
                        ? kBlueBssetColor
                        : kRedColor,
                    width: 1.0),
                borderRadius: BorderRadius.circular(10),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          )),
        ],
      ),
    );
  }

//////////////////////////////////////////////////
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////
//////////////////////////////////////////////////
}
