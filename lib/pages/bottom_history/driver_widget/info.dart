import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/hashProvider.dart';
import 'package:flutter_mixcall_normaluser_new/service/future_service.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class BottomDriverInfo extends StatefulWidget {
  final Map<String, dynamic> userData;
  const BottomDriverInfo({super.key, required this.userData});

  @override
  State<BottomDriverInfo> createState() => _BottomDriverInfoState();
}

class _BottomDriverInfoState extends State<BottomDriverInfo> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 24),

            // 프로필 이미지
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: kGreenFontColor.withOpacity(0.3), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: widget.userData['userProfileIMG'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.network(
                            widget.userData['userProfileIMG'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error,
                                  color: Colors.grey, size: 40);
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: kGreenFontColor,
                                  strokeWidth: 2,
                                ),
                              );
                            },
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: noState.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person,
                              size: 60, color: Colors.grey),
                        ),
                ),

                // 작은 아이콘 배지 (오른쪽 하단 코너)
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: kGreenFontColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_shipping,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 이름 및 직함
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                KTextWidget(
                  text: widget.userData['name'],
                  size: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                const KTextWidget(
                  text: '기사님',
                  size: 14,
                  fontWeight: null,
                  color: Colors.grey,
                ),
              ],
            ),

            // 차량 정보 한줄 요약
            /*   KTextWidget(
              text:
                  '${widget.userData['carType']}, ${widget.userData['carNum']}',
              size: 15,
              fontWeight: null,
              color: Colors.grey,
            ), */

            const SizedBox(height: 24),

            // 버튼 섹션
            _btn(),

            const SizedBox(height: 28),

            // 차량 정보 섹션 추가
            _buildSectionHeader('차량 정보', Icons.directions_car_filled),
            _carInfo(),

            const SizedBox(height: 24),

            // 사업자 정보 섹션
            _buildSectionHeader('사업자 정보', Icons.business),
            _driverInfo(),

            const SizedBox(height: 24),

            // 계좌 정보 섹션
            _buildSectionHeader('계좌 정보', Icons.account_balance),
            _accout(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

// 섹션 헤더 위젯
  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 5),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: kGreenFontColor.withOpacity(0.8),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                KTextWidget(
                  text: title,
                  textAlign: TextAlign.start,
                  size: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey.withOpacity(0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// 정보 행 위젯
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: KTextWidget(
              text: label,
              size: 14,
              fontWeight: null,
              color: Colors.grey,
            ),
          ),
          const Spacer(),
          KTextWidget(
            text: value,
            size: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

// 새로 추가된 차량 정보 위젯
  Widget _carInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: noState.withOpacity(0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 차량 정보 아이콘 행
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildVehicleInfoIcon(
                  Icons.local_shipping, widget.userData['carType']),
              _buildVehicleInfoIcon(
                  Icons.scale, '${widget.userData['carTon']}톤'),
              _buildVehicleInfoIcon(Icons.local_gas_station,
                  widget.userData['carOilType'] ?? '정보 없음'),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(
            color: Colors.grey,
            height: 1,
            thickness: 0.5,
          ),
          const SizedBox(height: 16),

          // 상세 정보
          _buildInfoRow('차량 번호', widget.userData['carNum']),
          _buildInfoRow('차량 유형', widget.userData['carType']),
          _buildInfoRow('차량 중량', '${widget.userData['carTon']}톤'),
          _buildInfoRow('차량 종류', widget.userData['carJong'] ?? '정보 없음'),
          _buildInfoRow('연료 타입', widget.userData['carOilType'] ?? '정보 없음'),
          widget.userData['carOption'] != null
              ? _buildInfoRow(
                  '차량 옵션',
                  widget.userData['carOption'].join(', '),
                )
              : _buildInfoRow('차량 옵션', '옵션 없음'),
        ],
      ),
    );
  }

