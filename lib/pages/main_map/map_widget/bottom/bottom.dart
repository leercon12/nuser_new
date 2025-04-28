import 'package:delayed_widget/delayed_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_mixcall_normaluser_new/pages/list/inuse_list/inuse_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/bottom/large_updown/la_updown.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/bottom/multi_state/multi_state.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/bottom/normal_state/short_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/bottom/return_state/return_state.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/new_add_main.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/service/future_service.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class BottomMainPage extends StatefulWidget {
  const BottomMainPage({super.key});

  @override
  State<BottomMainPage> createState() => _BottomMainPageState();
}

class _BottomMainPageState extends State<BottomMainPage> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (dataProvider.cargoList.isNotEmpty &&
          dataProvider.currentCargo == null) {
        dataProvider.setCurrentCargo(dataProvider.totalCargoList[0]);
        setState(() {});
      }
    });
  }

  int _previousListLength = 0;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dataProvider = Provider.of<DataProvider>(context);

    if (dataProvider.cargoList.isNotEmpty &&
        dataProvider.currentCargo == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        dataProvider.setCurrentCargo(dataProvider.totalCargoList[0]);
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Map<String, dynamic>? cargo;
  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;

    final dataProvider = Provider.of<DataProvider>(context);
    final addProvider = Provider.of<AddProvider>(context);

    return Stack(
      children: [
        if (dataProvider.currentCargo == null)
          SafeArea(
            child: GestureDetector(
              onTap: () {
                print(dataProvider.totalCargoList.length);
                HapticFeedback.lightImpact();
                addProvider.allReset();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NewAddMainPage(
                            callType: '',
                          )),
                );
              },
              child: Container(
                width: dw - 20,
                height: 56,
                margin: const EdgeInsets.only(
                    left: 10, right: 10, top: 10, bottom: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: kGreenFontColor),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 3),
                    KTextWidget(
                        text: '신규 운송 등록',
                        size: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)
                  ],
                ),
              ),
            ),
          ),
        if (dataProvider.currentCargo != null)
          AnimatedContainer(
            width: dw,
            height: dataProvider.isUp == false ? 160 : 330,
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.only(left: 8, right: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
                stops: [0.0, 0.9], // 0.8 지점부터 완전 불투명하게 됩니다
              ),
            ),
          ),
        if (dataProvider.currentCargo != null)
          Positioned(
            child: Column(
              children: [
                if (dataProvider.currentCargo!['senderType'] != '일반')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(
                                left: 8, right: 8, top: 4, bottom: 4),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: kOrangeBssetColor.withOpacity(0.2)),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.people_alt,
                                  color: kOrangeBssetColor,
                                  size: 12,
                                ),
                                SizedBox(width: 5),
                                KTextWidget(
                                    text: '소속 기업(단체) 등록',
                                    size: 12,
                                    fontWeight: FontWeight.bold,
                                    color: kOrangeBssetColor)
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (dataProvider.isUp == true) {
                      dataProvider.isUpState(false);
                    } else {
                      dataProvider.isUpState(true);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: dw - 16,
                    height: dataProvider.isUp == false ? 160 : 330,
                    margin: const EdgeInsets.only(left: 8, right: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30)),
                        color: msgBackColor),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: dataProvider.totalCargoList.length,
                      onPageChanged: (index) {
                        if (index < dataProvider.totalCargoList.length) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            dataProvider.setCurrentCargo(
                                dataProvider.totalCargoList[index]);
                            setState(() {});
                          });
                        }
                      },
                      itemBuilder: (context, index) {
                        // 안전하게 인덱스 체크
                        if (index >= dataProvider.totalCargoList.length) {
                          return const SizedBox.shrink();
                        }
                        cargo = dataProvider.totalCargoList[index];
                        return _shortChState(dataProvider, dw, cargo!);
                      },
                    ),
                  ),
                ),
              ],
            ),
          )
      ],
    );
  }

  Widget _shortChState(
      DataProvider dataProvider, double dw, Map<String, dynamic> cargo) {
    // 데이터가 완전히 준비되었는지 확인
    if (dataProvider.currentCargo == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final transitType = dataProvider.currentCargo!['aloneType'];

    return Column(
      children: [
        if (transitType == '다구간')
          const BottomMultiMain()
        else if (transitType == '왕복')
          const BottomReturnStateMain()
        else
          const BottomNormalMain()
      ],
    );
  }

  //////////////////////////
  /// //////////////////////////
  ///  //////////////////////////
  ///  //////////////////////////
  ///  //////////////////////////
}

Widget cirDriver(double dw, Map<String, dynamic> cargo) {
  return Container(
      height: dw,
      width: dw,
      padding: cargo['pickUserUid'] == null
          ? const EdgeInsets.all(10)
          : const EdgeInsets.all(2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: noState.withOpacity(0.5)),
      child: cargo['pickUserUid'] == null
          ? ClipRRect(
              // 이미지에도 borderRadius 적용하기 위해 ClipRRect 사용
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              child: Image.asset(
                'asset/img/logo.png',
                // fit: BoxFit.fitHeight, // 여기서 BoxFit 변경
                errorBuilder: (context, error, stackTrace) {
                  print('이미지 로드 에러: $error');
                  return const Center(
                    child: Text('이미지를 불러올 수 없습니다'),
                  );
                },
              ),
            )
          : ClipRRect(
              // 이미지에도 borderRadius 적용하기 위해 ClipRRect 사용
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              child: Image.network(
                cargo['driverPhoto'].toString(),
                // fit: BoxFit.fitHeight, // 여기서 BoxFit 변경
                errorBuilder: (context, error, stackTrace) {
                  print('이미지 로드 에러: $error');
                  return const Center(
                    child: Text('이미지를 불러올 수 없습니다'),
                  );
                },
              ),
            ));
}
