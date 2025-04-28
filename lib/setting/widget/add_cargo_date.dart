import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';

import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';

// 상수 관리
class TimePickerConstants {
  static List<String> hours =
      List.generate(24, (index) => index.toString().padLeft(2, '0'));
  static const List<String> minutes = ['00', '10', '20', '30', '40', '50'];

  static List<String> getTimeOptions(bool isUpload) {
    return [
      '미정',
      !isUpload ? '도착시 상차' : '도착시 하차',
      '전화로 시간 확인 필요(협의)',
      '시간 선택',
      '시간대 선택',
      '기타 직접입력'
    ];
  }
}

class DialogTimeSet extends StatefulWidget {
  final String callType;
  const DialogTimeSet({super.key, required this.callType});

  @override
  State<DialogTimeSet> createState() => _DialogTimeSetState();
}

class _DialogTimeSetState extends State<DialogTimeSet> {
  final TextEditingController _etcText = TextEditingController();
  DateTime selDay = DateTime.now();
  String? timeSel;
  bool _isSelTime = false;
  bool _isTwoSel = false;
  bool _isHour = false;
  bool _isM = false;
  bool _isHour2 = false;
  bool _isM2 = false;
  bool _isT = false;
  bool _isDone = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final addProvider = Provider.of<AddProvider>(context, listen: false);
    if (widget.callType.contains('하차')) {
      if (addProvider.setDownTimeEtc != null) {
        _etcText.text = addProvider.setDownTimeEtc.toString();
      }
    } else {
      if (addProvider.setUpTimeEtc != null) {
        _etcText.text = addProvider.setUpTimeEtc.toString();
      }
    }
  }

  String _getDayName(DateTime date) {
    final Map<int, String> weekdays = {
      1: '(월)',
      2: '(화)',
      3: '(수)',
      4: '(목)',
      5: '(금)',
      6: '(토)',
      7: '(일)'
    };
    return weekdays[date.weekday] ?? '';
  }

  String _getTimePhase(DateTime time) {
    final int hour = time.hour;
    if ((hour >= 23) || (hour >= 0 && hour <= 3)) return '심야';
    if (hour >= 4 && hour <= 7) return '새벽';
    if (hour >= 8 && hour <= 12) return '오전';
    if (hour >= 13 && hour <= 17) return '오후';
    return '저녁';
  }

  @override
  Widget build(BuildContext context) {
    final addProvider = Provider.of<AddProvider>(context);
    final bool isUpDown = widget.callType.contains('하차');

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _buildHeader(isUpDown),
          const SizedBox(height: 18),
          _buildDateSection(isUpDown),
          if (isUpDown) _buildTomorrowOption(addProvider),
          if (!_isSelTime) _buildTimeSection(isUpDown),
          const Spacer(),
          _buildSubmitButton(addProvider, isUpDown),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isUpDown) {
    return Row(
      children: [
        KTextWidget(
            text: !isUpDown ? '상차 일정' : '하차 일정',
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
    );
  }

  Widget _buildDateSection(bool isUpDown) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KTextWidget(
            text: !isUpDown ? '상차일' : '하차일',
            size: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white),
        const SizedBox(height: 8),
        _buildDateSelector(),
      ],
    );
  }

  Widget _buildDateSelector() {
    String dayName = _getDayName(selDay);
    bool isToday = selDay.year == DateTime.now().year &&
        selDay.month == DateTime.now().month &&
        selDay.day == DateTime.now().day;
    bool isUpDown = widget.callType.contains('하차');

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _isSelTime = !_isSelTime;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _isSelTime ? 300 : 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: btnColor,
          border: Border.all(
              color: _isSelTime
                  ? (isUpDown ? kRedColor : kBlueBssetColor)
                  : Colors.grey.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Container(
              height: 53,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Expanded(child: SizedBox()),
                  KTextWidget(
                      text: DateFormat('yyyy년 MM월 dd일').format(selDay) +
                          ' ' +
                          dayName,
                      size: 16,
                      fontWeight: FontWeight.bold,
                      color: null),
                  const SizedBox(width: 5),
                  // if (isToday)

                  /*  const KRoundedContainer(
                        color: kGreenFontColor,
                        child: KTextKRWidget(
                            text: '오늘',
                            size: 12,
                            fontWeight: FontWeight.bold,
                            color: kGreenFontColor)), */

                  const Expanded(child: SizedBox()),
                  Icon(
                    _isSelTime ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    size: 24,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
            if (_isSelTime) _buildDateList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateList() {
    DateTime today = DateTime.now();
    List<DateTime> dates = List.generate(
      16,
      (index) => DateTime(
        today.year,
        today.month,
        today.day + index,
      ),
    );

    return Expanded(
      child: ListView.builder(
        itemCount: dates.length,
        itemBuilder: (context, index) {
          DateTime date = dates[index];
          String dayName = _getDayName(date);
          bool isToday = date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;

          return InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                selDay = date;
                _isSelTime = false;
              });
            },
            child: Container(
              height: 25,
              margin: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  KTextWidget(
                      text: DateFormat('yyyy년 MM월 dd일').format(date),
                      size: 16,
                      fontWeight: null,
                      color: null),
                  KTextWidget(
                      text: ' ' + dayName,
                      size: 16,
                      fontWeight: null,
                      color: Colors.grey),
                  const SizedBox(width: 5),
                  if (isToday)
                    const KRoundedContainer(
                        color: kGreenFontColor,
                        child: KTextWidget(
                            text: '오늘',
                            size: 12,
                            fontWeight: FontWeight.bold,
                            color: kGreenFontColor)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTomorrowOption(AddProvider addProvider) {
    return Column(
      children: [
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            addProvider.isTmmState(!addProvider.isTmm);
          },
          child: Row(
            children: [
              addProvider.isTmm
                  ? const Icon(Icons.check_box, color: kRedColor)
                  : const Icon(
                      Icons.check_box_outline_blank,
                      color: Colors.grey,
                    ),
              const SizedBox(width: 6),
              KTextWidget(
                  text: addProvider.isTmm
                      ? '협의에 따라 다음날 하차도 가능한 운송건입니다.'
                      : '다음날 하차도 가능할 경우, 이곳을 클릭하세요.',
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: addProvider.isTmm ? kRedColor : Colors.grey)
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSection(bool isUpDown) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        KTextWidget(
            text: !isUpDown ? '상차 시간' : '하차 시간',
            size: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white),
        const SizedBox(height: 8),
        _buildTimeSelector(),
        const SizedBox(height: 16),
        if (timeSel == '시간 선택') _timeSel1(),
        if (timeSel == '시간대 선택') _timesel2(),
        if (timeSel?.contains('기타') == true) _etcState2(),
      ],
    );
  }

  Widget _buildTimeSelector() {
    bool isUpDown = widget.callType.contains('하차');
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _isTwoSel = !_isTwoSel;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _isTwoSel ? 335 : 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: btnColor,
          border: Border.all(
              color: _isTwoSel
                  ? (isUpDown ? kRedColor : kBlueBssetColor)
                  : Colors.grey.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Container(
              height: 53,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Expanded(child: SizedBox()),
                  KTextWidget(
                      text: timeSel ?? '시간 정보를 설정하세요',
                      size: 16,
                      fontWeight: FontWeight.bold,
                      color: _isTwoSel ? Colors.grey.withOpacity(0.5) : null),
                  const Expanded(child: SizedBox()),
                  Icon(
                    _isTwoSel ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    size: 24,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
            if (_isTwoSel)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    TimePickerConstants.getTimeOptions(isUpDown).map((text) {
                  return _secBtn(text);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _secBtn(String text) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _isTwoSel = false;
          timeSel = text;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 32),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 40,
          child: KTextWidget(
              text: text,
              size: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white),
        ),
      ),
    );
  }

  Widget _timeSel1() {
    bool isUpDown = widget.callType.contains('하차');
    final addProvider = Provider.of<AddProvider>(context);

    return _isSelTime == false && _isTwoSel == false
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _isHour = !_isHour;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _isHour ? 300 : 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: btnColor,
                      border: Border.all(
                          color: _isHour
                              ? (isUpDown ? kRedColor : kBlueBssetColor)
                              : Colors.grey.withOpacity(0.5)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 53,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Expanded(child: SizedBox()),
                              !isUpDown
                                  ? KTextWidget(
                                      text: addProvider.setUpDateDoubleStart ==
                                              null
                                          ? '시간'
                                          : '${addProvider.setUpDateDoubleStart!.hour} 시',
                                      size: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _isTwoSel
                                          ? Colors.grey.withOpacity(0.5)
                                          : null)
                                  : KTextWidget(
                                      text: addProvider
                                                  .setDownDateDoubleStart ==
                                              null
                                          ? '시간'
                                          : '${addProvider.setDownDateDoubleStart!.hour} 시',
                                      size: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _isTwoSel
                                          ? Colors.grey.withOpacity(0.5)
                                          : null),
                              const Expanded(child: SizedBox()),
                              Icon(
                                _isHour
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                                size: 24,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 16),
                            ],
                          ),
                        ),
                        if (_isHour)
                          Expanded(
                            child: ListView.builder(
                                itemCount: TimePickerConstants.hours.length,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      if (!isUpDown) {
                                        addProvider
                                            .setUpTimeDoubleStartState(DateTime(
                                          DateTime.now().year,
                                          DateTime.now().month,
                                          DateTime.now().day,
                                          int.parse(
                                              TimePickerConstants.hours[index]),
                                        ));
                                      } else {
                                        addProvider.setDownTimeDoubleStartState(
                                            DateTime(
                                          DateTime.now().year,
                                          DateTime.now().month,
                                          DateTime.now().day,
                                          int.parse(
                                              TimePickerConstants.hours[index]),
                                        ));
                                      }
                                      setState(() {
                                        _isHour = false;
                                      });
                                    },
                                    child: Container(
                                      height: 45,
                                      child: Center(
                                        child: KTextWidget(
                                            text: TimePickerConstants
                                                .hours[index],
                                            size: 16,
                                            fontWeight: null,
                                            color: Colors.white),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _isM = !_isM;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _isM ? 300 : 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: btnColor,
                      border: Border.all(
                          color: _isM
                              ? (isUpDown ? kRedColor : kBlueBssetColor)
                              : Colors.grey.withOpacity(0.5)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 53,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Expanded(child: SizedBox()),
                              !isUpDown
                                  ? KTextWidget(
                                      text: addProvider.setUpDateDoubleStart ==
                                              null
                                          ? '분'
                                          : '${addProvider.setUpDateDoubleStart!.minute} 분',
                                      size: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _isTwoSel
                                          ? Colors.grey.withOpacity(0.5)
                                          : null)
                                  : KTextWidget(
                                      text: addProvider
                                                  .setDownDateDoubleStart ==
                                              null
                                          ? '분'
                                          : '${addProvider.setDownDateDoubleStart!.minute} 분',
                                      size: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _isTwoSel
                                          ? Colors.grey.withOpacity(0.5)
                                          : null),
                              const Expanded(child: SizedBox()),
                              Icon(
                                _isM
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                                size: 24,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 16),
                            ],
                          ),
                        ),
                        if (_isM)
                          Column(
                            children: TimePickerConstants.minutes
                                .map((minute) => _min(minute, ''))
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _isT = !_isT;
                    });
                  },
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: btnColor,
                      border: Border.all(color: Colors.grey.withOpacity(0.5)),
                    ),
                    child: Center(
                      child: KTextWidget(
                          text: !_isT ? '부터' : '까지',
                          size: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ],
          )
        : const SizedBox();
  }

  Widget _min(String text, String? callType) {
    bool isUpDown = widget.callType.contains('하차');
    final addProvider = Provider.of<AddProvider>(context);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        if (timeSel == '시간 선택') {
          if (!isUpDown) {
            addProvider.setUpTimeDoubleStartState(
              DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
                addProvider.setUpDateDoubleStart?.hour ?? 0,
                int.parse(text),
              ),
            );
          } else {
            addProvider.setDownTimeDoubleStartState(
              DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
                addProvider.setDownDateDoubleStart?.hour ?? 0,
                int.parse(text),
              ),
            );
          }
          setState(() {
            _isM = false;
          });
        } else {
          if (callType == 'a') {
            if (!isUpDown) {
              addProvider.setUpTimeDoubleEndState(
                DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                  addProvider.setUpDateDoubleEnd?.hour ?? 0,
                  int.parse(text),
                ),
              );
            } else {
              addProvider.setDownTimeDoubleEndState(
                DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                  addProvider.setDownDateDoubleEnd?.hour ?? 0,
                  int.parse(text),
                ),
              );
            }
            setState(() {
              _isM2 = false;
            });
          } else {
            if (!isUpDown) {
              addProvider.setUpTimeDoubleStartState(
                DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                  addProvider.setUpDateDoubleStart?.hour ?? 0,
                  int.parse(text),
                ),
              );
            } else {
              addProvider.setDownTimeDoubleStartState(
                DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                  addProvider.setDownDateDoubleStart?.hour ?? 0,
                  int.parse(text),
                ),
              );
            }
            setState(() {
              _isM = false;
            });
          }
        }
      },
      child: Container(
        height: 40,
        child: Center(
          child: KTextWidget(
            text: text,
            size: 16,
            fontWeight: null,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _timesel2() {
    return _isSelTime == false && _isTwoSel == false
        ? Column(
            children: [
              _time2start(),
              const SizedBox(height: 12),
              _time2End(),
            ],
          )
        : const SizedBox();
  }

  Widget _time2start() {
    bool isUpDown = widget.callType.contains('하차');
    final addProvider = Provider.of<AddProvider>(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isHour = !_isHour;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isHour ? 300 : 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: btnColor,
                border: Border.all(
                    color: _isHour
                        ? (isUpDown ? kRedColor : kBlueBssetColor)
                        : Colors.grey.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  Container(
                    height: 53,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Expanded(child: SizedBox()),
                        !isUpDown
                            ? KTextWidget(
                                text: addProvider.setUpDateDoubleStart == null
                                    ? '시간'
                                    : '${addProvider.setUpDateDoubleStart!.hour} 시',
                                size: 16,
                                fontWeight: FontWeight.bold,
                                color: _isTwoSel
                                    ? Colors.grey.withOpacity(0.5)
                                    : null)
                            : KTextWidget(
                                text: addProvider.setDownDateDoubleStart == null
                                    ? '시간'
                                    : '${addProvider.setDownDateDoubleStart!.hour} 시',
                                size: 16,
                                fontWeight: FontWeight.bold,
                                color: _isTwoSel
                                    ? Colors.grey.withOpacity(0.5)
                                    : null),
                        const Expanded(child: SizedBox()),
                        Icon(
                          _isHour ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                          size: 24,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                  if (_isHour)
                    Expanded(
                      child: _buildHourList(addProvider, isUpDown, true),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMinutePicker(addProvider, isUpDown, true),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 55,
            child: const Center(
              child: KTextWidget(
                  text: '부터',
                  size: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _time2End() {
    bool isUpDown = widget.callType.contains('하차');
    final addProvider = Provider.of<AddProvider>(context);

    return _isHour == false && _isM == false
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _isHour2 = !_isHour2;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _isHour2 ? 300 : 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: btnColor,
                      border: Border.all(
                          color: _isHour2
                              ? (isUpDown ? kRedColor : kBlueBssetColor)
                              : Colors.grey.withOpacity(0.5)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 53,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Expanded(child: SizedBox()),
                              !isUpDown
                                  ? KTextWidget(
                                      text: addProvider.setUpDateDoubleEnd ==
                                              null
                                          ? '시간'
                                          : '${addProvider.setUpDateDoubleEnd!.hour} 시',
                                      size: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _isTwoSel
                                          ? Colors.grey.withOpacity(0.5)
                                          : null)
                                  : KTextWidget(
                                      text: addProvider.setDownDateDoubleEnd ==
                                              null
                                          ? '시간'
                                          : '${addProvider.setDownDateDoubleEnd!.hour} 시',
                                      size: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _isTwoSel
                                          ? Colors.grey.withOpacity(0.5)
                                          : null),
                              const Expanded(child: SizedBox()),
                              Icon(
                                _isHour2
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                                size: 24,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 16),
                            ],
                          ),
                        ),
                        if (_isHour2)
                          Expanded(
                            child: ListView.builder(
                              itemCount: TimePickerConstants.hours.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    if (!isUpDown) {
                                      addProvider.setUpTimeDoubleEndState(
                                        DateTime(
                                          DateTime.now().year,
                                          DateTime.now().month,
                                          DateTime.now().day,
                                          int.parse(
                                              TimePickerConstants.hours[index]),
                                          addProvider
                                                  .setUpDateDoubleEnd?.minute ??
                                              0,
                                        ),
                                      );
                                    } else {
                                      addProvider.setDownTimeDoubleEndState(
                                        DateTime(
                                          DateTime.now().year,
                                          DateTime.now().month,
                                          DateTime.now().day,
                                          int.parse(
                                              TimePickerConstants.hours[index]),
                                          addProvider.setDownDateDoubleEnd
                                                  ?.minute ??
                                              0,
                                        ),
                                      );
                                    }
                                    setState(() {
                                      _isHour2 = false;
                                    });
                                  },
                                  child: Container(
                                    height: 45,
                                    child: Center(
                                      child: KTextWidget(
                                          text:
                                              TimePickerConstants.hours[index],
                                          size: 16,
                                          fontWeight: null,
                                          color: Colors.white),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _isM2 = !_isM2;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _isM2 ? 300 : 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: btnColor,
                      border: Border.all(
                          color: _isM2
                              ? (isUpDown ? kRedColor : kBlueBssetColor)
                              : Colors.grey.withOpacity(0.5)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 53,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Expanded(child: SizedBox()),
                              !isUpDown
                                  ? KTextWidget(
                                      text: addProvider.setUpDateDoubleEnd ==
                                              null
                                          ? '분'
                                          : '${addProvider.setUpDateDoubleEnd!.minute} 분',
                                      size: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _isTwoSel
                                          ? Colors.grey.withOpacity(0.5)
                                          : null)
                                  : KTextWidget(
                                      text: addProvider.setDownDateDoubleEnd ==
                                              null
                                          ? '분'
                                          : '${addProvider.setDownDateDoubleEnd!.minute} 분',
                                      size: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _isTwoSel
                                          ? Colors.grey.withOpacity(0.5)
                                          : null),
                              const Expanded(child: SizedBox()),
                              Icon(
                                _isM2
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                                size: 24,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 16),
                            ],
                          ),
                        ),
                        if (_isM2)
                          Column(
                            children: TimePickerConstants.minutes
                                .map((minute) => _min(minute, 'a'))
                                .toList(),
                          )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 55,
                  child: const Center(
                    child: KTextWidget(
                        text: '까지',
                        size: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                ),
              ),
            ],
          )
        : const SizedBox();
  }

  Widget _etcState2() {
    bool isUpDown = widget.callType.contains('하차');
    return _isTwoSel == true || _isSelTime == true
        ? const SizedBox()
        : Container(
            height: 96,
            child: TextFormField(
              controller: _etcText,
              autocorrect: false,
              cursorColor: Colors.grey,
              maxLength: 100,
              maxLines: 3,
              style: const TextStyle(fontSize: 16),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                suffixIcon: Column(
                  children: [
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _etcText.clear();
                        setState(() {});
                      },
                      child: const Icon(
                        Icons.remove_circle,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                counterText: '',
                hintText: '기사님께 전달할 내용을 입력하세요.',
                hintStyle: const TextStyle(fontSize: 16),
                filled: true,
                fillColor: btnColor,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: !isUpDown ? kBlueBssetColor : kRedColor,
                      width: 1.0),
                  borderRadius: BorderRadius.circular(16),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          );
  }

  Widget _buildSubmitButton(AddProvider addProvider, bool isUpDown) {
    _updateIsDone(addProvider);

    return _isHour2 == false && _isM2 == false
        ? GestureDetector(
            onTap: _isDone
                ? () async {
                    HapticFeedback.lightImpact();
                    await _handleSubmit();
                  }
                : null,
            child: Container(
              height: 56,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: _isDone
                    ? (!isUpDown ? kBlueBssetColor : kRedColor)
                    : noState,
              ),
              child: Center(
                child: KTextWidget(
                    text: !isUpDown ? '상차 일시 등록' : '하차 일시 등록',
                    size: 16,
                    fontWeight: FontWeight.bold,
                    color: _isDone ? Colors.white : Colors.grey),
              ),
            ),
          )
        : const SizedBox();
  }

  void _updateIsDone(AddProvider addProvider) {
    if (widget.callType.contains('하차')) {
      if (timeSel == '시간 선택') {
        _isDone = addProvider.setDownDateDoubleStart != null;
      } else if (timeSel == '시간대 선택') {
        _isDone = addProvider.setDownDateDoubleEnd != null;
      } else if (timeSel == '기타(직접 입력)') {
        _isDone = _etcText.text.isNotEmpty;
      } else {
        _isDone = timeSel != null;
      }
    } else {
      if (timeSel == '시간 선택') {
        _isDone = addProvider.setUpDateDoubleStart != null;
      } else if (timeSel == '시간대 선택') {
        _isDone = addProvider.setUpDateDoubleEnd != null;
      } else if (timeSel == '기타(직접 입력)') {
        _isDone = _etcText.text.isNotEmpty;
      } else {
        _isDone = timeSel != null;
      }
    }
  }

  Future<void> _handleSubmit() async {
    final addProvider = Provider.of<AddProvider>(context, listen: false);
    if (selDay != null) {
      int year = selDay.year;
      int month = selDay.month;
      int day = selDay.day;

      if (widget.callType.contains('하차')) {
        await _handleDownTimeSubmit(addProvider, year, month, day);
      } else {
        await _handleUpTimeSubmit(addProvider, year, month, day);
      }
      Navigator.pop(context);
    }
  }

  Future<void> _handleDownTimeSubmit(
      AddProvider addProvider, int year, int month, int day) async {
    if (timeSel == '시간 선택') {
      int hour = addProvider.setDownDateDoubleStart!.hour;
      int min = addProvider.setDownDateDoubleStart!.minute;
      addProvider.setDownDateState(selDay);
      addProvider.setLocationDownTimeTypeState(timeSel.toString());
      addProvider
          .setDownTimeDoubleStartState(DateTime(year, month, day, hour, min));
      addProvider.setDownTimeAloneTypeState(_isT ? '까지' : '부터');
      addProvider.setLocationDownTimeisDoneState(true);
    } else if (timeSel == '시간대 선택') {
      _handleDownTimeRangeSubmit(addProvider, year, month, day);
    } else if (timeSel == '기타(직접 입력)') {
      _handleDownCustomTimeSubmit(addProvider);
    } else {
      addProvider.setDownDateState(selDay);
      addProvider.setLocationDownTimeTypeState(timeSel.toString());
      addProvider.setLocationDownTimeisDoneState(true);
    }
    addProvider.dayNameDownState(_getDayName(selDay));
  }

  void _handleDownTimeRangeSubmit(
      AddProvider addProvider, int year, int month, int day) {
    int hourStart = addProvider.setDownDateDoubleStart!.hour;
    int minStart = addProvider.setDownDateDoubleStart!.minute;
    int hourEnd = addProvider.setDownDateDoubleEnd!.hour;
    int minEnd = addProvider.setDownDateDoubleEnd!.minute;

    addProvider.setDownDateState(selDay);
    addProvider.setLocationDownTimeTypeState(timeSel.toString());
    addProvider.setDownTimeDoubleStartState(
        DateTime(year, month, day, hourStart, minStart));
    addProvider
        .setDownTimeDoubleEndState(DateTime(year, month, day, hourEnd, minEnd));
    addProvider.setLocationDownTimeisDoneState(true);
  }

  void _handleDownCustomTimeSubmit(AddProvider addProvider) {
    addProvider.setDownDateState(selDay);
    addProvider.setLocationDownTimeTypeState(timeSel.toString());
    addProvider.setDownTimeEtcState(_etcText.text.trim());
    addProvider.setLocationDownTimeisDoneState(true);
  }

  // 상차 시간 제출 처리와 관련된 메서드들도 동일한 패턴으로 구현
  Future<void> _handleUpTimeSubmit(
      AddProvider addProvider, int year, int month, int day) async {
    if (timeSel == '시간 선택') {
      int hour = addProvider.setUpDateDoubleStart!.hour;
      int min = addProvider.setUpDateDoubleStart!.minute;
      addProvider.setUpDateState(selDay);
      addProvider.setLocationUpTimeTypeState(timeSel.toString());
      addProvider
          .setUpTimeDoubleStartState(DateTime(year, month, day, hour, min));
      addProvider.setUpTimeAloneTypeState(_isT ? '부터' : '까지');
      addProvider.setLocationUpTimeisDoneState(true);
    } else if (timeSel == '시간대 선택') {
      _handleUpTimeRangeSubmit(addProvider, year, month, day);
    } else if (timeSel!.contains('기타')) {
      if (_etcText.text.length == 0) {
      } else {
        _handleUpCustomTimeSubmit(addProvider);
      }
    } else {
      addProvider.setUpDateState(selDay);
      addProvider.setLocationUpTimeTypeState(timeSel.toString());
      addProvider.setLocationUpTimeisDoneState(true);
    }
    addProvider.dayNameUpState(_getDayName(selDay));
  }

  void _handleUpTimeRangeSubmit(
      AddProvider addProvider, int year, int month, int day) {
    int hourStart = addProvider.setUpDateDoubleStart!.hour;
    int minStart = addProvider.setUpDateDoubleStart!.minute;
    int hourEnd = addProvider.setUpDateDoubleEnd!.hour;
    int minEnd = addProvider.setUpDateDoubleEnd!.minute;

    addProvider.setUpDateState(selDay);
    addProvider.setLocationUpTimeTypeState(timeSel.toString());
    addProvider.setUpTimeDoubleStartState(
        DateTime(year, month, day, hourStart, minStart));
    addProvider
        .setUpTimeDoubleEndState(DateTime(year, month, day, hourEnd, minEnd));
    addProvider.setLocationUpTimeisDoneState(true);
  }

  void _handleUpCustomTimeSubmit(AddProvider addProvider) {
    addProvider.setUpDateState(selDay);
    addProvider.setLocationUpTimeTypeState(timeSel.toString());
    addProvider.setUpTimeEtcState(_etcText.text.trim());
    addProvider.setLocationUpTimeisDoneState(true);
  }

  Widget _buildHourList(AddProvider addProvider, bool isUpDown, bool isStart) {
    return ListView.builder(
      itemCount: TimePickerConstants.hours.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            DateTime newTime;
            if (!isUpDown) {
              if (isStart) {
                newTime = DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                  int.parse(TimePickerConstants.hours[index]),
                  addProvider.setUpDateDoubleStart?.minute ?? 0,
                );
                addProvider.setUpTimeDoubleStartState(newTime);
              } else {
                newTime = DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                  int.parse(TimePickerConstants.hours[index]),
                  addProvider.setUpDateDoubleEnd?.minute ?? 0,
                );
                addProvider.setUpTimeDoubleEndState(newTime);
              }
            } else {
              if (isStart) {
                newTime = DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                  int.parse(TimePickerConstants.hours[index]),
                  addProvider.setDownDateDoubleStart?.minute ?? 0,
                );
                addProvider.setDownTimeDoubleStartState(newTime);
              } else {
                newTime = DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                  int.parse(TimePickerConstants.hours[index]),
                  addProvider.setDownDateDoubleEnd?.minute ?? 0,
                );
                addProvider.setDownTimeDoubleEndState(newTime);
              }
            }
            setState(() {
              _isHour = false;
              _isHour2 = false;
            });
          },
          child: Container(
            height: 45,
            child: Center(
              child: KTextWidget(
                text: TimePickerConstants.hours[index],
                size: 16,
                fontWeight: null,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMinutePicker(
      AddProvider addProvider, bool isUpDown, bool isStart) {
    final currentMinute = isUpDown
        ? (isStart
            ? addProvider.setDownDateDoubleStart?.minute
            : addProvider.setDownDateDoubleEnd?.minute)
        : (isStart
            ? addProvider.setUpDateDoubleStart?.minute
            : addProvider.setUpDateDoubleEnd?.minute);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          if (isStart) {
            _isM = !_isM;
          } else {
            _isM2 = !_isM2;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: (isStart ? _isM : _isM2) ? 300 : 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: btnColor,
          border: Border.all(
            color: (isStart ? _isM : _isM2)
                ? (isUpDown ? kRedColor : kBlueBssetColor)
                : Colors.grey.withOpacity(0.5),
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 53,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Expanded(child: SizedBox()),
                  KTextWidget(
                    text: currentMinute == null ? '분' : '$currentMinute 분',
                    size: 16,
                    fontWeight: FontWeight.bold,
                    color: _isTwoSel ? Colors.grey.withOpacity(0.5) : null,
                  ),
                  const Expanded(child: SizedBox()),
                  Icon(
                    (isStart ? _isM : _isM2)
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                    size: 24,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
            if (isStart ? _isM : _isM2)
              Column(
                children: TimePickerConstants.minutes
                    .map(
                      (minute) => _min(minute, isStart ? '' : 'a'),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
