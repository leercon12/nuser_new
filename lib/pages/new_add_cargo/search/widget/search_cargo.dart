import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/model/multi_cargo_add_model.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/multi_state/updown/cargo_dialog/multi_cargo.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/hashProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class SearchCargoPage extends StatefulWidget {
  final List<dynamic> cargos;
  final List<dynamic> comCargos;
  final String callType;
  final String type;
  const SearchCargoPage(
      {super.key,
      required this.cargos,
      required this.comCargos,
      required this.callType,
      required this.type});

  @override
  State<SearchCargoPage> createState() => _SearchCargoPageState();
}

class _SearchCargoPageState extends State<SearchCargoPage> {
  List<dynamic> filteredCargos = [];
  List<dynamic> filteredComCargos = [];

  @override
  void initState() {
    super.initState();
    // 초기값 설정
    filteredCargos = List.from(widget.cargos.reversed);
    filteredComCargos = List.from(widget.comCargos.reversed);
  }

  // 검색 함수
  void _searchCargos(String query) {
    setState(() {
      if (query.isEmpty) {
        // 검색어가 없으면 전체 리스트 보여주기
        filteredCargos = List.from(widget.cargos);
        filteredComCargos = List.from(widget.comCargos);
      } else {
        // 검색어가 있으면 필터링
        filteredCargos = widget.cargos.where((cargo) {
          final cargoType = cargo['cargoType'].toString().toLowerCase();
          final cargoWe = cargo['cargoWe'].toString().toLowerCase();
          final searchLower = query.toLowerCase();

          return cargoType.contains(searchLower) ||
              cargoWe.contains(searchLower);
        }).toList();

        filteredComCargos = widget.comCargos.where((cargo) {
          final cargoType = cargo['cargoType'].toString().toLowerCase();
          final cargoWe = cargo['cargoWe'].toString().toLowerCase();
          final searchLower = query.toLowerCase();

          return cargoType.contains(searchLower) ||
              cargoWe.contains(searchLower);
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
                  ? filteredCargos.length // widget.cargos 대신 filteredCargos 사용
                  : filteredComCargos
                      .length, // widget.comCargos 대신 filteredComCargos 사용
              itemBuilder: (context, index) {
                final location = dataProvider.isCompany == false
                    ? filteredCargos[
                        index] // widget.cargos 대신 filteredCargos 사용
                    : filteredComCargos[index];
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
                  hintText: '화물명 또는 설명으로 검색하세요.',
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
                  _searchCargos(value); // 검색 함수 호출
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
    final addProvider = Provider.of<AddProvider>(context);
    final dw = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        print(widget.callType);
        print(widget.type);
        if (widget.callType.contains('화물')) {
          if (widget.callType.contains('다구간')) {
            await _multiAdd(addProvider, location, context);
          } else if (widget.type == '기본') {
            final a = num.tryParse(location['cargoWe'].toString());
            addProvider.addCargoInfoState(location['cargoType']);
            addProvider.addCargoTonState(a as double);
            addProvider.addCargoCbmState((location['cbm'] as num).toDouble());
            addProvider.addCargoSizedState(
                (location['garo'] as num).toDouble(),
                (location['sero'] as num).toDouble(),
                (location['hi'] as num).toDouble());

            addProvider.resetImgUrlState(location['imgUrl']);
            Navigator.pop(context);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: EdgeInsets.only(left: 8, right: 8, bottom: 8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12), color: msgBackColor),
        child: Row(
          children: [
            Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: noState.withOpacity(0.3)),
                child:
                    location['imgUrl'] == null || location['imgUrl'] == 'null'
                        ? const Center(
                            child: Icon(
                              Icons.image,
                              color: Colors.grey,
                            ),
                          )
                        : ClipRRect(
                            // 이미지에도 borderRadius 적용하기 위해 ClipRRect 사용
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              location['imgUrl'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('이미지 로드 에러: $error');
                                return const Center(
                                  child: Text('이미지를 불러올 수 없습니다'),
                                );
                              },
                            ),
                          )),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                KTextWidget(
                    text: '${location['cargoWe']}${location['cargoWeType']}',
                    size: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                if (location['cbm'] != 0)
                  KTextWidget(
                      text:
                          'cbm : ${location['cbm']}, 가로 ${location['garo']}m X 세로 ${location['sero']}m X 높이 ${location['hi']}m',
                      size: 12,
                      fontWeight: null,
                      color: Colors.grey)
                else
                  const KTextWidget(
                      text: '화물 사이즈 정보 없음',
                      size: 12,
                      fontWeight: null,
                      color: Colors.grey),
                SizedBox(
                  width: dw - 100,
                  child: KTextWidget(
                      text: location['cargoType'].toString(),
                      size: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future _multiAdd(AddProvider addProvider, dynamic location, context) async {
    final hashProvider = Provider.of<HashProvider>(context, listen: false);
    final cargo = CargoInfo(
      id: generateAlphanumericId(),
      cargoType: location['cargoType'],
      cargoWeType: '톤', // 예: dropdownButton에서 선택된 값
      cargoWe: location['cargoWe'] != null
          ? num.tryParse(location['cargoWe'].toString())
          : null,
      cbm: (location['cbm'] == null || location['cbm'] == 0)
          ? null
          : location['cbm'],
      garo: (location['cbm'] == null || location['cbm'] == 0)
          ? null
          : location['garo'],
      sero: (location['cbm'] == null || location['cbm'] == 0)
          ? null
          : location['sero'],
      hi: (location['cbm'] == null || location['cbm'] == 0)
          ? null
          : location['hi'],
      imgUrl: location['imgUrl'] == null || location['imgUrl'] == ''
          ? null
          : location['imgUrl'],

      imgFile: null, // 이미지 선택 기능이 있는 경우
    );

    if (widget.type.contains('상차')) {
      addProvider.subUpAddCargo(cargo);
    } else {
      addProvider.subDownAddCargo(cargo);
    }
    Navigator.pop(context, {});
    /*  ScaffoldMessenger.of(context).showSnackBar(
        currentSnackBar('이전 내역 적용을 완료했습니다.\n실제 정보와 일치하는지 확인하세요.', context)); */
  }
}
