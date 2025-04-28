import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/sidePage/state_page/multi/multi_main.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/service/future_service.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/bottomSheet.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/image_dialog.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

Future<bool?> cargoInfo(
    context, Map<String, dynamic> cargo, dynamic data, int num) async {
  final upCargos = data['upCargos'];
  final downCargos = data['downCargos'];

  final totalTonUp = data['upCargos'].fold<double>(
      0.0,
      (double sum, dynamic cargo) =>
          sum + (cargo['cargoWe']?.toDouble() ?? 0.0));

  final totalTonDown = data['downCargos'].fold<double>(
      0.0,
      (double sum, dynamic cargo) =>
          sum + (cargo['cargoWe']?.toDouble() ?? 0.0));

  int selectedIndex = 0; // 현재 선택된 탭 인덱스

  return await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return BottomSheetWidget(
            contents: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Column(
              children: [
                SizedBox(
                  height: 550,
                  child: ContainedTabBarView(
                    initialIndex: 0,
                    onChange: (index) {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    tabs: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedIndex == 0
                              ? kBlueBssetColor.withOpacity(0.1)
                              : msgBackColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: KTextWidget(
                            text: upCargos.isEmpty
                                ? '상차 없음'
                                : '${upCargos.length}건, ${totalTonUp}톤 상차',
                            size: 16,
                            fontWeight: FontWeight.bold,
                            color: selectedIndex == 0
                                ? kBlueBssetColor
                                : Colors.grey,
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedIndex == 1
                              ? kRedColor.withOpacity(0.1)
                              : msgBackColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: KTextWidget(
                            text: downCargos.isEmpty
                                ? '하차 없음'
                                : '${downCargos.length}건, ${totalTonDown}톤 하차',
                            size: 16,
                            fontWeight: FontWeight.bold,
                            color: selectedIndex == 1 ? kRedColor : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                    tabBarProperties: TabBarProperties(
                      height: 48.0,
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.zero,
                      indicator: null,
                      indicatorColor:
                          selectedIndex == 1 ? kRedColor : kBlueBssetColor,
                      background: Container(
                        color: Colors.transparent, // 배경 투명으로 변경
                        // color: dialogColor, // 이전 코드
                      ),
                      unselectedLabelColor: Colors.grey,
                      unselectedLabelStyle: const TextStyle(fontWeight: null),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    views: [
                      UpList(data: data),
                      DownList(data: data),
                    ],
                  ),
                ),
                // const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: noState),
                          child: const Center(
                            child: RotatedBox(
                              quarterTurns: 1,
                              child: Icon(
                                Icons.double_arrow_rounded,
                                color: Colors.grey,
                              ),
                            ),
                          )),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        makePhoneCall(data['phone']);
                      },
                      child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: noState),
                          child: const Center(
                            child: RotatedBox(
                              quarterTurns: 1,
                              child: Icon(
                                Icons.phone,
                                color: Colors.grey,
                              ),
                            ),
                          )),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () async {
                        HapticFeedback.lightImpact();

                        Navigator.pop(context, true);
                      },
                      child: Container(
                          height: 48,
                          padding: const EdgeInsets.only(left: 35, right: 35),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: data['isDone'] == true
                                  ? noState
                                  : kGreenFontColor),
                          child: Center(
                              child: KTextWidget(
                                  text: '운송 완료',
                                  size: 16,
                                  fontWeight: FontWeight.bold,
                                  color: data['isDone'] == true
                                      ? Colors.grey
                                      : Colors.white))),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
      });
    },
  );
}

Future stateCom() async {}

class UpList extends StatelessWidget {
  final dynamic data;
  const UpList({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;
    return data['upCargos'].isEmpty
        ? Column(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info,
                      size: 50,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const KTextWidget(
                        text: '상차 목록이 없습니다.',
                        size: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)
                  ],
                ),
              ),
            ],
          )
        : Column(
            children: [
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: data['upCargos'].length,
                  itemBuilder: (context, index) {
                    final iniData = data['upCargos'][index];
                    return _boxState(iniData, '상차', dw, context);
                  },
                ),
              ),
            ],
          );
  }
}

class DownList extends StatelessWidget {
  final dynamic data;
  const DownList({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;
    return data['downCargos'].isEmpty
        ? Column(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info,
                      size: 50,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const KTextWidget(
                        text: '하차 목록이 없습니다.',
                        size: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)
                  ],
                ),
              ),
            ],
          )
        : Column(
            children: [
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: data['downCargos'].length,
                  itemBuilder: (context, index) {
                    final iniData = data['downCargos'][index];
                    return _boxState(iniData, '하차', dw, context);
                  },
                ),
              ),
            ],
          );
  }
}

Widget _boxState(dynamic inData, String call, double dw, context) {
  return Column(
    children: [
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: msgBackColor.withOpacity(0.5)),
        child: Row(
          children: [
            Container(
                width: 60,
                height: 60,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: noState.withOpacity(0.3)),
                child: inData['imgUrl'] == null || inData['imgUrl'] == 'null'
                    ? Center(
                        child: RotatedBox(
                            quarterTurns: call == '하차' ? 1 : 3,
                            child: Icon(
                              Icons.double_arrow_rounded,
                              color: call == '하차' ? kRedColor : kBlueBssetColor,
                            )),
                      )
                    : GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          showDialog(
                              context: context,
                              builder: (context) => ImageViewerDialog(
                                    networkUrl: inData['imgUrl'],
                                  ));
                        },
                        child: ClipRRect(
                          // 이미지에도 borderRadius 적용하기 위해 ClipRRect 사용
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            inData['imgUrl'].toString(),
                            fit: BoxFit.cover, // 여기서 BoxFit 변경
                            errorBuilder: (context, error, stackTrace) {
                              print('이미지 로드 에러: $error');
                              return const Center(
                                child: Text('이미지를 불러올 수 없습니다'),
                              );
                            },
                          ),
                        ),
                      )),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                KTextWidget(
                    text:
                        '${inData['cargoWe']}${inData['cargoWeType']}, ${call}',
                    size: 14,
                    fontWeight: FontWeight.bold,
                    color: call == '상차' ? kBlueBssetColor : kRedColor),
                if (inData['cbm'] != null && inData['cbm'] != 0)
                  KTextWidget(
                      text:
                          'cbm : ${inData['cbm']}, 가로 ${inData['garo']}m X 세로 ${inData['sero']}m X 높이 ${inData['hi']}m',
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
                  width: dw - 104,
                  child: KTextWidget(
                      text: inData['cargoType'].toString(),
                      size: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            )
          ],
        ),
      ),
    ],
  );
}
