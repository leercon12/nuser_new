import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/* ===================================
키보드 내리기 
=================================== */
void hideKeyboard(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode());
  SystemChannels.textInput.invokeMethod('TextInput.hide');
}

/* ===================================
날자 변환
=================================== */
String formatDate(DateTime dateTime) {
  // 연도, 월, 일을 추출
  String year = dateTime.year.toString().substring(2);
  int month = dateTime.month;
  int day = dateTime.day;

  // yy.mm.dd 형식의 문자열로 변환
  String formattedDate =
      '$year.${_addLeadingZero(month)}.${_addLeadingZero(day)}';

  return formattedDate;
}

String formatDateTime(DateTime dateTime) {
  // 연도, 월, 일, 시간, 분을 추출
  int year = dateTime.year;
  int month = dateTime.month;
  int day = dateTime.day;
  int hour = dateTime.hour;
  int minute = dateTime.minute;

  // yy.mm.dd HH:MM 형식의 문자열로 변환
  String formattedDate =
      '$year.${_addLeadingZero(month)}.${_addLeadingZero(day)} ${_addLeadingZero(hour)}:${_addLeadingZero(minute)}';

  return formattedDate;
}

String formatDateKorTime(DateTime dateTime) {
  // 연도, 월, 일, 시간, 분을 추출
  int year = dateTime.year;
  int month = dateTime.month;
  int day = dateTime.day;
  int hour = dateTime.hour;
  int minute = dateTime.minute;

  // 00년 00월 00일, 00시 00분 형식으로 변환
  String formattedDate =
      '${_addLeadingZero(year)}년 ${_addLeadingZero(month)}월 ${_addLeadingZero(day)}일, ${_addLeadingZero(hour)}시 ${_addLeadingZero(minute)}분';

  return formattedDate;
}

// 한 자리 숫자 앞에 0을 추가하는 보조 함수
String _addLeadingZero(int number) {
  return number.toString().padLeft(2, '0');
}

String getDayName(DateTime value) {
  String dayName = '';
  String value2 = DateFormat('yyyy-MM-dd EEEE').format(value);
  if (value2.contains('Monday')) {
    dayName = '(월)';
  } else if (value2.contains('Tuesday')) {
    dayName = '(화)';
  } else if (value2.contains('Wednesday')) {
    dayName = '(수)';
  } else if (value2.contains('Thursday')) {
    dayName = '(목)';
  } else if (value2.contains('Friday')) {
    dayName = '(금)';
  } else if (value2.contains('Saturday')) {
    dayName = '(토)';
  } else if (value2.contains('Sunday')) {
    dayName = '(일)';
  }

  return dayName;
}

String fase3String(dynamic value) {
  String? _fffase;

  // Timestamp 또는 DateTime 값을 DateTime으로 변환
  DateTime dateTime;
  if (value is Timestamp) {
    dateTime = value.toDate();
  } else if (value is DateTime) {
    dateTime = value;
  } else {
    throw ArgumentError('value must be DateTime or Timestamp');
  }

  int hour = dateTime.hour;
  print('Hour: $hour'); // 시간 값 출력

  if ((hour >= 23 && hour <= 23) || (hour >= 0 && hour <= 3)) {
    _fffase = '심야';
  } else if (hour >= 4 && hour <= 7) {
    _fffase = '새벽';
  } else if (hour >= 8 && hour <= 12) {
    _fffase = '오전';
  } else if (hour >= 13 && hour <= 17) {
    _fffase = '오후';
  } else if (hour >= 18 && hour <= 22) {
    _fffase = '저녁';
  }

  return _fffase ?? '시간정보없음'; // null 안전하게 처리
}

