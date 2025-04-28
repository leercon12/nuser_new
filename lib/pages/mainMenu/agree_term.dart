import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/pages/mainMenu/term/cargo.dart';
import 'package:flutter_mixcall_normaluser_new/pages/mainMenu/term/location.dart';
import 'package:flutter_mixcall_normaluser_new/pages/mainMenu/term/person.dart';
import 'package:flutter_mixcall_normaluser_new/pages/mainMenu/term/point.dart';
import 'package:flutter_mixcall_normaluser_new/pages/mainMenu/term/use.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';

import 'package:multi_dropdown/multiselect_dropdown.dart';

class AgreeMainPage extends StatefulWidget {
  final String? type;
  const AgreeMainPage({super.key, this.type});

  @override
  State<AgreeMainPage> createState() => _AgreeMainPageState();
}

class _AgreeMainPageState extends State<AgreeMainPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.type == null) {
      _type = '혼적콜 서비스 이용 약관';
    } else {
      _type = widget.type;
    }
  }

  final MultiSelectController _controllerC = MultiSelectController();
  String? _type;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const KTextWidget(
          text: '전체 약관 보기',
          size: 20,
          fontWeight: null,
          color: Colors.white,
        ),
        actions: const [
          Icon(Icons.info, color: kBlueBssetColor, size: 28),
          SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
            child: MultiSelectDropDown(
                controller: _controllerC,
                selectionType: SelectionType.single,
                singleSelectItemStyle:
                    const TextStyle(fontSize: 16, color: Colors.white),
                hintColor: btnColor,
                hint: '원하시는 하차 날자를 선택하세요.',
                hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                optionTextStyle: const TextStyle(
                  fontSize: 16,
                ),
                focusedBorderColor: kGreenFontColor,
                fieldBackgroundColor: btnColor,
                borderColor: btnColor,
                focusedBorderWidth: 1,
                selectedOptionBackgroundColor: kGreenFontColor,
                selectedOptionTextColor: Colors.white,
                optionsBackgroundColor: btnColor,
                dropdownBackgroundColor: btnColor,
                dropdownMargin: 10,
                dropdownHeight: 300,
                borderRadius: 16,
                clearIcon: null,
                dropdownBorderRadius: 16,
                selectedOptions: [
                  widget.type == null
                      ? ValueItem(
                          label: '혼적콜 서비스 이용 약관', value: '혼적콜 서비스 이용 약관')
                      : ValueItem(
                          label: widget.type.toString(),
                          value: widget.type.toString())
                ],
                onOptionSelected: (options) {
                  _type = options[0].value;
                  setState(() {});
                },
                options: const [
                  ValueItem(label: '혼적콜 서비스 이용 약관', value: '혼적콜 서비스 이용 약관'),
                  ValueItem(label: '혼적콜 개인정보 처리방침', value: '혼적콜 개인정보 처리방침'),
                  ValueItem(label: '혼적콜 위치정보 이용약관', value: '혼적콜 위치정보 이용약관'),
                  ValueItem(
                      label: '혼적콜 전자금융(포인트)이용 약관', value: '혼적콜 전자금융(포인트)이용 약관'),
                  ValueItem(label: '혼적콜 운송 약관', value: '혼적콜 운송 약관'),
                ]),
          ),
          const SizedBox(height: 12),
          if (_type == '혼적콜 서비스 이용 약관') const Expanded(child: UseAgree()),
          if (_type == '혼적콜 개인정보 처리방침') const Expanded(child: PersonAgree()),
          if (_type == '혼적콜 위치정보 이용약관') const Expanded(child: LocationAgree()),
          if (_type == '혼적콜 전자금융(포인트)이용 약관')
            const Expanded(child: PointAgree()),
          if (_type == '혼적콜 운송 약관') const Expanded(child: CargoAgree()),
        ],
      )),
    );
  }
}
