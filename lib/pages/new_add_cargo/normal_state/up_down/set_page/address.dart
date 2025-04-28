import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/hashProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/sarchmap.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';

class AddressDialog extends StatefulWidget {
  final String callType;
  const AddressDialog({super.key, required this.callType});

  @override
  State<AddressDialog> createState() => _AddressDialogState();
}

class _AddressDialogState extends State<AddressDialog> {
  TextEditingController _searchText = TextEditingController();
  String? _sel = '1';
  bool _searchLoading = false;
  bool _noSerachInput = false;
  //List<SearchResult>? results;
  int _input = 0;
  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;
    final addProvider = Provider.of<AddProvider>(context);
    final mapProvider = Provider.of<MapProvider>(context);

    bool isUpDown = widget.callType.contains('상차');
    bool _isA = addProvider.setLocationUpAddress1 == null ||
        addProvider.setLocationUpAddress1 == '';
    bool _isB = addProvider.setLocationDownAddress1 == null ||
        addProvider.setLocationDownAddress1 == '';

    Color _isColor = widget.callType == '차고지'
        ? kGreenFontColor
        : widget.callType.contains('상차')
            ? kBlueBssetColor
            : kRedColor;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              KTextWidget(
                  text: widget.callType == '차고지' ? '차고지 주소 검색' : '주소 검색',
                  size: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              const Expanded(child: SizedBox()),
              GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.cancel,
                    color: Colors.grey,
                  )),
            ],
          ),
          const SizedBox(height: 18),
          _top(dw, _isColor, mapProvider),
          const SizedBox(height: 18),
          _secrhText(addProvider, _isColor),
        ],
      ),
    );
  }

  List<SearchResult>? results;
  Widget _top(double dw, Color _isColor, MapProvider mapProvider) {
    return SizedBox(
      width: dw,
      child: Row(
        children: [
          const Spacer(),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _sel = '1';
              _searchText.clear();
              setState(() {});
            },
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 17,
                  color: _sel == '1' ? _isColor : Colors.grey.withOpacity(0.5),
                ),
                const SizedBox(width: 5),
                KTextWidget(
                  text: '주소 검색',
                  size: 15,
                  fontWeight: FontWeight.bold,
                  color: _sel == '1' ? _isColor : Colors.grey,
                ),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _sel = '2';
              _searchText.clear();
              setState(() {});
            },
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 17,
                  color: _sel == '2' ? _isColor : Colors.grey.withOpacity(0.5),
                ),
                const SizedBox(width: 5),
                KTextWidget(
                    text: '상호 검색',
                    size: 15,
                    fontWeight: FontWeight.bold,
                    color: _sel == '2' ? _isColor : Colors.grey),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _sel = '3';
              _searchText.clear();
              setState(() {});
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MapAddressSearch(
                    callType: widget.callType,
                    nLatLng: NLatLng(mapProvider.currentLivePosition!.latitude,
                        mapProvider.currentLivePosition!.longitude),
                  ),
                ),
              );
            },
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 17,
                  color: _sel == '3' ? _isColor : Colors.grey.withOpacity(0.5),
                ),
                const SizedBox(width: 5),
                KTextWidget(
                    text: '지도 검색',
                    size: 15,
                    fontWeight: FontWeight.bold,
                    color: _sel == '3' ? _isColor : Colors.grey),
              ],
            ),
          ),
          const Spacer()
        ],
      ),
    );
  }

  Widget _secrhText(AddProvider addProvider, Color _isColor) {
    AddProvider _local = Provider.of<AddProvider>(context);
    return Column(
      children: [
        TextFormField(
          controller: _searchText,
          autocorrect: false,
          cursorColor: _isColor,
          maxLength: 30,
          minLines: 1,
          style: TextStyle(
              color: _searchLoading == true ? Colors.grey : null, fontSize: 16),
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            suffix: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    final _addProvider =
                        Provider.of<AddProvider>(context, listen: false);
                    if (_searchText.text.trim().length == 0) {
                      _noSerachInput = true;
                      setState(() {});
                    } else {
                      setState(() {
                        _noSerachInput = false;
                        _searchLoading = true;
                      });

                      if (widget.callType == '하차') {
                        addProvider.setLocationDownAddressState(null, null);
                      } else {
                        addProvider.setLocationUpAddressState(null, null);
                      }

                      if (_sel == '1') {
                        await _addProvider.search(searchData: _searchText.text);
                      } else {
                        addProvider
                            .keywordSearch(_searchText.text.trim())
                            .then((value) {
                          results = value;
                          print(results);

                          setState(() {});
                        });
                      }
                      //원미로 13번길 43
                      setState(() {
                        _searchLoading = false;
                      });
                    }
                  },
                  child: KTextWidget(
                      text: '검색',
                      size: 16,
                      fontWeight: FontWeight.bold,
                      color: _isColor),
                )
              ],
            ),
            //원미로 13번길 43
            counterText: '',
            hintText: _sel == '1' ? '지번 또는 도로명 주소 입력' : '상호(업체명 등)으로 주소 검색',
            hintStyle: const TextStyle(fontSize: 16),
            filled: true,
            fillColor: btnColor,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(16),
            ),
            focusedBorder: OutlineInputBorder(
              // 선택되었을 때 보덕색으로 표시됨
              borderSide: BorderSide(color: _isColor),
              borderRadius: BorderRadius.circular(16),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onChanged: (value) {
            setState(() {
              _input = _searchText.text.length;
            });
          },
        ),
        const SizedBox(height: 24),
        if (_local.data != null && _sel == '1') _sel1(),
        if (results != null && _sel == '2') _sel2()
      ],
    );
  }

  Widget _sel1() {
    final dw = MediaQuery.of(context).size.width;
    final addProvider = Provider.of<AddProvider>(context);
    final mapProvider = Provider.of<MapProvider>(context);
    final hashProvider = Provider.of<HashProvider>(context);

    AddProvider _local = Provider.of<AddProvider>(context);

    bool _isUpDown = widget.callType == '하차';
    bool _isA = addProvider.setLocationUpAddress1 == null ||
        addProvider.setLocationUpAddress1 == '';
    bool _isB = addProvider.setLocationDownAddress1 == null ||
        addProvider.setLocationDownAddress1 == '';
    bool _isC = _isUpDown == false ? _isA : _isB;
    return Column(
        children: List.generate(
      _local.data!['documents'].length,
      (index) => _local == null ||
              _local.data == null ||
              _local.data!['documents'] == null ||
              _local.data!['documents'].isEmpty ||
              _local.data!['documents'][index]['address'] == null ||
              _local.data!['documents'][index]['address']['address_name'] ==
                  null ||
              _local
                  .data!['documents'][index]['address']['address_name'].isEmpty
          ? const KTextWidget(
              text: '검색 결과가 없습니다.',
              size: 15,
              fontWeight: FontWeight.bold,
              color: kRedColor)
          : Container(
              width: dw,
              padding: const EdgeInsets.only(bottom: 10, left: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: dw - 90,
                        child: KTextWidget(
                          text:
                              '${_local.data!['documents'][index]['address']['address_name']}',
                          size: 16,
                          fontWeight: FontWeight.bold,
                          color: null,
                        ),
                      ),
                      SizedBox(
                        width: dw - 90,
                        child: KTextWidget(
                          text: '${_local.data!['documents'][index]['road_address']['address_name']}' +
                              ' ${_local.data!['documents'][index]['road_address']['building_name']}',
                          size: 12,
                          fontWeight: null,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const Expanded(child: SizedBox()),
                  GestureDetector(
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        if (widget.callType == '하차') {
                          addProvider.setLocationDownAddressState(
                              '${_local.data!['documents'][index]['address']['address_name']}',
                              '${_local.data!['documents'][index]['road_address']['address_name']}' +
                                  ' ${_local.data!['documents'][index]['road_address']['building_name']}');

                          addProvider.setLocationDownNLatLngState(NLatLng(
                            double.parse(_local.data!['documents'][index]
                                ['address']['y']),
                            double.parse(_local.data!['documents'][index]
                                ['address']['x']),
                          ));
                          _searchText.text =
                              addProvider.setLocationDownAddress1.toString();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MapAddressSearch(
                                callType: widget.callType,
                                nLatLng: NLatLng(
                                  double.parse(_local.data!['documents'][index]
                                      ['address']['y']),
                                  double.parse(_local.data!['documents'][index]
                                      ['address']['x']),
                                ),
                              ),
                            ),
                          );
                        } else {
                          addProvider.setLocationUpAddressState(
                              '${_local.data!['documents'][index]['address']['address_name']}',
                              '${_local.data!['documents'][index]['road_address']['address_name']}' +
                                  ' ${_local.data!['documents'][index]['road_address']['building_name']}');

                          addProvider.setLocationUpNLatLngState(NLatLng(
                            double.parse(_local.data!['documents'][index]
                                ['address']['y']),
                            double.parse(_local.data!['documents'][index]
                                ['address']['x']),
                          ));
                          //원미로 13번길 43 부천역 소사역

                          _searchText.text =
                              addProvider.setLocationUpAddress1.toString();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MapAddressSearch(
                                callType: widget.callType,
                                nLatLng: NLatLng(
                                  double.parse(_local.data!['documents'][index]
                                      ['address']['y']),
                                  double.parse(_local.data!['documents'][index]
                                      ['address']['x']),
                                ),
                              ),
                            ),
                          );
                        }
                        // Navigator.pop(context);
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: noState),
                        child: const Center(
                          child: KTextWidget(
                              text: '선택',
                              size: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                      )),
                ],
              ),
            ),
    ));
  }
  //원미로 13번길 43

  String? adsS;
  String? adsR;
  List? ads;
  NLatLng? _point;

  Widget _sel2() {
    final dw = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        if (results == [] || results!.isEmpty)
          const KTextWidget(
              text: '검색 결과가 없습니다.',
              size: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey)
        else
          Container(
            width: dw,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 5),
                  for (var result in results!)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: dw - 90,
                              child: Text(
                                result
                                    .title, // 또는 원하는 SearchResult의 필드를 여기에 넣으세요
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: null),
                              ),
                            ),
                            SizedBox(
                              width: dw - 90,
                              child: Text(
                                result
                                    .roadAddress, // 또는 원하는 SearchResult의 필드를 여기에 넣으세요
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: null,
                                    color: Colors.grey),
                              ),
                            ),
                            const SizedBox(height: 15),
                          ],
                        ),
                        const Expanded(child: SizedBox()),
                        GestureDetector(
                            onTap: () {
                              // 소사역 쿠팡
                              HapticFeedback.lightImpact();
                              ads = [];
                              print('++++++++++++');
                              print(result.mapx);
                              print(result.mapy);
                              _point = NLatLng(result.mapy, result.mapx);
                              setState(() {});
                              NLatLng convertedCoordinate =
                                  NLatLng(result.mapy, result.mapx);

                              NPoint(result.mapx, result.mapy);

                              NCameraUpdate cameraUpdate =
                                  NCameraUpdate.scrollAndZoomTo(
                                target: convertedCoordinate,
                                zoom: 15,
                              );
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => MapAddressSearch(
                                    callType: widget.callType,
                                    nLatLng: convertedCoordinate,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: noState),
                              child: const Center(
                                child: KTextWidget(
                                    text: '선택',
                                    size: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                              ),
                            )),
                      ],
                    ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
