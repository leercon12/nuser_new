import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:intl/intl.dart';

enum SkyCondition { clear, partlyCloudy, mostlyCloudy, cloudy, unknown }

enum PrecipitationType {
  none,
  rain,
  rainSnow,
  snow,
  shower,
  rainDrop,
  rainSnowDrop,
  snowDrop,
  unknown
}

class WeatherForecast {
  final String date;
  final String time;
  final int temperature;
  final int humidity;
  final String precipitation;
  final SkyCondition skyCondition;
  final PrecipitationType precipType;
  final double wind;
  final String region; // 지역 추가

  WeatherForecast({
    required this.date,
    required this.time,
    required this.temperature,
    required this.humidity,
    required this.precipitation,
    required this.skyCondition,
    required this.precipType,
    required this.wind,
    required this.region,
  });

  static SkyCondition _getSkyCondition(int sky) {
    switch (sky) {
      case 1:
        return SkyCondition.clear;
      case 2:
        return SkyCondition.partlyCloudy;
      case 3:
        return SkyCondition.mostlyCloudy;
      case 4:
        return SkyCondition.cloudy;
      default:
        return SkyCondition.unknown;
    }
  }

  static PrecipitationType _getPrecipType(int pty) {
    switch (pty) {
      case 0:
        return PrecipitationType.none;
      case 1:
        return PrecipitationType.rain;
      case 2:
        return PrecipitationType.rainSnow;
      case 3:
        return PrecipitationType.snow;
      case 4:
        return PrecipitationType.shower;
      case 5:
        return PrecipitationType.rainDrop;
      case 6:
        return PrecipitationType.rainSnowDrop;
      case 7:
        return PrecipitationType.snowDrop;
      default:
        return PrecipitationType.unknown;
    }
  }

  factory WeatherForecast.fromFirestore(
      Map<String, dynamic> json, String region) {
    return WeatherForecast(
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      temperature: int.parse(json['temperature'] ?? '0'),
      humidity: int.parse(json['humidity'] ?? '0'),
      precipitation: json['precipitation'] ?? '0',
      skyCondition: _getSkyCondition(int.parse(json['sky'] ?? '0')),
      precipType: _getPrecipType(int.parse(json['pty'] ?? '0')),
      wind: double.parse(json['wind'] ?? '0'),
      region: region,
    );
  }

