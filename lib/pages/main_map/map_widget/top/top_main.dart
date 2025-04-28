import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/list/history_list/history.dart';

import 'package:flutter_mixcall_normaluser_new/pages/list/inuse_list/inuse_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/mainMenu/mainmenu_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/mainMenu/notificaton/notification.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/futurue_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/main_page.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/top/pick_top.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/new_add_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/weather/weather_main.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';

class TopMainWidget extends StatefulWidget {
  const TopMainWidget({super.key});

  @override
  State<TopMainWidget> createState() => _TopMainWidgetState();
}

class _TopMainWidgetState extends State<TopMainWidget> {
  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final mapProvider = Provider.of<MapProvider>(context);
    final dw = MediaQuery.of(context).size.width;
    final dh = MediaQuery.of(context).size.height;
    return AnimatedContainer(
      width: dw,
      height: dh * 0.29,
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.only(left: 8, right: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
          ],
          stops: //_state ? [0.5, 1] : [0.3, 1],
              [0.2, 1],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _cargoState(dataProvider)),
              //const Spacer(),
              const SizedBox(width: 10),
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationMainPage()),
                  );
                },
                child: Stack(
                  children: [
                    Image.asset(
                      'asset/img/bell.png',
                      width: 28,
                      height: 28,
                    ),
                    Positioned(
                        right: 0,
                        child: Container(
                          height: 5,
                          width: 5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: kGreenFontColor,
                          ),
                        ))
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const MainMenuPage()), // 이동할 페이지를 지정
                  );
                },
                child: Image.asset(
                  'asset/img/menu.png',
                  width: 28,
                  height: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _sideMenu(dataProvider),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WeatherMainPage()),
                  );
                },
                child: Container(
                  //margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.only(
                      top: 8, bottom: 8, right: 12, left: 12),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      //border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      color: Theme.of(context).cardColor),
                  child: Row(
                    children: [
                      Image.asset('asset/img/sun.png', width: 16),
                      SizedBox(width: 5),
                      KTextWidget(
                          text: '날씨 예보',
                          size: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)
                    ],
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  updateCameraCenter(
                      mapProvider.controller,
                      NLatLng(mapProvider.currentLivePosition!.latitude,
                          mapProvider.currentLivePosition!.longitude));
                },
                child: Container(
                  //margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.only(
                      top: 8, bottom: 8, right: 12, left: 12),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      //border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      color: Theme.of(context).cardColor),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.location_searching_rounded,
                        color: Colors.grey,
                        size: 16,
                      ),
                      SizedBox(width: 5),
                      KTextWidget(
                          text: '현위치',
                          size: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _sideMenu(DataProvider dataProvider) {
    final addProvider = Provider.of<AddProvider>(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // 가로 스크롤 설정
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
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
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.only(
                  top: 12, bottom: 12, right: 16, left: 16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  color: Theme.of(context).cardColor),
              child: const Center(
                child: Row(
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.grey,
                      size: 20,
                    ),
                    SizedBox(width: 3),
                    KTextWidget(
                        text: '신규 운송 등록',
                        size: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              //addProvider.addReset();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InUseCargoList()),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.only(
                  top: 12, bottom: 12, right: 16, left: 16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                      color: dataProvider.totalCargoList.isNotEmpty
                          ? kOrangeBssetColor.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.3)),
                  color: Theme.of(context).cardColor),
              child: Center(
                child: Row(
                  children: [
                    Icon(
                      Icons.online_prediction_sharp,
                      color: dataProvider.totalCargoList.isNotEmpty
                          ? kOrangeBssetColor
                          : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    KTextWidget(
                        text: '진행 중인 운송',
                        size: 16,
                        fontWeight: FontWeight.bold,
                        color: dataProvider.totalCargoList.isNotEmpty
                            ? kOrangeBssetColor
                            : Colors.grey),
                    const SizedBox(width: 8),
                    if (dataProvider.totalCargoList.isNotEmpty)
                      KTextWidget(
                          text: dataProvider.totalCargoList.length < 10
                              ? '0${dataProvider.totalCargoList.length}'
                              : dataProvider.totalCargoList.length.toString(),
                          size: 16,
                          fontWeight: FontWeight.bold,
                          color: kOrangeBssetColor)
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              //addProvider.addReset();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const HistoryListMain()),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.only(
                  top: 12, bottom: 12, right: 16, left: 16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  color: Theme.of(context).cardColor),
              child: const Center(
                child: Row(
                  children: [
                    Icon(Icons.history_sharp, color: Colors.grey, size: 20),
                    SizedBox(width: 5),
                    KTextWidget(
                        text: '나의 운송 내역',
                        size: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cargoState(DataProvider dataProvider) {
    final dw = MediaQuery.of(context).size.width;
    return Container(
      // height: 30,
      child: dataProvider.totalCargoList.length > 0
          ? ComTopState()
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 10),
                Image.asset(
                  'asset/img/pack.png',
                  width: 35,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const KTextWidget(
                        text: '운송중인 화물이 없습니다.',
                        size: 18,
                        fontWeight: FontWeight.bold,
                        lineHeight: 0,
                        color: Colors.white),
                    SizedBox(
                      width: dw - 147,
                      child: const KTextWidget(
                          text: '신규 운송을 요청하려면, 아래 버튼을 클릭하세요.',
                          size: 12,
                          overflow: TextOverflow.ellipsis,
                          lineHeight: 0,
                          fontWeight: null,
                          color: Colors.grey),
                    )
                  ],
                )
              ],
            ),
    );
  }
}
