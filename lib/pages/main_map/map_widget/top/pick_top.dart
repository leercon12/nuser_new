import 'dart:async';

import 'package:delayed_widget/delayed_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/list/inuse_list/inuse_main.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';

import 'package:provider/provider.dart';

class ComTopState extends StatefulWidget {
  const ComTopState({super.key});

  @override
  State<ComTopState> createState() => _ComTopStateState();
}

class _ComTopStateState extends State<ComTopState> {
  Timer? _timer;
  int _currentIndex = 0;
  // _availableStates 추가: 기본적으로 모든 상태 포함
  List<int> _availableStates = [0, 1, 2, 3];

  @override
  void initState() {
    super.initState();
    _setupTimer();
  }

  void _setupTimer() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        // 사용 가능한 상태 리스트의 범위 내에서 순환
        _currentIndex = (_currentIndex + 1) % _availableStates.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    // 상태 업데이트 함수 활성화
    _updateAvailableStates(dataProvider);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        //addProvider.addReset();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const InUseCargoList()),
        );
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: _buildContent(dataProvider),
      ),
    );
  }

  // 코멘트 해제 및 수정
  void _updateAvailableStates(DataProvider dataProvider) {
    _availableStates = [];

    // 오늘 화물 목록이 있는지 확인
    if (dataProvider.cargoList.isNotEmpty ||
        dataProvider.companyCargoList.isNotEmpty) {
      _availableStates.add(0);
    }

    // 내일 화물 목록이 있는지 확인
    if (countCargosTomorrow(dataProvider.cargoList) > 0 ||
        countCargosTomorrow(dataProvider.companyCargoList) > 0) {
      _availableStates.add(1);
    }

    // 미래 화물 목록이 있는지 확인
    if (countCargosAfterTomorrow(dataProvider.cargoList) > 0 ||
        countCargosAfterTomorrow(dataProvider.companyCargoList) > 0) {
      _availableStates.add(2);
    }

    // 최종 목적지는 항상 포함
    _availableStates.add(3);

    // 현재 인덱스가 유효한지 확인하고 조정
    if (_availableStates.isEmpty) {
      // 상태가 없는 경우 기본 상태 추가
      _availableStates.add(3);
    }

    if (_currentIndex >= _availableStates.length) {
      _currentIndex = 0;
    }
  }

  Widget _buildContent(DataProvider dataProvider) {
    // _availableStates가 비어있지 않은지 확인
    if (_availableStates.isEmpty) {
      _updateAvailableStates(dataProvider);
    }

    int currentState = _availableStates[_currentIndex];
    return Container(
      key: ValueKey<int>(currentState),
      child: _getCurrentWidget(dataProvider, currentState),
    );
  }

  Widget _getCurrentWidget(DataProvider dataProvider, int state) {
    switch (state) {
      case 0:
        return _buildTodayWidget(dataProvider);
      case 1:
        return _buildTomorrowWidget(dataProvider);
      case 2:
        return _buildFuturewWidget(dataProvider);
      case 3:
        return _buildFinalDestinationWidget(dataProvider);
      default:
        return _buildFinalDestinationWidget(dataProvider);
    }
  }

  Widget _buildTodayWidget(DataProvider dataProvider) {
    return SizedBox(
      height: 29,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('asset/img/ic_my.png', width: 20),
          const SizedBox(width: 8),
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: KTextWidget(
                text: '개인',
                size: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(width: 8),
          KTextWidget(
              text: '0${dataProvider.cargoList.length}',
              size: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white),
          const SizedBox(width: 8),
          Container(height: 15, width: 2, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(width: 8),
          Image.asset('asset/img/company.png', width: 20),
          const SizedBox(width: 8),
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: KTextWidget(
                text: '기업',
                size: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(width: 8),
          KTextWidget(
              text: '0${dataProvider.companyCargoList.length}',
              size: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white),
          const SizedBox(width: 12),
          Container(
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: kGreenFontColor.withOpacity(0.3),
            ),
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
            child: const KTextWidget(
                text: '오늘',
                size: 15,
                fontWeight: FontWeight.bold,
                color: kGreenFontColor),
          )
        ],
      ),
    );
  }

  Widget _buildTomorrowWidget(DataProvider dataProvider) {
    return SizedBox(
      height: 29,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('asset/img/ic_my.png', width: 20),
          const SizedBox(width: 8),
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: KTextWidget(
                text: '개인',
                size: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(width: 8),
          KTextWidget(
              text: '0${countCargosTomorrow(dataProvider.cargoList)}',
              size: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white),
          const SizedBox(width: 8),
          Container(height: 15, width: 2, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(width: 8),
          Image.asset('asset/img/company.png', width: 20),
          const SizedBox(width: 8),
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: KTextWidget(
                text: '기업(단체)',
                size: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(width: 8),
          KTextWidget(
              text: '0${countCargosTomorrow(dataProvider.companyCargoList)}',
              size: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white),
          const SizedBox(width: 12),
          Container(
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: kOrangeAssetColor.withOpacity(0.3),
            ),
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
            child: const KTextWidget(
                text: '내일',
                size: 15,
                fontWeight: FontWeight.bold,
                color: kOrangeAssetColor),
          )
        ],
      ),
    );
  }

  Widget _buildFuturewWidget(DataProvider dataProvider) {
    return SizedBox(
      height: 29,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('asset/img/ic_my.png', width: 20),
          const SizedBox(width: 8),
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: KTextWidget(
                text: '개인',
                size: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(width: 8),
          KTextWidget(
              text: '0${countCargosAfterTomorrow(dataProvider.cargoList)}',
              size: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white),
          const SizedBox(width: 8),
          Container(height: 15, width: 2, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(width: 8),
          Image.asset('asset/img/company.png', width: 20),
          const SizedBox(width: 8),
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: KTextWidget(
                text: '기업(단체)',
                size: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(width: 8),
          KTextWidget(
              text:
                  '0${countCargosAfterTomorrow(dataProvider.companyCargoList)}',
              size: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white),
          const SizedBox(width: 12),
          Container(
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: kOrangeBssetColor.withOpacity(0.3),
            ),
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
            child: const KTextWidget(
                text: '예약',
                size: 15,
                fontWeight: FontWeight.bold,
                color: kOrangeBssetColor),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalDestinationWidget(DataProvider dataProvider) {
    final dw = MediaQuery.of(context).size.width;
    return SizedBox(
      height: 29,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.info,
            color: kBlueBssetColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: SizedBox(
              width: dw - 126,
              child: const KTextWidget(
                  text: '클릭하여 상세 정보를 확인하세요.',
                  overflow: TextOverflow.ellipsis,
                  size: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

// 내일인 화물만 개수를 세는 함수
  int countCargosTomorrow(List<dynamic> cargoList) {
    // 내일 날짜의 시작과 끝
    final tomorrow = DateTime.now().add(Duration(days: 1));
    final tomorrowStart = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    final tomorrowEnd = tomorrowStart
        .add(Duration(days: 1))
        .subtract(Duration(milliseconds: 1));

    // 내일인 화물만 카운트
    return _countItemsOnSpecificDay(cargoList, tomorrowStart, tomorrowEnd);
  }

// 내일 이후(내일 포함)의 화물 개수를 세는 함수
  int countCargosAfterTomorrow(List<dynamic> cargoList) {
    // 내일 날짜 (하루의 시작)
    final tomorrow = DateTime.now().add(Duration(days: 1));
    final tomorrowStart = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);

    // 내일 이후 화물 카운트
    return _countItemsAfterDate(cargoList, tomorrowStart);
  }

  // Helper function to safely convert any timestamp type to DateTime
  DateTime _convertToDateTime(dynamic timestamp) {
    if (timestamp == null) {
      return DateTime
          .now(); // Default fallback or handle null differently as needed
    }

    // If it's already a DateTime, return it
    if (timestamp is DateTime) {
      return timestamp;
    }

    // If it's a Firestore Timestamp
    if (timestamp.runtimeType.toString().contains('Timestamp')) {
      try {
        // Firestore Timestamp has toDate() method
        return timestamp.toDate();
      } catch (e) {
        print('Error converting Timestamp to DateTime: $e');
        return DateTime.now(); // Fallback
      }
    }

    // If it's a String, try to parse it
    if (timestamp is String) {
      try {
        return DateTime.parse(timestamp);
      } catch (e) {
        print('Error parsing date string: $e');
        return DateTime.now(); // Fallback
      }
    }

    // If it's a number (milliseconds since epoch)
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }

    // Default fallback for unknown types
    print('Unknown timestamp type: ${timestamp.runtimeType}');
    return DateTime.now();
  }

  int _countItemsOnSpecificDay(
      List<dynamic> cargoList, DateTime dayStart, DateTime dayEnd) {
    if (cargoList == null || cargoList.isEmpty) {
      return 0;
    }

    return cargoList.where((cargo) {
      // aloneType이 "왕복" 또는 "다구간"인 경우
      if (cargo['aloneType'] == "왕복" || cargo['aloneType'] == "다구간") {
        // locations 배열이 있고 비어있지 않은지 확인
        if (cargo['locations'] != null && cargo['locations'].isNotEmpty) {
          try {
            final firstDate =
                _convertToDateTime(cargo['locations'].first['date']);
            final lastDate =
                _convertToDateTime(cargo['locations'].last['date']);

            // 날짜가 해당 날짜에 있는지 확인
            return (firstDate.isAfter(dayStart) ||
                    firstDate.isAtSameMomentAs(dayStart)) &&
                (firstDate.isBefore(dayEnd) ||
                    firstDate.isAtSameMomentAs(dayEnd)) &&
                (lastDate.isAfter(dayStart) ||
                    lastDate.isAtSameMomentAs(dayStart)) &&
                (lastDate.isBefore(dayEnd) ||
                    lastDate.isAtSameMomentAs(dayEnd));
          } catch (e) {
            print('Date processing error: $e');
            return false;
          }
        }
      } else {
        // 다른 aloneType의 경우, upTime과 downTime 확인
        if (cargo['upTime'] != null && cargo['downTime'] != null) {
          try {
            final upTime = _convertToDateTime(cargo['upTime']);
            final downTime = _convertToDateTime(cargo['downTime']);

            // 날짜가 해당 날짜에 있는지 확인
            return (upTime.isAfter(dayStart) ||
                    upTime.isAtSameMomentAs(dayStart)) &&
                (upTime.isBefore(dayEnd) || upTime.isAtSameMomentAs(dayEnd)) &&
                (downTime.isAfter(dayStart) ||
                    downTime.isAtSameMomentAs(dayStart)) &&
                (downTime.isBefore(dayEnd) ||
                    downTime.isAtSameMomentAs(dayEnd));
          } catch (e) {
            print('Date processing error: $e');
            return false;
          }
        }
      }

      return false;
    }).length;
  }

// 특정 날짜 이후의 화물을 세는 헬퍼 함수
  int _countItemsAfterDate(List<dynamic> cargoList, DateTime dateStart) {
    if (cargoList == null || cargoList.isEmpty) {
      return 0;
    }

    return cargoList.where((cargo) {
      // aloneType이 "왕복" 또는 "다구간"인 경우
      if (cargo['aloneType'] == "왕복" || cargo['aloneType'] == "다구간") {
        // locations 배열이 있고 비어있지 않은지 확인
        if (cargo['locations'] != null && cargo['locations'].isNotEmpty) {
          try {
            final firstDate =
                _convertToDateTime(cargo['locations'].first['date']);
            final lastDate =
                _convertToDateTime(cargo['locations'].last['date']);

            // 날짜가 시작일 이후인지 확인
            return (firstDate.isAfter(dateStart) ||
                    firstDate.isAtSameMomentAs(dateStart)) &&
                (lastDate.isAfter(dateStart) ||
                    lastDate.isAtSameMomentAs(dateStart));
          } catch (e) {
            print('Date processing error: $e');
            return false;
          }
        }
      } else {
        // 다른 aloneType의 경우, upTime과 downTime 확인
        if (cargo['upTime'] != null && cargo['downTime'] != null) {
          try {
            final upTime = _convertToDateTime(cargo['upTime']);
            final downTime = _convertToDateTime(cargo['downTime']);

            // 날짜가 시작일 이후인지 확인
            return (upTime.isAfter(dateStart) ||
                    upTime.isAtSameMomentAs(dateStart)) &&
                (downTime.isAfter(dateStart) ||
                    downTime.isAtSameMomentAs(dateStart));
          } catch (e) {
            print('Date processing error: $e');
            return false;
          }
        }
      }

      return false;
    }).length;
  }
}