  // JSON으로 직렬화 (SharedPreferences 저장용)
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'time': time,
      'temperature': temperature.toString(),
      'humidity': humidity.toString(),
      'precipitation': precipitation,
      'sky': _getSkyIndex().toString(),
      'pty': _getPtyIndex().toString(),
      'wind': wind.toString(),
      'region': region,
    };
  }

  // JSON에서 객체 복원 (SharedPreferences 로드용)
  factory WeatherForecast.fromJson(Map<String, dynamic> json, String region) {
    return WeatherForecast(
      date: json['date'] as String,
      time: json['time'] as String,
      temperature: int.parse(json['temperature'] as String),
      humidity: int.parse(json['humidity'] as String),
      precipitation: json['precipitation'] as String,
      skyCondition: _getSkyCondition(int.parse(json['sky'] as String)),
      precipType: _getPrecipType(int.parse(json['pty'] as String)),
      wind: double.parse(json['wind'] as String),
      region: region,
    );
  }

  // SkyCondition을 인덱스로 변환
  int _getSkyIndex() {
    switch (skyCondition) {
      case SkyCondition.clear:
        return 1;
      case SkyCondition.partlyCloudy:
        return 2;
      case SkyCondition.mostlyCloudy:
        return 3;
      case SkyCondition.cloudy:
        return 4;
      case SkyCondition.unknown:
        return 0;
    }
  }

  // PrecipitationType을 인덱스로 변환
  int _getPtyIndex() {
    switch (precipType) {
      case PrecipitationType.none:
        return 0;
      case PrecipitationType.rain:
        return 1;
      case PrecipitationType.rainSnow:
        return 2;
      case PrecipitationType.snow:
        return 3;
      case PrecipitationType.shower:
        return 4;
      case PrecipitationType.rainDrop:
        return 5;
      case PrecipitationType.rainSnowDrop:
        return 6;
      case PrecipitationType.snowDrop:
        return 7;
      case PrecipitationType.unknown:
        return 9;
    }
  }

  String getWeatherDescription() {
    String skyDesc = '';
    switch (skyCondition) {
      case SkyCondition.clear:
        skyDesc = '맑음';
      case SkyCondition.partlyCloudy:
        skyDesc = '구름조금';
      case SkyCondition.mostlyCloudy:
        skyDesc = '구름많음';
      case SkyCondition.cloudy:
        skyDesc = '흐림';
      case SkyCondition.unknown:
        skyDesc = '알수없음';
    }

    String precipDesc = '';
    switch (precipType) {
      case PrecipitationType.none:
        return skyDesc;
      case PrecipitationType.rain:
        precipDesc = '비';
      case PrecipitationType.rainSnow:
        precipDesc = '비/눈';
      case PrecipitationType.snow:
        precipDesc = '눈';
      case PrecipitationType.shower:
        precipDesc = '소나기';
      case PrecipitationType.rainDrop:
        precipDesc = '빗방울';
      case PrecipitationType.rainSnowDrop:
        precipDesc = '빗방울/눈날림';
      case PrecipitationType.snowDrop:
        precipDesc = '눈날림';
      case PrecipitationType.unknown:
        return skyDesc;
    }

    return '$skyDesc, $precipDesc';
  }

  String getWeatherImage() {
    if (precipType != PrecipitationType.none) {
      switch (precipType) {
        case PrecipitationType.rain:
        case PrecipitationType.rainDrop:
          return 'asset/img/wa_4.png';
        case PrecipitationType.snow:
        case PrecipitationType.snowDrop:
          return 'asset/img/wa_3.png';
        case PrecipitationType.rainSnow:
        case PrecipitationType.rainSnowDrop:
          return 'asset/img/wa_2.png';
        case PrecipitationType.shower:
          return 'asset/img/wa_1.png';
        default:
          break;
      }
    }

    switch (skyCondition) {
      case SkyCondition.clear:
        return _isDayTime() ? 'asset/img/we_1.png' : 'asset/img/we_1.png';
      case SkyCondition.partlyCloudy:
        return _isDayTime() ? 'asset/img/we_2.png' : 'asset/img/we_2.png';
      case SkyCondition.mostlyCloudy:
        return 'asset/img/we_3.png';
      case SkyCondition.cloudy:
        return 'asset/img/we_4.png';
      default:
        return 'asset/img/wa_dea.png';
    }
  }

  bool _isDayTime() {
    int hourOfDay = int.parse(time.substring(0, 2));
    return hourOfDay >= 6 && hourOfDay < 18;
  }

  Widget getWeatherIcon({double size = 32.0}) {
    final imagePath = getWeatherImage();
    print('이미지 경로: $imagePath'); // 디버그용

    return Image.asset(
      imagePath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        print('이미지 로드 에러: $error'); // 에러 확인용
        return Icon(Icons.cloud_queue, size: size); // 에러시 기본 아이콘
      },
    );
  }
}

String formatTimestamp99(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();

  // DateFormat을 사용하여 기본 포맷팅
  DateFormat dateFormat = DateFormat('MM월 dd일 (E)', 'en_US');

  String formattedDate = dateFormat.format(dateTime);

  // 영어 요일을 한국어로 변환
  Map<String, String> dayTranslations = {
    'Sun': '일',
    'Mon': '월',
    'Tue': '화',
    'Wed': '수',
    'Thu': '목',
    'Fri': '금',
    'Sat': '토',
  };

  dayTranslations.forEach((englishDay, koreanDay) {
    formattedDate = formattedDate.replaceAll(englishDay, koreanDay);
  });

  return formattedDate;
}

