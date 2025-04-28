import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_widget/delayed_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/bottom_history/bottom_com_info.dart';
import 'package:flutter_mixcall_normaluser_new/pages/bottom_history/bottom_driver_info.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/sidePage/biding/future/biding_future.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/sidePage/biding/sel_dialog.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/sidePage/biding/widget/com.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/sidePage/biding/widget/driver.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/hashProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/service/future_service.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/countdown.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BidingMainPage extends StatefulWidget {
  final Map<String, dynamic> cargo;
  const BidingMainPage({super.key, required this.cargo});

  @override
  State<BidingMainPage> createState() => _BidingMainPageState();
}

class _BidingMainPageState extends State<BidingMainPage> {
  String _type = '전체';
  String _sortBy = '최신 등록';

  num _total = 0;
  num _driver = 0;
  num _com = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.cargo['confirmUser'] != null) {
      setState(() {
        currentPrice = widget.cargo['conMoney'];
        _currentId = widget.cargo['confirmUser'];
      });
    }
  }

  @override
  void dispose() {
    //stopPeriodicExpiryCheck();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Column(
            children: [
              if (_total > 0) _top(),
              Expanded(child: _bidingList()),
            ],
          ),
          if (widget.cargo['conDate'] != null)
            Positioned(
              bottom: 0,
              right: 50,
              child: DelayedWidget(
                animationDuration: const Duration(milliseconds: 700),
                animation: DelayedAnimations.SLIDE_FROM_BOTTOM,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: msgBackColor),
                  child: Row(
                    children: [
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.grey.withOpacity(0.06),
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              color: kBlueBssetColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          KTextWidget(
                              text: '현재 수락 여부를 확인중입니다.',
                              size: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          KTextWidget(
                              text: '취소 후, 다른 제안을 선택할 수 있습니다.',
                              size: 13,
                              fontWeight: null,
                              color: Colors.grey)
                        ],
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _top() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8), color: msgBackColor),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _type = '전체';
              });
            },
            child: Row(
              children: [
                _type == '전체'
                    ? const Icon(
                        Icons.check_circle,
                        size: 15,
                        color: kGreenFontColor,
                      )
                    : Icon(
                        Icons.check,
                        color: Colors.grey.withOpacity(0.7),
                        size: 15,
                      ),
                const SizedBox(width: 5),
                KTextWidget(
                    text: '전체 $_total',
                    size: 13,
                    fontWeight: _type == '전체' ? FontWeight.bold : null,
                    color: _type == '전체'
                        ? kGreenFontColor
                        : Colors.grey.withOpacity(0.7))
              ],
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _type = '기사';
              });
            },
            child: Row(
              children: [
                _type == '기사'
                    ? const Icon(
                        Icons.check_circle,
                        size: 15,
                        color: kGreenFontColor,
                      )
                    : Icon(
                        Icons.check,
                        color: Colors.grey.withOpacity(0.7),
                        size: 15,
                      ),
                const SizedBox(width: 5),
                KTextWidget(
                    text: '기사 $_driver',
                    size: 13,
                    fontWeight: _type == '기사' ? FontWeight.bold : null,
                    color: _type == '기사'
                        ? kGreenFontColor
                        : Colors.grey.withOpacity(0.7))
              ],
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _type = '주선사';
              });
            },
            child: Row(
              children: [
                _type == '주선사'
                    ? const Icon(
                        Icons.check_circle,
                        size: 15,
                        color: kGreenFontColor,
                      )
                    : Icon(
                        Icons.check,
                        color: Colors.grey.withOpacity(0.7),
                        size: 15,
                      ),
                const SizedBox(width: 5),
                KTextWidget(
                    text: '주선사 $_com',
                    size: 13,
                    fontWeight: _type == '주선사' ? FontWeight.bold : null,
                    color: _type == '주선사'
                        ? kGreenFontColor
                        : Colors.grey.withOpacity(0.7))
              ],
            ),
          ),
          const Spacer(),
          DropdownButton<String>(
            value: _sortBy,
            icon: const Icon(
              Icons.arrow_drop_down,
              color: kBlueBssetColor,
              size: 15,
            ),
            elevation: 0,
            style: const TextStyle(
                color: kBlueBssetColor,
                fontSize: 13,
                fontWeight: FontWeight.bold),
            underline: Container(height: 0),
            isDense: true,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _sortBy = newValue;
                });
              }
            },
            items: ['최신 등록', '낮은 가격']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: kBlueBssetColor),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String? _currentId;
  Map<String, String> _distanceCache = {};
  Widget _bidingList() {
    final mapProvider = Provider.of<MapProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final hashProvider = Provider.of<HashProvider>(context);

    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cargoInfo')
            .doc(widget.cargo['uid'])
            .collection(extractFour(widget.cargo['id']))
            .doc(widget.cargo['id'])
            .collection('biding')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<DocumentSnapshot> originalDocs = snapshot.data!.docs;
          if (originalDocs.isEmpty) {
            // 빈 결과 처리를 위한 즉시 UI 업데이트 - 비동기 상태 업데이트
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _total = 0;
                  _driver = 0;
                  _com = 0;
                });
              }
            });

            // 빈 결과 표시
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info,
                    color: Colors.grey.withOpacity(0.3),
                    size: 50,
                  ),
                  const SizedBox(height: 10),
                  KTextWidget(
                      text: '아직 제안받은 운송료가 없습니다.',
                      size: 14,
                      fontWeight: null,
                      color: Colors.grey.withOpacity(0.5))
                ],
              ),
            );
          }

          List<DocumentSnapshot> bidingDocs = List.from(originalDocs);

          // 카운터 업데이트를 위한 비동기 상태 업데이트 - 성능 최적화
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _total = originalDocs.length;
                _driver = originalDocs
                    .where((doc) => doc['proposalType'] == 'driver')
                    .length;
                _com = originalDocs
                    .where((doc) => doc['proposalType'] == 'com')
                    .length;
              });
            }
          });

          // 정렬 로직
          if (_sortBy == '낮은 가격') {
            bidingDocs.sort(
                (a, b) => (a['price'] as num).compareTo(b['price'] as num));
          } else {
            bidingDocs.sort((a, b) =>
                (b['upDate'] as Timestamp).compareTo(a['upDate'] as Timestamp));
          }

          // 유형 필터링
          if (_type != '전체') {
            bidingDocs = bidingDocs
                .where((doc) => _type == '기사'
                    ? doc['proposalType'] == 'driver'
                    : doc['proposalType'] == 'com')
                .toList();
          }

          // 필터링 후 결과가 없는 경우
          if (bidingDocs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info,
                    color: Colors.grey.withOpacity(0.3),
                    size: 50,
                  ),
                  const SizedBox(height: 10),
                  KTextWidget(
                      text: '해당하는 제안이 없습니다.',
                      size: 14,
                      fontWeight: null,
                      color: Colors.grey.withOpacity(0.5))
                ],
              ),
            );
          }

          // 결과 표시
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              _chartView(originalDocs), // 차트 뷰는 고정 높이를 가진다고 가정
              const SizedBox(height: 8),
              Expanded(
                // GridView를 Expanded로 감싸기
                child: GridView.builder(
                  // shrinkWrap: true, // Expanded 안에서는 제거
                  // physics: const NeverScrollableScrollPhysics(), // 스크롤 가능하도록 변경
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.75, // 세로로 더 길게 조정 (필요에 따라 값 조정)
                  ),
                  itemCount: bidingDocs.length,
                  itemBuilder: (context, index) {
                    final data =
                        bidingDocs[index].data() as Map<String, dynamic>;
                    return data['proposalType'] == 'driver'
                        ? GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                currentPrice = data['price'];
                                _currentId = data['uid'];
                              });
                              mapProvider.bidingSelIdState(data['uid']);
                            },
                            child: BidingDriverWidget(
                                cargo: widget.cargo, data: data))
                        : GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                currentPrice = data['price'];
                                _currentId = data['uid'];
                              });
                              mapProvider.bidingSelIdState(data['uid']);
                            },
                            child: BidingComWidget(
                                cargo: widget.cargo, data: data));
                  },
                ),
              ),
            ],
          );
        });
  }

