import 'package:delayed_widget/delayed_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/model/multi_cargo_add_model.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/normal_state/up_down/set_page/address.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/search/search_main.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/hashProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/add_cargo_date.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';

class AddUpDownSetPage extends StatefulWidget {
  final int? no;
  final String callType;
  AddUpDownSetPage({super.key, required this.callType, this.no});

  @override
  State<AddUpDownSetPage> createState() => _AddUpDownSetPageState();
}

class _AddUpDownSetPageState extends State<AddUpDownSetPage> {
  bool isUpDown = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isUpDown = widget.callType.contains('상차');
    _inputSet();
  }

  Future _inputSet() async {
    final addProvider = Provider.of<AddProvider>(context, listen: false);
    final hashProvider = Provider.of<HashProvider>(context, listen: false);

    if (isUpDown) {
      if (addProvider.setLocationUpName != null) {
        _senderText.text = addProvider.setLocationUpName!.length > 10
            ? hashProvider.decryptData(addProvider.setLocationUpName.toString())
            : addProvider.setLocationUpName.toString();
        _phoneText.text = addProvider.setLocationUpPhone.toString();
        _input = _senderText.text.length;
        _inputPhone = _phoneText.text.length;
      }
    } else {
      if (addProvider.setLocationDownName != null) {
        _senderText.text = addProvider.setLocationDownName!.length > 10
            ? hashProvider
                .decryptData(addProvider.setLocationDownName.toString())
            : addProvider.setLocationDownName.toString();
        _phoneText.text = addProvider.setLocationDownPhone.toString();
        _input = _senderText.text.length;
        _inputPhone = _phoneText.text.length;
      }
    }

    if (widget.callType.contains('상차')) {
      if (addProvider.setLocationUpName != null) {
        _senderText.text = addProvider.setLocationUpName.toString();
        _phoneText.text = addProvider.setLocationUpPhone.toString();
      }
      if (addProvider.setLocationUpDis != null) {
        _addressDis.text = addProvider.setLocationUpDis.toString();
      }
      if (addProvider.addMultiEtc != null) {
        _multiText.text = addProvider.addMultiEtc.toString();
        print(addProvider.addMultiEtc);
      }
      if (addProvider.setUpEtc != null && addProvider.setUpEtc != '') {
        _multiText.text = addProvider.setUpEtc.toString();
      }
    } else {
      if (addProvider.setLocationDownName != null) {
        _senderText.text = addProvider.setLocationDownName.toString();
        _phoneText.text = addProvider.setLocationDownPhone.toString();
      }
      if (addProvider.setLocationDownDis != null) {
        _addressDis.text = addProvider.setLocationDownDis.toString();
      }
      if (addProvider.addMultiEtc != null) {
        _multiText.text = addProvider.addMultiEtc.toString();
      }
      if (addProvider.setDownEtc != null && addProvider.setDownEtc != '') {
        _multiText.text = addProvider.setDownEtc.toString();
      }
    }

    setState(() {});
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
            addProvider.addUpSenderType != null
        : addProvider.setLocationCargoDownType != null &&
            _inputPhone > 0 &&
            _input > 0 &&
            addProvider.setLocationDownAddress1 != null &&
            addProvider.setDownDate != null &&
            addProvider.addDownSenderType != null;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            widget.callType.contains('상차') ? '상차지 등록' : '하차지 등록',
            style: const TextStyle(fontSize: 20),
          ),
          actions: [
            GestureDetector(
              onTap: () async {
                HapticFeedback.lightImpact();
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
          HapticFeedback.lightImpact();
          if (widget.callType.contains('다구간_수정')) {
            await _multiReSet(addProvider);
          } else if (widget.callType.contains('다구간')) {
            await _multiAdd(addProvider);
          } else {
            context.read<AddProvider>().checkAndUpdateSimpleRoute();
            await _normalAdd(addProvider);
          }
          Navigator.pop(context);
        },
        child: Container(
          height: 56,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12), color: kGreenFontColor),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KTextWidget(
                  text: isUpDown ? '상차지 정보 등록' : '하차지 등록',
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
      );
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
      );
    }
  }

  Future _multiAdd(AddProvider addProvider) async {
    if (widget.callType.contains('상차')) {
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
      ));
    }
  }

  Future _normalAdd(AddProvider addProvider) async {
    if (widget.callType.contains('상차')) {
      addProvider.setLocationUpNamePhoneState(
          _senderText.text.trim(), _phoneText.text.trim());
      if (_addressDis != null) {
        addProvider.setLocationUpDisState(_addressDis.text.trim());
      }
      if (_multiText.text.isNotEmpty || _multiText.text != '') {
        addProvider.setUpEtcState(_multiText.text.trim());
      }
    } else {
      addProvider.setLocationDownNamePhoneState(
          _senderText.text.trim(), _phoneText.text.trim());
      if (_addressDis != null) {
        addProvider.setLocationDownDisState(_addressDis.text.trim());
      }
      if (_multiText.text.isNotEmpty || _multiText.text != '') {
        addProvider.setDownEtcState(_multiText.text.trim());
      }
    }
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

    return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();

          if (widget.callType.contains('하차')) {
            addProvider.addDownSenderTypeState([text]);
          } else {
            addProvider.addUpSenderTypeState([text]);
          }
        },
        child: widget.callType.contains('하차')
            ? Container(
                padding: const EdgeInsets.only(
                    top: 12, bottom: 12, right: 10, left: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: addProvider.addDownSenderType != null &&
                            addProvider.addDownSenderType!.contains(text)
                        ? _isColor.withOpacity(0.16)
                        : btnColor,
                    border: Border.all(
                      color: addProvider.addDownSenderType != null &&
                              addProvider.addDownSenderType!.contains(text)
                          ? _isColor
                          : Colors.grey.withOpacity(0.3),
                    )),
                child: Column(
                  children: [
                    KTextWidget(
                        text: text,
                        size: 15,
                        fontWeight: addProvider.addDownSenderType != null &&
                                addProvider.addDownSenderType!.contains(text)
                            ? FontWeight.bold
                            : null,
                        color: addProvider.addDownSenderType != null &&
                                addProvider.addDownSenderType!.contains(text)
                            ? _isColor
                            : Colors.grey)
                  ],
                ),
              )
            : Container(
                padding: const EdgeInsets.only(
                    top: 12, bottom: 12, right: 10, left: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: addProvider.addUpSenderType != null &&
                            addProvider.addUpSenderType!.contains(text)
                        ? _isColor.withOpacity(0.16)
                        : btnColor,
                    border: Border.all(
                        color: addProvider.addUpSenderType != null &&
                                addProvider.addUpSenderType!.contains(text)
                            ? _isColor
                            : Colors.grey.withOpacity(0.3))),
                child: Column(
                  children: [
                    KTextWidget(
                        text: text,
                        size: 15,
                        fontWeight: addProvider.addUpSenderType != null &&
                                addProvider.addUpSenderType!.contains(text)
                            ? FontWeight.bold
                            : null,
                        color: addProvider.addUpSenderType != null &&
                                addProvider.addUpSenderType!.contains(text)
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
    final hashProvider = Provider.of<HashProvider>(context, listen: false);
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
            HapticFeedback.lightImpact();
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
                _senderText.text = hashProvider
                    .decryptData(addProvider.setLocationUpName.toString());
                _phoneText.text = addProvider.setLocationUpPhone.toString();
                _input = _senderText.text.length;
                _inputPhone = _phoneText.text.length;
                setState(() {});
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
                _senderText.text = hashProvider
                    .decryptData(addProvider.setLocationDownName.toString());
                _phoneText.text = addProvider.setLocationDownPhone.toString();
                _input = _senderText.text.length;
                _inputPhone = _phoneText.text.length;
                setState(() {});
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
                          child: AddressDialog(callType: widget.callType)),
                    ),
                  ],
                ),
              );
            },
          );
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
          //height: addProvider.setLocationUpAddress1!.length > 20 ? 104 : 52,
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
    bool _isAds = addProvider.setLocationDownAddress1 == null;
    Color _isColor = isUpDown == false ? kRedColor : kBlueBssetColor;
    return Column(
      children: [
        Center(
          child: Container(
            height: 52,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: _isAds ? noState : msgBackColor),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on_sharp,
                  color: Colors.grey,
                  size: 18,
                ),
                const SizedBox(width: 8),
                if (addProvider.setLocationDownAddress1 == null)
                  const SizedBox(
                    child: KTextWidget(
                        text: '하차지 주소를 등록하세요.',
                        size: 16,
                        textAlign: TextAlign.center,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
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
                              callType: widget.callType,
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
        widget.callType.contains('하차') ? kRedColor : kBlueBssetColor;
    return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          if (widget.callType.contains('하차')) {
            addProvider.setLocationCargoDownTypeState(text);
          } else {
            addProvider.setLocationCargoUpTypeState(text);
          }
        },
        child: Container(
          //height: 40,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: widget.callType.contains('하차')
                  ? addProvider.setLocationCargoDownType == text
                      ? _isColor.withOpacity(0.16)
                      : btnColor
                  : addProvider.setLocationCargoUpType == text
                      ? _isColor.withOpacity(0.16)
                      : btnColor,
              border: Border.all(
                  color: widget.callType.contains('하차')
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
                    fontWeight: widget.callType.contains('하차')
                        ? addProvider.setLocationCargoDownType == text
                            ? FontWeight.bold
                            : null
                        : addProvider.setLocationCargoUpType == text
                            ? FontWeight.bold
                            : null,
                    color: widget.callType.contains('하차')
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
}