String formatDateTime99(DateTime dateTime) {
  // DateFormat을 사용하여 기본 포맷팅
  DateFormat dateFormat = DateFormat('MM월 dd일 (E)', 'en_US');

  String formattedDate = dateFormat.format(dateTime);

  // 영어 요일을 한국어로 변환
  Map<String, String> dayTranslations = {
    'Sun': '일',
    'Mon': '월',
    'Tue': '화',
    'Wed': '수',
    'Thu': '목',
    'Fri': '금',
    'Sat': '토',
  };

  dayTranslations.forEach((englishDay, koreanDay) {
    formattedDate = formattedDate.replaceAll(englishDay, koreanDay);
  });

  return formattedDate;
}

// 미니멀한 정보 행 위젯
Widget buildMinimalInfoRow({
  required IconData icon,
  required String title,
  required String value,
  FontWeight? fontWeight,
  bool? isSmall,
  Color? valueColor,
}) {
  return Row(
    children: [
      const SizedBox(width: 10),
      Icon(icon, size: isSmall == true ? 14 : 16, color: Colors.grey),
      const SizedBox(width: 5),
      KTextWidget(
        text: title,
        size: 14,
        fontWeight: null,
        color: Colors.grey,
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Container(
          padding: isSmall == true
              ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
              : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black26.withOpacity(0.05),
            borderRadius: BorderRadius.circular(6),
          ),
          child: KTextWidget(
            text: value,
            size: 14,
            textAlign: TextAlign.end,
            fontWeight: fontWeight == null ? null : fontWeight,
            color: valueColor ?? Colors.white,
          ),
        ),
      ),
    ],
  );
}

String formatTime(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  // 날짜 형식 지정 (24시간 형식)
  DateFormat dateFormat = DateFormat('HH시 : mm분'); // 'HH'는 24시간 형식을 의미
  return dateFormat.format(dateTime);
}

String formatTimeEnd(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  // 날짜 형식 지정 (24시간 형식)
  DateFormat dateFormat = DateFormat('HH : mm'); // 'HH'는 24시간 형식을 의미
  return dateFormat.format(dateTime);
}

// formatTime 함수도 DateTime을 받도록 수정 (기존 함수가 Timestamp를 사용하는 경우)
String formatTime2(DateTime dateTime) {
  return DateFormat('HH:mm').format(dateTime);
}

// formatTimeEnd 함수도 DateTime을 받도록 수정
String formatTimeEnd2(DateTime dateTime) {
  return DateFormat('HH:mm').format(dateTime);
}

String calculateDateStatus2(DateTime selDay) {
  // 오늘인지 확인

  DateTime now = DateTime.now();
  if (selDay.year == now.year &&
      selDay.month == now.month &&
      selDay.day == now.day) {
    return 'today';
  }
  // 내일인지 확인
  else if (selDay.year == now.year &&
      selDay.month == now.month &&
      selDay.day == now.day + 1) {
    return 'tmm';
  }
  // 오늘 이전 날짜인지 확인
  else if (selDay.isBefore(DateTime(now.year, now.month, now.day))) {
    return 'ex';
  }
  // 오늘과 내일 이후의 날짜
  else {
    return 'book';
  }
}

Widget buildTag(String text, Color textColor, Color bgColor, {IconData? icon}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(4),
      color: bgColor,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 13,
            color: textColor,
          ),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: KTextWidget(
            text: text,
            size: 13,
            overflow: TextOverflow.ellipsis,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    ),
  );
}

// 날짜 상태 표시 태그
Widget dateStateTag(String state) {
  Color bgColor;
  Color textColor;
  String text;

  switch (state) {
    case 'today':
      bgColor = kGreenFontColor.withOpacity(0.2);
      textColor = kGreenFontColor;
      text = '오늘';
      break;
    case 'tmm':
      bgColor = kBlueBssetColor.withOpacity(0.2);
      textColor = kBlueBssetColor;
      text = '내일';
      break;
    case 'ex':
      bgColor = kRedColor.withOpacity(0.2);
      textColor = kRedColor;
      text = '만료';
      break;
    case 'book':
      bgColor = kOrangeBssetColor.withOpacity(0.2);
      textColor = kOrangeBssetColor;
      text = '예약';
      break;
    default:
      return const SizedBox.shrink();
  }

  return KTextWidget(
    text: '$text, ',
    size: 12,
    fontWeight: null,
    color: textColor,
  );
}