// 기사 정보 표시 위젯 - 레이아웃 개선
  Widget _driverListItem(Map<String, dynamic> data, DataProvider dataProvider,
      MapProvider mapProvider, HashProvider hashProvider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSelected = _currentId == data['uid'];
    final bool isConfirmed = widget.cargo['confirmUser'] == data['uid'];
    String distance = '...';
    if (data['location'] != null && distance == '...') {
      distance = formatDistance(getDistance(
          hashProvider.decLatLng(widget.cargo['upLocation']['geopoint']),
          hashProvider.decLatLng(data['location'])));
    }

    return Card(
      elevation: 0,
      color: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: msgBackColor,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                currentPrice = data['price'];
                _currentId = data['uid'];
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단 정보 행
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 프로필 이미지
                      Container(
                        padding: const EdgeInsets.all(3),
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: noState.withOpacity(0.5)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: _buildProfileImage(data['photoUrl']),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // 사용자 정보
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 이름 및 상태 행
                            Row(
                              children: [
                                // 이름 표시
                                KTextWidget(
                                    text: maskLastCharacter(
                                        data['name'].toString()),
                                    size: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey),

                                const SizedBox(width: 3),

                                const KTextWidget(
                                    text: '기사님',
                                    size: 14,
                                    fontWeight: null,
                                    color: Colors.grey),

                                // 확인 사용자 표시
                                if (isConfirmed) _buildConfirmationStatus(),

                                const Spacer(),

                                // 시간 표시
                                KTextWidget(
                                    text: agoKorTimestamp(data['date']),
                                    size: 12,
                                    fontWeight: null,
                                    color: Colors.grey),
                              ],
                            ),

                            // 차량 정보
                            KTextWidget(
                                text: data['carInfo'],
                                size: 12,
                                fontWeight: null,
                                color: Colors.grey),

                            const SizedBox(height: 4),

                            // 별점 및 거리, 가격 정보
                            Row(
                              children: [
                                // 별점
                                _buildRating(isSelected),

                                // 거리 정보
                                if (distance != '...')
                                  _buildDistanceInfo(distance),

                                const Spacer(),

                                // 가격 정보
                                KTextWidget(
                                    text: '${formatCurrency(data['price'])}원',
                                    size: 14,
                                    fontWeight:
                                        isSelected ? FontWeight.bold : null,
                                    color:
                                        isSelected ? Colors.white : Colors.grey)
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // 확장된 버튼 영역 - 선택된 경우만 표시
                  if (isSelected)
                    _buildActionButtons(data, dataProvider, mapProvider),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

// 주선사 정보 표시 위젯 - 레이아웃 개선
  Widget _companyListItem(Map<String, dynamic> data, DataProvider dataProvider,
      MapProvider mapProvider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSelected = _currentId == data['uid'];
    final bool isConfirmed = widget.cargo['confirmUser'] == data['uid'];

    return Card(
      elevation: 0,
      color: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: msgBackColor,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                currentPrice = data['price'];
                _currentId = data['uid'];
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단 정보 행
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 프로필 이미지
                      Container(
                        padding: const EdgeInsets.all(3),
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: noState.withOpacity(0.5)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: _buildProfileImage(data['photoUrl']),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // 회사 정보
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 회사명 및 상태 행
                            Row(
                              children: [
                                // 회사명 표시
                                KTextWidget(
                                    text: data['name'],
                                    size: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey),

                                // 확인 사용자 표시
                                if (isConfirmed)
                                  const Row(
                                    children: [
                                      KTextWidget(
                                          text: ' 수락중',
                                          size: 14,
                                          fontWeight: FontWeight.bold,
                                          color: kGreenFontColor),
                                      SizedBox(width: 3),
                                      SizedBox(
                                        width: 10,
                                        height: 10,
                                        child: CircularProgressIndicator(
                                          color: kGreenFontColor,
                                          strokeWidth: 1,
                                        ),
                                      )
                                    ],
                                  ),

                                const Spacer(),

                                // 시간 표시
                                KTextWidget(
                                    text: agoKorTimestamp(data['date']),
                                    size: 12,
                                    fontWeight: null,
                                    color: Colors.grey),
                              ],
                            ),

                            // 전문 주선사 표시
                            const KTextWidget(
                                text: '전문 주선사',
                                size: 12,
                                fontWeight: null,
                                color: Colors.grey),

                            const SizedBox(height: 4),

                            // 별점 및 가격 정보
                            Row(
                              children: [
                                // 별점
                                _buildRating(isSelected),

                                const Spacer(),

                                // 가격 정보
                                KTextWidget(
                                    text: '${formatCurrency(data['price'])}원',
                                    size: 14,
                                    fontWeight:
                                        isSelected ? FontWeight.bold : null,
                                    color:
                                        isSelected ? Colors.white : Colors.grey)
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // 확장된 버튼 영역 - 선택된 경우만 표시
                  if (isSelected)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: _buildCompanyActionButton(
                          data, dataProvider, mapProvider),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

// 프로필 이미지 위젯
  Widget _buildProfileImage(String? photoUrl) {
    final defaultUrl =
        'https://firebasestorage.googleapis.com/v0/b/mixcall.appspot.com/o/user.png?alt=media&token=30cb61dc-dc75-4bfd-a6d8-927a9031bca2';

    if (photoUrl == null || photoUrl == defaultUrl) {
      return Image.asset(
        'asset/img/logo.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('이미지 로드 에러: $error');
          return const Center(
            child: Icon(Icons.person, color: Colors.grey),
          );
        },
      );
    } else {
      return CachedNetworkImage(
        imageUrl: photoUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.grey,
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          print('이미지 로드 에러: $error');
          return const Center(
            child: Icon(Icons.person, color: Colors.grey),
          );
        },
      );
    }
  }

// 확인 상태 위젯
  Widget _buildConfirmationStatus() {
    return const Row(
      children: [
        KTextWidget(
            text: '의 제안 수락중',
            size: 14,
            fontWeight: FontWeight.bold,
            color: kGreenFontColor),
        SizedBox(width: 3),
        SizedBox(
          width: 10,
          height: 10,
          child: CircularProgressIndicator(
            color: kGreenFontColor,
            strokeWidth: 1,
          ),
        )
      ],
    );
  }

// 별점 위젯
  Widget _buildRating(bool isSelected) {
    return Row(
      children: [
        Icon(
          Icons.star,
          color: isSelected ? kOrangeBssetColor : Colors.grey,
          size: 15,
        ),
        const SizedBox(width: 5),
        KTextWidget(
            text: '4.5',
            size: 14,
            fontWeight: null,
            color: isSelected ? kOrangeBssetColor : Colors.grey),
      ],
    );
  }

// 거리 정보 위젯
  Widget _buildDistanceInfo(String distance) {
    return Row(
      children: [
        /*   const SizedBox(width: 8),
        Icon(Icons.location_on_sharp, color: Colors.grey, size: 14),
        const SizedBox(width: 2), */
        KTextWidget(
            text: ', 상차까지 ${distance}',
            size: 14,
            fontWeight: null,
            color: Colors.grey),
      ],
    );
  }

// 기사용 액션 버튼 위젯
  Widget _buildActionButtons(Map<String, dynamic> data,
      DataProvider dataProvider, MapProvider mapProvider) {
    final bool isConfirmed = widget.cargo['confirmUser'] == data['uid'];
    final bool otherConfirmed =
        widget.cargo['confirmUser'] != null && !isConfirmed;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          // 기사 정보 확인 버튼
          const SizedBox(width: 57),
          if (widget.cargo['confirmUser'] == null)
            Expanded(
              child: DelayedWidget(
                delayDuration: const Duration(milliseconds: 200),
                animation: DelayedAnimations.SLIDE_FROM_TOP,
                animationDuration: const Duration(milliseconds: 400),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return BottomDriverInfoPage(
                                pickUserUid: data['uid'],
                                isReview: true,
                                cargo: widget.cargo,
                              );
                            },
                          );
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: noState,
                      ),
                      child: const Center(
                        child: KTextWidget(
                            text: '정보 보기',
                            size: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // 버튼 사이 간격
          if (widget.cargo['confirmUser'] == null) const SizedBox(width: 8),

          // 제안 수락/취소 버튼
          Expanded(
            child: DelayedWidget(
              delayDuration: const Duration(milliseconds: 200),
              animation: DelayedAnimations.SLIDE_FROM_TOP,
              animationDuration: const Duration(milliseconds: 400),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () async {
                    HapticFeedback.lightImpact();

                    // 상차일 만료 확인
                    DateTime pickupDate = widget.cargo['aloneType'] == '다구간' ||
                            widget.cargo['aloneType'] == '왕복'
                        ? widget.cargo['locations'][0]['date'].toDate()
                        : widget.cargo['upTime'].toDate();

                    if (isPassedDate(pickupDate)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          errorSnackBar('상차일이 만료된 운송입니다.', context));
                      return;
                    }

                    // 제안 취소 또는 수락 처리
                    if (isConfirmed) {
                      mapProvider.isLoadingState(true);
                      await bidingCancel(dataProvider, data, context);
                      mapProvider.isLoadingState(false);
                    } else {
                      await bidingSelStep01BottomSheet(context, data)
                          .then((value) async {
                        if (value == true) {
                          await bidingSelStep02BottomSheet(
                                  context, data, widget.cargo)
                              .then((value) async {
                            if (value == true) {
                              mapProvider.isLoadingState(true);
                              await selDriverProposal(
                                  dataProvider, data, context);
                              mapProvider.isLoadingState(false);
                            }
                          });
                        }
                      });
                    }
                  },
                  child: otherConfirmed
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.withOpacity(0.3),
                          ),
                          child: const Center(
                            child: KTextWidget(
                                text: '다른 제안을 수락중입니다',
                                size: 14,
                                fontWeight: null,
                                color: Colors.grey),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: isConfirmed ? kRedColor : kGreenFontColor,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              KTextWidget(
                                  text: isConfirmed ? '제안 수락 취소' : '제안 수락하기',
                                  size: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              /*   CountdownTimer(
                                timestamp: widget.cargo['conDate'],
                              ) */
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

// 주선사용 액션 버튼 위젯
  Widget _buildCompanyActionButton(Map<String, dynamic> data,
      DataProvider dataProvider, MapProvider mapProvider) {
    final bool isConfirmed = widget.cargo['confirmUser'] == data['uid'];
    final bool otherConfirmed =
        widget.cargo['confirmUser'] != null && !isConfirmed;

    return DelayedWidget(
      delayDuration: const Duration(milliseconds: 100),
      animation: DelayedAnimations.SLIDE_FROM_TOP,
      animationDuration: const Duration(milliseconds: 400),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () async {
            HapticFeedback.lightImpact();

            if (isConfirmed) {
              mapProvider.isLoadingState(true);
              await bidingCancel(dataProvider, data, context);
              mapProvider.isLoadingState(false);
            } else {
              await bidingSelStep01BottomSheet(context, data)
                  .then((value) async {
                if (value == true) {
                  await bidingSelStep02BottomSheet(context, data, widget.cargo)
                      .then((value) async {
                    if (value == true) {
                      mapProvider.isLoadingState(true);
                      await selComProposal(dataProvider, data, context);
                      mapProvider.isLoadingState(false);
                    }
                  });
                }
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: otherConfirmed
                  ? Colors.grey.withOpacity(0.3)
                  : (isConfirmed ? kRedColor : kGreenFontColor),
            ),
            child: Center(
              child: KTextWidget(
                  text: otherConfirmed
                      ? '다른 제안을 수락중입니다'
                      : (isConfirmed ? '제안 수락 취소' : '제안 수락하기'),
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: otherConfirmed ? Colors.grey : Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _chartView(List<DocumentSnapshot<Object?>> data) {
    return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12), color: msgBackColor),
        child: _priceChart(data));
  }

  Future _setPrice() async {}
  num? currentPrice = 0;

  Widget _priceChart(List<DocumentSnapshot> bidingDocs) {
    // 가격 데이터 준비
    List<num> prices = bidingDocs
        .map((doc) => (doc.data() as Map<String, dynamic>)['price'] as num)
        .toList();
    prices.sort();

    bool isDisabled = prices.length <= 1;

    num minPrice = prices.first;
    num maxPrice = prices.last;
    num range = maxPrice - minPrice;

    // position 계산
    double? position;
    if (currentPrice != null && currentPrice != 0) {
      num clampedPrice = currentPrice!.clamp(minPrice, maxPrice);
      position = (clampedPrice - minPrice) / range;
      position = position.clamp(0.0, 1.0);
    }

    // 실제 차트의 너비 계산 (패딩 고려)
    final chartWidth = MediaQuery.of(context).size.width - 64; // 좌우 패딩 32씩 제외

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          height: 55,
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 32,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: isDisabled
                            ? [
                                Colors.grey.withOpacity(0.2),
                                Colors.grey.withOpacity(0.3),
                                Colors.grey.withOpacity(0.2),
                              ]
                            : [
                                kBlueBssetColor.withOpacity(1),
                                kBlueBssetColor.withOpacity(0.5),
                                kRedColor.withOpacity(0.5),
                                kRedColor.withOpacity(1),
                              ],
                        stops: isDisabled ? null : const [0.0, 0.3, 0.7, 1.0],
                      ),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: chartWidth * 0.33,
                          child: Container(
                            height: 32,
                            width: 1,
                            color: isDisabled
                                ? Colors.grey.withOpacity(0.3)
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                        Positioned(
                          left: chartWidth * 0.66,
                          child: Container(
                            height: 32,
                            width: 1,
                            color: isDisabled
                                ? Colors.grey.withOpacity(0.3)
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isDisabled && position != null)
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      left: (chartWidth * position), // 시작 패딩(16) + 위치 계산
                      top: -6,
                      child: TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 700),
                        tween: Tween<double>(begin: -2.0, end: 2.0),
                        builder: (context, double value, child) {
                          return Transform.translate(
                            offset: Offset(0, value),
                            child: Container(
                              height: 40,
                              width: 4,
                              decoration: BoxDecoration(
                                color: kGreenFontColor,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: kGreenFontColor.withOpacity(0.3),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '최저',
                    style: TextStyle(
                      color: isDisabled
                          ? Colors.grey.withOpacity(0.5)
                          : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '평균',
                    style: TextStyle(
                      color: isDisabled
                          ? Colors.grey.withOpacity(0.5)
                          : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '최고',
                    style: TextStyle(
                      color: isDisabled
                          ? Colors.grey.withOpacity(0.5)
                          : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (isDisabled)
          Positioned.fill(
              child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            color: msgBackColor.withOpacity(0.6),
            child: const Center(
              child: Text(
                '가격 비교를 위해 최소 2건 이상의 제안이 필요합니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          )),
      ],
    );
  }
}

// 데이터 모델
class PricePoint {
  final String category;
  final num min;
  final num max;
  final num average;

  PricePoint(this.category, this.min, this.max, this.average);
}
