import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mixcall_normaluser_new/pages/weather/helper.dart';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class WeatherProvider extends ChangeNotifier {
  Map<String, List<WeatherForecast>> _regionForecasts = {};
  String _currentRegion = 'SEOUL'; // 기본값을 서울로 변경

  // 지역 정렬 순서 (서울부터 시작)
  final List<String> _regionOrder = [
    '서울', // 서울
    '인천', // 인천
    '수원', // 수원(경기)
    '강릉', // 강릉(강원)
    '청주', // 청주(충북)
    '대전', // 대전
    '세종', // 세종
    '전주', // 전주(전북)
    '목포', // 목포(전남)
    '광주', // 광주
    '포항', // 포항(경북)
    '대구', // 대구
    '창원', // 창원(경남)
    '부산', // 부산
    '울산', // 울산
    '제주', // 제주
    '춘천' // 춘천
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String get currentRegion => _currentRegion;

  Future<void> initializeData() async {
    await fetchWeatherData();
  }

  // 기상청 갱신 시간 (2, 5, 8, 11, 14, 17, 20, 23시) 중
  // 현재 시간에 해당하는 가장 최근 갱신 시간 구하기
  int _getLatestUpdateHour() {
    final now = DateTime.now();
    final currentHour = now.hour;

    if (currentHour < 2)
      return 23;
    else if (currentHour < 5)
      return 2;
    else if (currentHour < 8)
      return 5;
    else if (currentHour < 11)
      return 8;
    else if (currentHour < 14)
      return 11;
    else if (currentHour < 17)
      return 14;
    else if (currentHour < 20)
      return 17;
    else if (currentHour < 23)
      return 20;
    else
      return 23;
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 날씨 데이터 가져오기 (최적화된 버전)

// 날씨 데이터 가져오기 (최적화된 버전)

// 날씨 데이터 가져오기 (최적화된 버전)
  // 날씨 데이터 가져오기 (최적화된 버전)
  // 날씨 데이터 가져오기 (최적화된 버전)
  Future<void> fetchWeatherData() async {
    try {
      _isLoading = true;
      notifyListeners();
      print('날씨 데이터 확인 중...'); // 디버그 로그

      // 1. 현재 날짜와 최신 기상청 갱신 시간 확인
      final now = DateTime.now();
      final today = DateFormat('yyyyMMdd').format(now);
      final latestUpdateHour = _getLatestUpdateHour();

      print('오늘 날짜: $today, 최신 갱신 시간: $latestUpdateHour시');

      // 먼저 Firebase에서 데이터 확인하여 17개 지역이 모두 있는지 체크
      final DocumentSnapshot weatherDoc = await _firestore
          .collection('shortTermForecasts')
          .doc('latest_short_term')
          .get();

      bool needsUpdate = false;
      Timestamp? collectedAt;

      if (!weatherDoc.exists) {
        print('Firebase에 날씨 데이터가 없습니다.');
        needsUpdate = true;
      } else {
        // 문서 데이터 확인
        final data = weatherDoc.data() as Map<String, dynamic>;
        final List<dynamic> forecasts = data['forecasts'] as List<dynamic>;
        collectedAt = data['collectedAt'] as Timestamp?;

        print('서버에서 가져온 지역 수: ${forecasts.length}');

        // 모든 필수 지역이 있는지 확인
        final bool hasAllRegions = hasAllRequiredRegionsInForecast(forecasts);
        if (!hasAllRegions) {
          print('Firebase 데이터에 필수 지역이 부족합니다. 업데이트가 필요합니다.');
          needsUpdate = true;
        }
      }

      // 업데이트 필요하고 마지막 수집이 10분 이상 지났으면 Cloud Function 호출
      if (needsUpdate) {
        bool shouldTriggerUpdate = true;
        if (collectedAt != null) {
          final lastCollectedTime = collectedAt.toDate();
          final difference = now.difference(lastCollectedTime);

          if (difference.inMinutes < 10) {
            print(
                '마지막 데이터 수집이 ${difference.inMinutes}분 전에 이루어졌습니다. 업데이트를 건너뜁니다.');
            shouldTriggerUpdate = false;
          }
        }

        if (shouldTriggerUpdate) {
          print('Cloud Function 호출하여 데이터 업데이트 요청');
          await triggerWeatherUpdate();

          // 캐시 데이터 초기화
          await clearCachedData();

          // 잠시 대기 후 다시 데이터 요청 (Cloud Function이 처리할 시간 부여)
          await Future.delayed(Duration(seconds: 5));
          return await fetchWeatherData(); // 재귀적으로 다시 시도
        }
      }

      // 2. SharedPreferences에서 저장된 데이터 확인
      final prefs = await SharedPreferences.getInstance();
      final lastUpdateDate = prefs.getString('weatherLastUpdateDate');
      final lastUpdateHour = prefs.getInt('weatherLastUpdateHour');

      print('마지막 업데이트 날짜: $lastUpdateDate, 시간: $lastUpdateHour시');

      // 3. 데이터를 새로 가져와야 하는지 결정
      bool shouldFetchNewData = true;

      // 오늘 데이터이고, 최신 갱신 시간의 데이터를 이미 가지고 있는 경우
      if (lastUpdateDate == today && lastUpdateHour == latestUpdateHour) {
        print('오늘 $latestUpdateHour시 데이터가 이미 있습니다. 캐시 데이터를 확인합니다.');
        final cachedData = prefs.getString('weatherData');

        if (cachedData != null && cachedData.isNotEmpty) {
          try {
            // 캐시된 데이터 복원
            final Map<String, dynamic> decodedData = jsonDecode(cachedData);

            // 데이터 구조 형태로 변환 (대체 방식)
            _regionForecasts = {};
            decodedData.forEach((region, forecastsJson) {
              _regionForecasts[region] = (forecastsJson as List)
                  .map((item) => WeatherForecast.fromJson(
                      Map<String, dynamic>.from(item), region))
                  .toList();
            });

            print('캐시 데이터 로드 성공: ${_regionForecasts.length}개 지역');
            print('로드된 지역: ${_regionForecasts.keys.join(", ")}');

            // 캐시된 데이터에 모든 지역이 있으면 새로 가져오지 않음
            if (hasAllRequiredRegions()) {
              shouldFetchNewData = false;
            } else {
              print('캐시된 데이터에 일부 지역이 누락되었습니다. 새로 가져옵니다.');
            }
          } catch (e) {
            print('캐시 데이터 파싱 오류, 새로운 데이터를 가져옵니다: $e');
          }
        } else {
          print('캐시 데이터가 없습니다. 새로운 데이터를 가져옵니다.');
        }
      } else {
        print('최신 날씨 데이터가 필요합니다. Firebase에서 데이터를 가져옵니다.');
      }

      // 4. 필요한 경우 Firebase에서 최신 데이터 가져오기
      if (shouldFetchNewData) {
        print('Firebase에서 날씨 데이터 요청 중...');

        // 이미 위에서 데이터를 확인했으므로 다시 가져올 필요가 없다면 재활용
        final data = weatherDoc.data() as Map<String, dynamic>;
        final List<dynamic> forecasts = data['forecasts'] as List<dynamic>;

        // 기존 데이터 삭제 후 새 데이터로 교체
        _regionForecasts.clear();

        // 지역별로 데이터 처리
        for (var forecast in forecasts) {
          final city = forecast['city'] as String;
          final List<dynamic> cityForecasts =
              forecast['forecasts'] as List<dynamic>;
          print('지역 $city의 예보 수: ${cityForecasts.length}개');

          // 새 지역 추가
          if (!_regionForecasts.containsKey(city)) {
            _regionForecasts[city] = [];
          }

          // 해당 지역의 예보 데이터 추가
          for (var forecastData in cityForecasts) {
            _regionForecasts[city]?.add(WeatherForecast.fromFirestore(
                forecastData as Map<String, dynamic>, city));
          }
        }

        print('처리된 지역: ${_regionForecasts.keys.join(', ')}');

        // 5. 새로 가져온 데이터를 캐시에 저장
        try {
          // 데이터 직렬화
          Map<String, List<Map<String, dynamic>>> serializedData = {};
          _regionForecasts.forEach((region, forecasts) {
            serializedData[region] = forecasts.map((f) => f.toJson()).toList();
          });

          // SharedPreferences에 저장
          await prefs.setString('weatherData', jsonEncode(serializedData));
          await prefs.setString('weatherLastUpdateDate', today);
          await prefs.setInt('weatherLastUpdateHour', latestUpdateHour);

          print('$today $latestUpdateHour시 데이터를 캐시에 저장했습니다.');
        } catch (e) {
          print('데이터 캐싱 오류: $e');
        }
      }
    } catch (e) {
      print('날씨 데이터 가져오기 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

// 필요한 모든 지역이 로드된 데이터에 있는지 확인
  bool hasAllRequiredRegions() {
    // 모든 지역이 존재하는지 확인
    for (String region in _regionOrder) {
      if (!_regionForecasts.containsKey(region) ||
          _regionForecasts[region]?.isEmpty == true) {
        print('누락된 지역: $region');
        return false; // 하나라도 없거나 비어있다면 false
      }
    }
    return true; // 모든 지역이 있다면 true
  }

// Firebase에서 가져온 데이터에 모든 필수 지역이 있는지 확인
  bool hasAllRequiredRegionsInForecast(List<dynamic> forecasts) {
    // 가져온 지역 목록
    final Set<String> fetchedRegions = {};
    for (var forecast in forecasts) {
      fetchedRegions.add(forecast['city'] as String);
    }

    // 필요한 모든 지역이 있는지 확인
    for (String region in _regionOrder) {
      if (!fetchedRegions.contains(region)) {
        print('Firebase 데이터에서 누락된 지역: $region');
        return false;
      }
    }
    return true;
  }

// 날씨 데이터 업데이트 함수 (Cloud Function 호출)
  Future<void> triggerWeatherUpdate() async {
    try {
      print('Cloud Function 호출: update_weather');
      final response = await http.get(Uri.parse(
          'https://us-central1-mixcall.cloudfunctions.net/update_weather'));

      if (response.statusCode == 200) {
        print('날씨 데이터 업데이트 요청 성공: ${response.body}');
      } else {
        print('날씨 데이터 업데이트 요청 실패: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('날씨 데이터 업데이트 요청 오류: $e');
    }
  }

  // 지역 변경
  void changeRegion(String region) {
    _currentRegion = region;
    notifyListeners();
  }

  // 현재 선택된 지역의 예보 목록
  List<WeatherForecast> get currentRegionForecasts =>
      _regionForecasts[_currentRegion] ?? [];

  // 현재 지역의 날씨
  WeatherForecast? get currentWeather =>
      currentRegionForecasts.isNotEmpty ? currentRegionForecasts.first : null;

  // 날짜별로 그룹화된 예보
  Map<String, List<WeatherForecast>> get dailyForecasts {
    final forecasts = currentRegionForecasts;
    return groupBy(forecasts, (WeatherForecast f) => f.date);
  }

  // 정렬된 사용 가능한 지역 목록
  List<String> get availableRegions {
    // 데이터가 있는 지역 목록
    final regions = _regionForecasts.keys.toList();

    // 사전 정의된 순서에 따라 정렬
    return _regionOrder.where((region) => regions.contains(region)).toList();
  }

  // 특정 날짜의 최고/최저 기온
  Map<String, int> getRegionDayTemperatures(String region, String date) {
    print('지역 $region, 날짜 $date의 기온 데이터 확인'); // 디버그용

    final dayForecasts = _regionForecasts[region]
            ?.where((forecast) => forecast.date == date)
            .toList() ??
        [];

    if (dayForecasts.isEmpty) {
      return {'max': 0, 'min': 0};
    }

    final temperatures = dayForecasts.map((e) => e.temperature).toList();

    return {
      'max': temperatures.reduce(max),
      'min': temperatures.reduce(min),
    };
  }

  // 특정 지역의 현재 날씨 가져오기
  WeatherForecast? getRegionWeather(String region) {
    final forecasts = _regionForecasts[region] ?? [];
    if (forecasts.isEmpty) return null;

    // 현재 날짜와 시간 가져오기
    final now = DateTime.now();
    final currentDate = DateFormat('yyyyMMdd').format(now); // YYYYMMDD 형식
    final currentHour = DateFormat('HHmm').format(now); // HHMM 형식

    print('현재 날짜: $currentDate, 현재 시간: $currentHour'); // 디버그용

    // 현재 날짜의 예보만 필터링
    final todayForecasts =
        forecasts.where((f) => f.date == currentDate).toList();

    print('오늘 예보 개수: ${todayForecasts.length}'); // 디버그용

    if (todayForecasts.isEmpty) {
      print('오늘 예보 데이터가 없습니다. 첫번째 예보를 사용합니다.'); // 디버그용
      return forecasts.first; // 데이터가 없으면 첫 번째 예보 반환
    }

    // 현재 시간과 가장 가까운 예보 찾기
    final closest = todayForecasts.reduce((a, b) {
      final aDiff = (int.parse(a.time) - int.parse(currentHour)).abs();
      final bDiff = (int.parse(b.time) - int.parse(currentHour)).abs();
      return aDiff < bDiff ? a : b;
    });

    print('선택된 예보 시간: ${closest.time}'); // 디버그용
    return closest;
  }

  // 모든 지역의 현재 날씨 데이터 가져오기
  Map<String, WeatherForecast?> getAllRegionsCurrentWeather() {
    Map<String, WeatherForecast?> result = {};
    for (var region in availableRegions) {
      result[region] = getRegionWeather(region);
    }
    return result;
  }

  // 특정 지역의 3일간 예보 가져오기
  Map<String, List<WeatherForecast>> getThreeDaysForecast(String region) {
    final forecasts = _regionForecasts[region] ?? [];
    if (forecasts.isEmpty) return {};

    // String 날짜를 DateTime으로 변환하는 함수
    DateTime parseDate(String yyyymmdd) {
      final year = int.parse(yyyymmdd.substring(0, 4));
      final month = int.parse(yyyymmdd.substring(4, 6));
      final day = int.parse(yyyymmdd.substring(6, 8));
      return DateTime(year, month, day);
    }

    // 날짜별로 그룹화 (String 날짜 사용)
    final groupedForecasts = groupBy(forecasts, (WeatherForecast f) => f.date);

    // 날짜 문자열을 정렬
    final sortedDates = groupedForecasts.keys.toList()
      ..sort((a, b) {
        final dateA = parseDate(a);
        final dateB = parseDate(b);
        return dateA.compareTo(dateB);
      });

    // 처음 3일치만 선택
    final threeDays = sortedDates.take(3).toList();

    return Map.fromEntries(
        threeDays.map((date) => MapEntry(date, groupedForecasts[date]!)));
  }

  // 날짜 포맷팅 헬퍼 함수
  String formatDate(String yyyymmdd) {
    final year = int.parse(yyyymmdd.substring(0, 4));
    final month = int.parse(yyyymmdd.substring(4, 6));
    final day = int.parse(yyyymmdd.substring(6, 8));

    return '$month월 $day일';
  }

  // 캐시 데이터 강제로 초기화 (디버깅용)
  Future<void> clearCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('weatherData');
    await prefs.remove('weatherLastUpdateDate');
    await prefs.remove('weatherLastUpdateHour');
    print('날씨 캐시 데이터가 초기화되었습니다.');
  }
}