Widget timeState(String type, String updown, dynamic start, dynamic end,
    String? aloneType, String etc) {
  // Timestamp 또는 DateTime 처리를 위한 헬퍼 함수
  DateTime? getDateTime(dynamic value) {
    if (value == null) return null;
    return value is Timestamp
        ? value.toDate()
        : (value is DateTime ? value : null);
  }

  // start와 end를 DateTime으로 변환
  final DateTime? startDateTime = getDateTime(start);
  final DateTime? endDateTime = getDateTime(end);

  return Stack(
    children: [
      if (type == '미정')
        KTextWidget(
            text: '${updown}시간 미정',
            size: 12,
            textAlign: TextAlign.end,
            fontWeight: null,
            overflow: TextOverflow.ellipsis,
            color: Colors.grey),
      if (type == '도착시 상차' || type == '도착시 하차')
        KTextWidget(
            text: '도착하면 ${updown}',
            size: 12,
            textAlign: TextAlign.end,
            fontWeight: null,
            overflow: TextOverflow.ellipsis,
            color: Colors.grey),
      if (type.contains('전화로'))
        KTextWidget(
            text: '${updown}지와 전화로 확인 필요',
            size: 12,
            textAlign: TextAlign.end,
            fontWeight: null,
            overflow: TextOverflow.ellipsis,
            color: Colors.grey),
      if (type == '시간 선택' && startDateTime != null)
        KTextWidget(
            text:
                '${fase3String(startDateTime)} ${formatTime2(startDateTime)} ${aloneType ?? ''} ${updown}',
            size: 12,
            textAlign: TextAlign.end,
            fontWeight: null,
            overflow: TextOverflow.ellipsis,
            color: Colors.grey),
      if (type == '시간대 선택' && startDateTime != null && endDateTime != null)
        KTextWidget(
            text:
                '${fase3String(startDateTime)} ${formatTimeEnd2(startDateTime)} ~ ${fase3String(endDateTime)} ${formatTimeEnd2(endDateTime)} 까지 ${updown}',
            size: 12,
            fontWeight: null,
            overflow: TextOverflow.ellipsis,
            color: Colors.grey),
      if (type.contains('기타') == true)
        SizedBox(
          child: KTextWidget(
              text: etc,
              size: 12,
              textAlign: TextAlign.end,
              fontWeight: null,
              overflow: TextOverflow.ellipsis,
              color: kOrangeBssetColor),
        ),
    ],
  );
}

String allTimeState(String type, String updown, dynamic start, dynamic end,
    String? aloneType, String etc) {
  DateTime? startDateTime;
  DateTime? endDateTime;

  // DateTime 또는 Timestamp를 안전하게 변환
  if (start != null) {
    startDateTime = start is Timestamp
        ? start.toDate()
        : (start is DateTime ? start : null);
  }

  if (end != null) {
    endDateTime =
        end is Timestamp ? end.toDate() : (end is DateTime ? end : null);
  }

  if (type == '미정') {
    return '${updown}시간 미정';
  } else if (type == '도착시 상차' || type == '도착시 하차') {
    return '도착하면 ${updown}';
  } else if (type.contains('전화로')) {
    return '${updown}지와 전화로 확인 필요';
  } else if (type == '시간 선택') {
    if (startDateTime == null) return '$updown 시간 정보 없음';
    return '${fase3String(startDateTime)} ${formatTime2(startDateTime)} ${aloneType ?? ''} ${updown}';
  } else if (type == '시간대 선택') {
    if (startDateTime == null || endDateTime == null) return '$updown 시간 정보 없음';
    return '${fase3String(startDateTime)} ${formatTimeEnd2(startDateTime)} ~ ${fase3String(endDateTime)} ${formatTimeEnd2(endDateTime)} 까지 ${updown}';
  } else if (type.contains('기타') == true) {
    return etc;
  } else {
    return ''; // 기본 빈 문자열 반환
  }
}

// 태그 스타일의 정보 표시 위젯
Widget buildInfoTag(String text, Color textColor, Color bgColor) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(4),
    ),
    child: KTextWidget(
      text: text,
      size: 13,
      fontWeight: FontWeight.bold,
      color: textColor,
    ),
  );
}