bool isToday(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

//////////////////////////////////////
/// 완성 updown 위젯 주소 줄이기
/////////////////////////////////////

Future<String> addressEx(String address) async {
  List<String> words = address.split(RegExp(r'\s+'));
  int lastSpaceIndex = words.length - 1;
  String? extractedText;
  if (words.length > 5) {
    lastSpaceIndex = words.length - 3;
  } else if (words.length < 5) {
    lastSpaceIndex = words.length - 2;
  } else {
    lastSpaceIndex = words.length - 1;
  }

  if (lastSpaceIndex > 0) {
    extractedText = words.sublist(0, lastSpaceIndex).join(' ');
  }
  return extractedText.toString();
}

String calculateDateStatus(DateTime selDay, DateTime now) {
  // 오늘인지 확인
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

Future<String?> addDisCurrent2Up(
    BuildContext context, NLatLng up, NLatLng down) async {
  if (up == null || down == null) {
    return null;
  } else {
    // 두 지점 간의 거리 계산
    final distance = up.distanceTo(down);

    // 소수점 첫째 자리에서 반올림하여 정수로 만들기
    final roundedDistance = distance.round();

    // 1km 이내 또는 초과에 따라 반환값 설정
    if (roundedDistance <= 1000) {
      return '$roundedDistance m';
    } else {
      final distanceInKm = (roundedDistance / 1000).round();
      return '$distanceInKm km';
    }
  }
}

////////////////////////////////////

Widget dateState(String state, double? size) {
  return Stack(
    children: [
      if (state == 'today')
        KTextWidget(
            text: '오늘, ',
            size: size == null ? 14 : size,
            fontWeight: FontWeight.bold,
            color: kGreenFontColor),
      if (state == 'tmm')
        KTextWidget(
            text: '내일, ',
            size: size == null ? 14 : size,
            fontWeight: FontWeight.bold,
            color: kBlueBssetColor),
      if (state == 'ex')
        KTextWidget(
            text: '만료, ',
            size: size == null ? 14 : size,
            fontWeight: FontWeight.bold,
            color: kRedColor),
      if (state == 'book')
        KTextWidget(
            text: '예약, ',
            size: size == null ? 14 : size,
            fontWeight: FontWeight.bold,
            color: kOrangeBssetColor),
    ],
  );
}

Widget dateState2(String state) {
  return Stack(
    children: [
      if (state == 'today')
        const Center(
          child: KTextWidget(
              text: '오늘',
              size: 13,
              fontWeight: FontWeight.bold,
              color: kGreenFontColor),
        ),
      if (state == 'tmm')
        const Center(
          child: KTextWidget(
              text: '내일',
              size: 13,
              fontWeight: FontWeight.bold,
              color: kBlueBssetColor),
        ),
      if (state == 'ex')
        const Center(
          child: KTextWidget(
              text: '만료',
              size: 13,
              fontWeight: FontWeight.bold,
              color: kRedColor),
        ),
      if (state == 'book')
        const Center(
          child: KTextWidget(
              text: '예약',
              size: 13,
              fontWeight: FontWeight.bold,
              color: kOrangeBssetColor),
        ),
    ],
  );
}

String extractFour(String input) {
  // 문자열의 길이가 4글자 이상인 경우 앞 4글자를 추출
  if (input.length >= 4) {
    return input.substring(0, 4);
  } else {
    // 문자열의 길이가 4글자 미만인 경우 문자열 전체를 반환
    return input;
  }
}

String getTwoWords(String text) {
  List<String> words = text.split(' ');
  return words.length > 1 ? '${words[0]} ${words[1]}' : text;
}

class DottedLine extends StatelessWidget {
  final double width;
  final Color color;

  const DottedLine({
    super.key,
    this.width = double.infinity,
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 1,
      child: CustomPaint(
        painter: _DottedLinePainter(color: color),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  final Color color;

  _DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    const double dashWidth = 3;
    const double dashSpace = 3;
    double currentX = 0;

    while (currentX < size.width) {
      canvas.drawLine(
        Offset(currentX, 0),
        Offset(currentX + dashWidth, 0),
        paint,
      );
      currentX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class VerticalDottedLine extends StatelessWidget {
  final double height;
  final Color color;

  const VerticalDottedLine({
    super.key,
    this.height = double.infinity,
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1,
      height: height,
      child: CustomPaint(
        painter: _VerticalDottedLinePainter(color: color),
      ),
    );
  }
}

class _VerticalDottedLinePainter extends CustomPainter {
  final Color color;

  _VerticalDottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    const double dashHeight = 3;
    const double dashSpace = 3;
    double currentY = 0;

    while (currentY < size.height) {
      canvas.drawLine(
        Offset(0, currentY),
        Offset(0, currentY + dashHeight),
        paint,
      );
      currentY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ProgressLinePainter extends CustomPainter {
  final double progress;
  final Color lineColor;
  final double strokeWidth;

  ProgressLinePainter({
    required this.progress,
    required this.lineColor,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final startPoint = Offset(0, size.height / 2);
    final endPoint = Offset(size.width * progress, size.height / 2);

    canvas.drawLine(startPoint, endPoint, paint);
  }

  @override
  bool shouldRepaint(ProgressLinePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

// 타임스탬프 포맷 함수
String agoKorTimestamp(Timestamp timestamp) {
  final now = DateTime.now();
  final date = timestamp.toDate();
  final difference = now.difference(date);

  if (difference.inMinutes < 1) {
    return '방금 전';
  } else if (difference.inHours < 1) {
    return '${difference.inMinutes}분 전';
  } else if (difference.inDays < 1) {
    return '${difference.inHours}시간 전';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}일 전';
  } else {
    return '${date.month}월 ${date.day}일';
  }
}

String maskLastCharacter(String text) {
  if (text.isEmpty) return text;
  return text.substring(0, text.length - 1) + '*';
}

String removeLists(String text) {
  return text.replaceAll('[', '').replaceAll(']', '');
}

String formatCurrency(dynamic amount) {
  if (amount == null) return '0';

  final formatter = NumberFormat("#,###");

  // double인 경우 int로 변환
  if (amount is double) {
    amount = amount.toInt();
  }

  try {
    return '${formatter.format(amount)}';
  } catch (e) {
    return '0';
  }
}

class _WavyLinePainter extends CustomPainter {
  final double progress;
  final double animValue;
  final Color lineColor;

  _WavyLinePainter({
    required this.progress,
    required this.animValue,
    required this.lineColor,
  });

  double easeInOutCubic(double t) {
    return t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    final double progressWidth = size.width * progress;
    final double baseY = size.height / 2;

    // 메인 라인
    path.moveTo(0, baseY);
    path.lineTo(progressWidth, baseY);

    // 심전도 패턴
    if (progress > 0) {
      final double patternWidth = 55.0;
      final double currentX = progressWidth + (patternWidth * animValue);

      path.moveTo(progressWidth, baseY);

      if (animValue <= 0.15) {
        // 첫 번째 직선
        path.lineTo(currentX, baseY);
      } else if (animValue <= 0.25) {
        // 직선 유지
        path.lineTo(progressWidth + (patternWidth * 0.15), baseY);
        path.lineTo(currentX, baseY);
      } else if (animValue <= 0.35) {
        // 급격한 상승 - 부드러운 가속
        path.lineTo(progressWidth + (patternWidth * 0.25), baseY);
        double t = (animValue - 0.25) / 0.1;
        path.lineTo(currentX, baseY - (30 * easeInOutCubic(t)));
      } else if (animValue <= 0.45) {
        // 급격한 하강 - 부드러운 가속
        path.lineTo(progressWidth + (patternWidth * 0.25), baseY);
        path.lineTo(progressWidth + (patternWidth * 0.35), baseY - 30);
        double t = (animValue - 0.35) / 0.1;
        path.lineTo(currentX, baseY + (15 * easeInOutCubic(t)));
      } else if (animValue <= 0.55) {
        // 기준선으로 복귀 - 부드러운 감속
        path.lineTo(progressWidth + (patternWidth * 0.25), baseY);
        path.lineTo(progressWidth + (patternWidth * 0.35), baseY - 30);
        path.lineTo(progressWidth + (patternWidth * 0.45), baseY + 15);
        double t = (animValue - 0.45) / 0.1;
        path.lineTo(currentX, baseY + 15 - (15 * easeInOutCubic(t)));
      } else {
        // 마지막 직선
        path.lineTo(progressWidth + (patternWidth * 0.25), baseY);
        path.lineTo(progressWidth + (patternWidth * 0.35), baseY - 30);
        path.lineTo(progressWidth + (patternWidth * 0.45), baseY + 15);
        path.lineTo(progressWidth + (patternWidth * 0.55), baseY);
        path.lineTo(currentX, baseY);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavyLinePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.animValue != animValue;
  }
}

class ProgressLine extends StatefulWidget {
  final double width;
  final double progress;
  final Color lineColor;

  const ProgressLine({
    Key? key,
    required this.width,
    required this.progress,
    required this.lineColor,
  }) : super(key: key);

  @override
  State<ProgressLine> createState() => _ProgressLineState();
}

class _ProgressLineState extends State<ProgressLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1.0, curve: Curves.easeInOutSine),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.width, 40),
          painter: _WavyLinePainter(
            progress: widget.progress,
            lineColor: widget.lineColor,
            animValue: _animation.value,
          ),
        );
      },
    );
  }
}

bool isPassedDate(DateTime timestamp) {
  // 오늘 날짜의 자정 시간 가져오기
  final today = DateTime.now();
  final todayMidnight = DateTime(today.year, today.month, today.day);

  // 비교할 날짜의 자정 시간 생성
  final compareDateMidnight =
      DateTime(timestamp.year, timestamp.month, timestamp.day);

  // 비교할 날짜가 오늘보다 이전이면(즉, 어제까지면) true 반환
  return compareDateMidnight.isBefore(todayMidnight);
}

class StaticLinePainter extends CustomPainter {
  final double progress;
  final Color lineColor;

  StaticLinePainter({
    required this.progress,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    final double progressWidth = size.width * progress;
    final double baseY = size.height / 2;

    // 메인 라인만 그리기
    path.moveTo(0, baseY);
    path.lineTo(progressWidth, baseY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant StaticLinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class StaticProgressLine extends StatelessWidget {
  final double width;
  final double progress;
  final Color lineColor;

  const StaticProgressLine({
    Key? key,
    required this.width,
    required this.progress,
    required this.lineColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 40, // 기존 위젯과 동일한 높이 유지
      child: CustomPaint(
        painter: StaticLinePainter(
          progress: progress,
          lineColor: lineColor,
        ),
      ),
    );
  }
}

String maskText(String text) {
  if (text.isEmpty) return '';
  if (text.length <= 2) return '*' * text.length;

  // 마지막 2글자를 제외한 부분
  String visiblePart = text.substring(0, text.length - 2);
  // 마지막 2글자는 '*'로 변경
  return visiblePart + '**';
}

String upDownTypeState(String state, String callType) {
  if (state.isEmpty) return '';

  String? title;

  if (state == '미정') {
    title = '${callType} 방법 미정';
  } else if (state == '수작업') {
    title = '수작업으로 ${callType}';
  } else if (state == '지게차') {
    title = '지게차로 ${callType}';
  } else if (state == '호이스트') {
    title = '호이스트로 ${callType}';
  } else if (state == '컨베이어') {
    title = '컨베이어로 ${callType}';
  } else if (state == '크레인') {
    title = '크레인으로 ${callType}';
  } else if (state == '전화로 확인') {
    title = '${callType}지에 전화로 확인 필요';
  }

  return title.toString();
}

void navigateToPage(BuildContext context, Widget page) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => page),
  );
}

String getRelativeDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final tomorrow = today.add(const Duration(days: 1));
  final compareDate = DateTime(date.year, date.month, date.day);

  if (compareDate == today) {
    return '오늘';
  } else if (compareDate == yesterday) {
    return '어제';
  } else if (compareDate == tomorrow) {
    return '내일';
  } else if (compareDate.isAfter(tomorrow)) {
    return '이후';
  } else {
    return '이전';
  }
}

int getPickupCount(Map<String, dynamic> cargo) {
  // cargo에서 locations 리스트를 가져와서 처리
  final locations = List<Map<String, dynamic>>.from(cargo!['locations'] ?? []);
  return locations.where((location) => location['type'] == '상차').length;
}

int getDropoffCount(Map<String, dynamic> cargo) {
  final locations = List<Map<String, dynamic>>.from(cargo!['locations'] ?? []);
  return locations.where((location) => location['type'] == '하차').length;
}

double getPickupWeight(Map<String, dynamic> cargo) {
  final locations = List<Map<String, dynamic>>.from(cargo['locations'] ?? []);

  return locations.where((location) => location['type'] == '상차').fold(
      0.0, (sum, location) => sum + (location['weight']?.toDouble() ?? 0.0));
}

double getDropoffWeight(Map<String, dynamic> cargo) {
  final locations = List<Map<String, dynamic>>.from(cargo['locations'] ?? []);

  return locations.where((location) => location['type'] == '하차').fold(
      0.0, (sum, location) => sum + (location['weight']?.toDouble() ?? 0.0));
}

int getTodayCount(Map<String, dynamic> cargo) {
  final now = DateTime.now();
  final locations = List<Map<String, dynamic>>.from(cargo!['locations'] ?? []);

  return locations.where((location) {
    // Timestamp를 DateTime으로 변환
    final timestamp = location['date'] as Timestamp;
    final locationDate = timestamp.toDate();

    final normalizedLocationDate = DateTime(
      locationDate.year,
      locationDate.month,
      locationDate.day,
    );

    final normalizedNow = DateTime(
      now.year,
      now.month,
      now.day,
    );

    return normalizedLocationDate.isAtSameMomentAs(normalizedNow);
  }).length;
}

int getTomorrowCount(Map<String, dynamic> cargo) {
  final now = DateTime.now();
  final tomorrow = DateTime(now.year, now.month, now.day + 1);
  final locations = List<Map<String, dynamic>>.from(cargo!['locations'] ?? []);

  return locations.where((location) {
    final timestamp = location['date'] as Timestamp;
    final locationDate = timestamp.toDate();

    final normalizedLocationDate = DateTime(
      locationDate.year,
      locationDate.month,
      locationDate.day,
    );

    return normalizedLocationDate.isAtSameMomentAs(tomorrow);
  }).length;
}

int getFutureCount(Map<String, dynamic> cargo) {
  final now = DateTime.now();
  final tomorrow = DateTime(now.year, now.month, now.day + 1);
  final locations = List<Map<String, dynamic>>.from(cargo!['locations'] ?? []);

  return locations.where((location) {
    final timestamp = location['date'] as Timestamp;
    final locationDate = timestamp.toDate();

    final normalizedLocationDate = DateTime(
      locationDate.year,
      locationDate.month,
      locationDate.day,
    );

    return normalizedLocationDate.isAfter(tomorrow);
  }).length;
}

bool isWithinFiveMinutes(DateTime timeStamp) {
  final now = DateTime.now();
  final difference = now.difference(timeStamp);
  return difference.inMinutes < 10; // 5분 미만이면 true 반환
}

String addressEx2(String address) {
  List<String> words = address.split(RegExp(r'\s+'));
  int lastSpaceIndex = words.length - 1;
  String extractedText;

  if (words.length >= 5) {
    lastSpaceIndex = words.length - 2;
  } else if (words.length == 4) {
    lastSpaceIndex = words.length - 1;
  } else if (words.length == 3) {
    lastSpaceIndex = words.length - 1;
  } else {
    lastSpaceIndex = words.length - 1;
  }

  if (lastSpaceIndex > 0) {
    extractedText = words.sublist(0, lastSpaceIndex).join(' ');
  } else {
    extractedText = address; // 원래 주소를 반환
  }

  return extractedText;
}

String addressExtract(String address) {
  List<String> words = address.split(RegExp(r'\s+'));

  if (words.length <= 2) {
    return address;
  }

  return words.sublist(0, 2).join(' ');
}

/* String calculateDateStatus(DateTime selDay, DateTime now) {
  // 오늘인지 확인
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
} */

String getPart(String input, int index) {
  if (input.isEmpty) {
    return '';
  }

  List<String> parts = input.split('/');

  if (index < 0 || index >= parts.length) {
    return '';
  }

  return parts[index];
}

////// 멀티 계산

Map<String, dynamic> analyzeCargoData(dynamic data) {
  // 상차지점 리스트
  List<Map<String, dynamic>> upPoints = [];

  // 하차지점 리스트
  List<Map<String, dynamic>> downPoints = [];

  // 상차, 하차 화물 개수 추적
  int totalUpCargoCount = 0;
  int totalDownCargoCount = 0;

  // 현재 적재량 추적
  double currentWeight = 0.0;
  double maxWeight = 0.0;
  int currentCargoCount = 0;
  int maxCargoCount = 0;
  Map<String, dynamic>? maxWeightPoint;

  // 데이터 타입 확인 및 처리
  List<dynamic> locations = [];

  if (data is List) {
    // CargoLocation 객체 리스트인 경우 (addProvider.locations)
    locations = data;
  } else if (data is Map && data.containsKey('locations')) {
    // Map<String, dynamic> 형태에서 locations 배열 추출
    locations = data['locations'] as List;
  } else {
    // 지원하지 않는 형식
    return {
      '상차지점리스트': [],
      '하차지점리스트': [],
      '상차화물수': 0,
      '하차화물수': 0,
      '최대적재정보': {'최대무게': 0.0, '최대개수': 0, '적재위치': null}
    };
  }

  // 위치 순회
  for (int i = 0; i < locations.length; i++) {
    var location = locations[i];
    var locationType, locationAddress, upCargosData, downCargosData;

    // 데이터 형식에 따른 필드 추출
    if (location is Map) {
      // Map 형태 데이터 처리
      locationType = location['type'];
      locationAddress = location['address1'];
      upCargosData = location['upCargos'];
      downCargosData = location['downCargos'];
    } else {
      // CargoLocation 객체 처리
      locationType = location.type;
      locationAddress = location.address1;
      upCargosData = location.upCargos;
      downCargosData = location.downCargos;
    }

    // 모든 위치에서 상차 및 하차 데이터 처리
    var upCargos = [];
    var downCargos = [];

    // 먼저 하차 화물 처리 (위치 타입에 관계없이)
    if (downCargosData != null) {
      List cargosList = downCargosData is List ? downCargosData : [];

      // 이 위치의 하차 개수 추가
      totalDownCargoCount += cargosList.length;

      for (var cargo in cargosList) {
        var cargoName, cargoWeight, cargoType;

        // 화물 데이터 형식 처리
        if (cargo is Map) {
          cargoName = cargo['cargo'] ?? '미지정';
          cargoWeight = _extractNumericValue(cargo['cargoWe']);
          cargoType = cargo['cargoType'] ?? '일반';
        } else {
          cargoName = cargo.cargo ?? '미지정';
          cargoWeight = _extractNumericValue(cargo.cargoWe);
          cargoType = cargo.cargoType ?? '일반';
        }

        // 현재 화물 정보 저장
        downCargos.add({'화물명': cargoName, '무게': cargoWeight, '종류': cargoType});

        // 위치 타입에 관계없이 하차 시 적재량 감소
        currentWeight = (currentWeight - cargoWeight) > 0
            ? (currentWeight - cargoWeight)
            : 0;
        currentCargoCount = currentCargoCount > 0 ? currentCargoCount - 1 : 0;
      }
    }

    // 그 다음 상차 화물 처리 (위치 타입에 관계없이)
    if (upCargosData != null) {
      List cargosList = upCargosData is List ? upCargosData : [];

      // 이 위치의 상차 개수 추가
      totalUpCargoCount += cargosList.length;

      for (var cargo in cargosList) {
        var cargoName, cargoWeight, cargoType;

        // 화물 데이터 형식 처리
        if (cargo is Map) {
          cargoName = cargo['cargo'] ?? '미지정';
          cargoWeight = _extractNumericValue(cargo['cargoWe']);
          cargoType = cargo['cargoType'] ?? '일반';
        } else {
          cargoName = cargo.cargo ?? '미지정';
          cargoWeight = _extractNumericValue(cargo.cargoWe);
          cargoType = cargo.cargoType ?? '일반';
        }

        // 현재 화물 정보 저장
        upCargos.add({'화물명': cargoName, '무게': cargoWeight, '종류': cargoType});

        // 위치 타입에 관계없이 상차 시 적재량 증가
        currentWeight += cargoWeight;
        currentCargoCount++;
      }
    }

    // 각 위치에서 상하차 후 최대 적재량 갱신
    if (currentWeight > maxWeight) {
      maxWeight = currentWeight;
      maxCargoCount = currentCargoCount;
      maxWeightPoint = {
        '위치번호': i + 1,
        '주소': locationAddress ?? '',
        '무게': currentWeight,
        '개수': currentCargoCount
      };
    }

    // 위치 유형에 따라 목록에 추가
    if (locationType == '상차') {
      // 상차지점 정보 저장
      upPoints.add({
        '위치번호': i + 1,
        '주소': locationAddress ?? '',
        '상차목록': upCargos,
        '상차무게': upCargos.fold<double>(
            0, (sum, item) => sum + (item['무게'] as double))
      });
    } else if (locationType == '하차' || locationType == '회차') {
      // 하차지점 정보 저장
      downPoints.add({
        '위치번호': i + 1,
        '주소': locationAddress ?? '',
        '하차목록': downCargos,
        '하차무게': downCargos.fold<double>(
            0, (sum, item) => sum + (item['무게'] as double))
      });
    }
  }

  // 결과 반환
  return {
    '상차지점리스트': upPoints,
    '하차지점리스트': downPoints,
    '상차화물수': totalUpCargoCount,
    '하차화물수': totalDownCargoCount,
    '최대적재정보': {'최대무게': maxWeight, '최대개수': maxCargoCount, '적재위치': maxWeightPoint}
  };
}

/// 숫자 값 추출 헬퍼 함수
double _extractNumericValue(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) {
    try {
      return double.parse(value);
    } catch (e) {
      return 0.0;
    }
  }
  return 0.0;
}
