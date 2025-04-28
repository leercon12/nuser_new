import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/hashProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class SearchAddress extends StatefulWidget {
  final List<dynamic> locations;
  final List<dynamic> comLocations;
  final String callType;
  final String type;
  const SearchAddress(
      {super.key,
      required this.locations,
      required this.comLocations,
      required this.callType,
      required this.type});

  @override
  State<SearchAddress> createState() => _SearchAddressState();
}

class _SearchAddressState extends State<SearchAddress> {
  // 필터링된 리스트를 저장할 상태 변수들
  List<dynamic> filteredLocations = [];
  List<dynamic> filteredComLocations = [];

  @override
  void initState() {
    super.initState();
    // 초기값 설정시 리스트를 뒤집어서 저장
    filteredLocations = List.from(widget.locations.reversed);
    filteredComLocations = List.from(widget.comLocations.reversed);
  }

  // 검색 함수
  void _searchLocations(String query) {
    setState(() {
      if (query.isEmpty) {
        // 검색어가 없으면 전체 리스트 보여주기
        filteredLocations = List.from(widget.locations);
        filteredComLocations = List.from(widget.comLocations);
      } else {
        // 검색어가 있으면 필터링
        filteredLocations = widget.locations.where((location) {
          final name = location['name'].toString().toLowerCase();
          final address = location['address1'].toString().toLowerCase();
          final addressDis =
              (location['addressDis'] ?? '').toString().toLowerCase();
          final searchLower = query.toLowerCase();

          return name.contains(searchLower) ||
              address.contains(searchLower) ||
              addressDis.contains(searchLower);
        }).toList();

        filteredComLocations = widget.comLocations.where((location) {
          final name = location['name'].toString().toLowerCase();
          final address = location['address1'].toString().toLowerCase();
          final addressDis =
              (location['addressDis'] ?? '').toString().toLowerCase();
          final searchLower = query.toLowerCase();

          return name.contains(searchLower) ||
              address.contains(searchLower) ||
              addressDis.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    return GestureDetector(
      onTap: () => hideKeyboard(context),
      child: Column(
        children: [
          _searchBar(dataProvider),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.builder(
              itemCount: dataProvider.isCompany == false
                  ? filteredLocations
                      .length // widget.locations 대신 filteredLocations 사용
                  : filteredComLocations
                      .length, // widget.comLocations 대신 filteredComLocations 사용
              itemBuilder: (context, index) {
                final location = dataProvider.isCompany == false
                    ? filteredLocations[
                        index] // widget.locations 대신 filteredLocations 사용
                    : filteredComLocations[
                        index]; // widget.comLocations 대신 filteredComLocations 사용
                return _card(location, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  TextEditingController _searchText = TextEditingController();
  String selectedOption = '나의 내역';
  Widget _searchBar(DataProvider dataProvider) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Row(
        children: [
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: msgBackColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedOption,
                dropdownColor: msgBackColor,
                style: const TextStyle(
                  color: kOrangeBssetColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                items: ['나의 내역', '회사 내역'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue == '나의 내역') {
                    dataProvider.isCompanyState(false);
                  } else {
                    dataProvider.isCompanyState(true);
                  }
                  setState(() {});
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 56,
              child: TextFormField(
                controller: _searchText,
                autocorrect: false,
                maxLength: 30,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                minLines: 1,
                maxLines: 1,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  color: null,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  suffix: GestureDetector(
                    onTap: () async {},
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        KTextWidget(
                            text: '검색',
                            size: 16,
                            fontWeight: FontWeight.bold,
                            color: kGreenFontColor)
                      ],
                    ),
                  ),
                  counterStyle: const TextStyle(fontSize: 0),
                  errorStyle: const TextStyle(
                      fontSize: 0, height: 0), // 기본 에러 스타일 완전히 숨기기
                  errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: kRedColor)),
                  errorText: null, // 기본 에러 텍스트 비활성화
                  filled: true,
                  fillColor: msgBackColor,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 10,
                  ),
                  hintText: '상호명 또는 주소로 검색하세요.',
                  hintStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: kGreenFontColor, width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  _searchLocations(value); // 검색 함수 호출
                },
                validator: (value) {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(dynamic location, context) {
    final dw = MediaQuery.of(context).size.width;

    final addProvider = Provider.of<AddProvider>(context);
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        print(widget.callType);

        if (widget.callType != '화물') {
          if (widget.callType.contains('다구간')) {
            await _multiAdd(addProvider, location, context);
          } else {
            await _normalAdd(addProvider, location, context);
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8), color: msgBackColor),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: noState.withOpacity(0.2)),
                  child: const Center(
                    child: Icon(
                      Icons.location_searching,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KTextWidget(
                        text: location['name'],
                        size: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    Row(
                      children: [
                        const SizedBox(
                          width: 50,
                          child: KTextWidget(
                              text: '연락처',
                              size: 14,
                              fontWeight: null,
                              color: Colors.grey),
                        ),
                        KTextWidget(
                            text: location['phone'],
                            size: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ],
                    ),
                    SizedBox(
                      width: dw - 85,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 50,
                            child: KTextWidget(
                                text: '운송지',
                                size: 14,
                                fontWeight: null,
                                color: Colors.grey),
                          ),
                          if (location['addressDis'] != null &&
                              location['addressDis'] != '')
                            Expanded(
                              child: KTextWidget(
                                  text:
                                      '${location['address1']}, ${location['addressDis']}',
                                  size: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            )
                          else
                            Expanded(
                              child: KTextWidget(
                                  text: '${location['address1']}',
                                  size: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Future _multiAdd(AddProvider addProvider, dynamic location, context) async {
    final hashProvider = Provider.of<HashProvider>(context, listen: false);
    if (widget.type.contains('상차')) {
      print(addProvider.upCargos.length);
      addProvider.addUpSenderTypeState(null);
      addProvider.setLocationUpAddressState(
          location['address1'], location['address2']);
      addProvider.setLocationUpDisState(location['addressDis']);
      addProvider.setLocationUpNamePhoneState(
          location['name'], location['phone']);
      addProvider.setLocationUpNLatLngState(
          hashProvider.decLatLng(location['location']));

      // 수정된 부분: type 처리 방식 변경
      var rawData = location['type'].toString();
      List<String> locationTypeList = rawData
          .replaceAll('[', '')
          .replaceAll(']', '')
          .split(',')
          .map((e) => e.trim())
          .toList();
      addProvider.addUpSenderTypeState(locationTypeList);
    } else {
      addProvider.addDownSenderTypeState(null);
      addProvider.setLocationDownAddressState(
          location['address1'], location['address2']);
      addProvider.setLocationDownDisState(location['addressDis']);
      addProvider.setLocationDownNamePhoneState(
          location['name'], location['phone']);
      addProvider.setLocationDownNLatLngState(
          hashProvider.decLatLng(location['location']));

      // 수정된 부분: type 처리 방식 변경
      var rawData = location['type'].toString();
      List<String> locationTypeList = rawData
          .replaceAll('[', '')
          .replaceAll(']', '')
          .split(',')
          .map((e) => e.trim())
          .toList();
      addProvider.addDownSenderTypeState(locationTypeList);
    }
    Navigator.pop(context, {
      'name': location['name'],
      'phone': location['phone'],
      'addressDis': location['addressDis'],
    });
  }

  Future _normalAdd(AddProvider addProvider, dynamic location, context) async {
    final hashProvider = Provider.of<HashProvider>(context, listen: false);
    if (widget.type.contains('상차')) {
      print(addProvider.upCargos.length);
      addProvider.addUpSenderTypeState(null);

      addProvider.setLocationUpAddressState(
          location['address1'], location['address2']);
      addProvider.setLocationUpDisState(location['addressDis']);
      addProvider.setLocationUpNamePhoneState(
          location['name'], location['phone']);
      addProvider.setLocationUpNLatLngState(
          hashProvider.decLatLng(location['location']));

      var rawData = location['type'].toString();
      List<String> locationTypeList = rawData
          .replaceAll('[', '')
          .replaceAll(']', '')
          .split(',')
          .map((e) => e.trim())
          .toList();
      addProvider.addUpSenderTypeState(locationTypeList);
    } else {
      addProvider.addDownSenderTypeState(null);
      addProvider.setLocationDownAddressState(
          location['address1'], location['address2']);
      addProvider.setLocationDownDisState(location['addressDis']);
      addProvider.setLocationDownNamePhoneState(
          location['name'], location['phone']);
      addProvider.setLocationDownNLatLngState(
          hashProvider.decLatLng(location['location']));
      var rawData = location['type'].toString();
      List<String> locationTypeList = rawData
          .replaceAll('[', '')
          .replaceAll(']', '')
          .split(',')
          .map((e) => e.trim())
          .toList();
      addProvider.addDownSenderTypeState(locationTypeList);
    }
    Navigator.pop(context, {
      'name': location['name'],
      'phone': location['phone'],
      'addressDis': location['addressDis'],
    });
    /*   ScaffoldMessenger.of(context).showSnackBar(
        currentSnackBar('이전 내역 적용을 완료했습니다.\n실제 정보와 일치하는지 확인하세요.', context)); */
  }
}