// 차량 정보 아이콘 위젯
  Widget _buildVehicleInfoIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: noState,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: kGreenFontColor.withOpacity(0.8),
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        KTextWidget(
          text: label,
          size: 12,
          fontWeight: FontWeight.normal,
          color: Colors.grey,
        ),
      ],
    );
  }

  Widget _btn() {
    final dataProvider = Provider.of<DataProvider>(context);
    final bool isLiked =
        dataProvider.userData!.likeDriver.contains(widget.userData['uid']);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              makePhoneCall(widget.userData['phone'].toString());
            },
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: noState,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone,
                    color: Colors.grey,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  KTextWidget(
                    text: '전화 걸기',
                    size: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  )
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              HapticFeedback.lightImpact();
              if (isLiked == false) {
                await _like(dataProvider);
              } else {
                await _unLike(dataProvider);
              }
              dataProvider.userProvider();
            },
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isLiked ? kGreenFontColor.withOpacity(0.3) : noState,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    color: isLiked ? kGreenFontColor : Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  KTextWidget(
                    text: isLiked ? '단골 해제' : '단골 설정',
                    size: 14,
                    fontWeight: FontWeight.bold,
                    color: isLiked ? kGreenFontColor : Colors.grey,
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _driverInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: noState.withOpacity(0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 사업자 정보 이미지 컨테이너
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildDocumentImage(widget.userData['businessPhoto'].toString()),
              const SizedBox(width: 12),
              _buildDocumentImage(widget.userData['driverLicence'].toString()),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(
            color: Colors.grey,
            height: 1,
            thickness: 0.5,
          ),
          const SizedBox(height: 16),

          // 사업자 정보 상세
          _buildInfoRow('화물 운수 자격증', '등록 완료'),
          _buildInfoRow('사업자 등록증', '등록 완료'),
          _buildInfoRow('회사명', widget.userData['businessName']),
          _buildInfoRow('대표 메일', widget.userData['businessEmail']),
          _buildInfoRow('사업자등록번호', widget.userData['businessNum']),
        ],
      ),
    );
  }

// 문서 이미지 위젯
  Widget _buildDocumentImage(String imageUrl) {
    return Container(
      height: 80,
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.error, color: Colors.grey),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(
                color: kGreenFontColor,
                strokeWidth: 2,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _accout() {
    final hashProvider = Provider.of<HashProvider>(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: noState.withOpacity(0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 계좌 정보 이미지
          Center(
            child:
                _buildDocumentImage(widget.userData['acountPhoto'].toString()),
          ),

          const SizedBox(height: 20),
          const Divider(
            color: Colors.grey,
            height: 1,
            thickness: 0.5,
          ),
          const SizedBox(height: 16),

          // 계좌 정보 상세
          _buildInfoRow('계좌 사본 등록', '등록 완료'),
          _buildInfoRow('은행 / 계좌명',
              '${widget.userData['bankName']}, ${widget.userData['acountName']}'),
          _buildInfoRow(
              '계좌 번호', hashProvider.decryptData(widget.userData['acountNum'])),
        ],
      ),
    );
  }

  Widget _businessInfo() {
    return Container();
  }

  Future _like(DataProvider dataProvider) async {
    await FirebaseFirestore.instance
        .collection('user_driver')
        .doc(widget.userData['uid'])
        .update({
      'likeClient': FieldValue.arrayUnion([dataProvider.userData!.uid])
    });

    await FirebaseFirestore.instance
        .collection('user_normal')
        .doc(dataProvider.userData!.uid)
        .update({
      'likeDriver': FieldValue.arrayUnion([widget.userData['uid']])
    });
  }

  Future _unLike(DataProvider dataProvider) async {
    await FirebaseFirestore.instance
        .collection('user_driver')
        .doc(widget.userData['uid'])
        .update({
      'likeClient': FieldValue.arrayRemove([dataProvider.userData!.uid])
    });

    await FirebaseFirestore.instance
        .collection('user_normal')
        .doc(dataProvider.userData!.uid)
        .update({
      'likeDriver': FieldValue.arrayRemove([widget.userData['uid']])
    });
  }
}
