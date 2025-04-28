import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/service/future_service.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/bottomSheet.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';

Future<bool?> bidingSelStep01BottomSheet(
    context, Map<String, dynamic> data) async {
  final dw = MediaQuery.of(context).size.width;
  bool _step02 = false;

  return await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return BottomSheetWidget(
            contents: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Column(
              children: [
                const SizedBox(height: 12),
                const Icon(Icons.info, size: 70, color: kGreenFontColor),
                const SizedBox(height: 24),
                KTextWidget(
                    text: data['proposalType'] == 'driver'
                        ? '실제 화물 기사의 제안입니다.'
                        : '전문 주선사의 제안입니다.',
                    size: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                const SizedBox(height: 12),
                KTextWidget(
                    text: data['proposalType'] == 'driver'
                        ? '실제 화물 기사란, 화물운수사업자 자격을 취득한 전문 화물 운송 사업자로 0.5톤에서 25톤까지 다양항 유형의 화물차량으로 화물 운송을 전문적으로 영위중인 사업자를 말합니다.'
                        : '전문 주선사란, 화물운송주선사업자 자격을 취득한 화물 운송 사업자로, 다년간 다양한 화물의 운송을 중개 / 대리한 경험을 가지고 있는 전문 기업을 말합니다. 주선사업자를 취득하기 위해서는 사무실, 일정금액 이상의 잔고 증명, 적재물배상보험증권 등의 조건을 갖춰야합니다.',
                    size: 14,
                    fontWeight: null,
                    color: Colors.grey),
                const SizedBox(height: 8),
                KTextWidget(
                    text: data['proposalType'] == 'driver'
                        ? '기사 제안을 선택할 경우, 다음과 같은 경우가 발생할 수 있음으로 내용을 꼭 확인하세요.'
                        : '주선사 제안을 선택할 경우, 다음과 같은 경우가 발생할 수 있음으로 내용을 꼭 확인하세요.',
                    size: 14,
                    fontWeight: null,
                    color: Colors.grey),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Column(
                      children: [
                        SizedBox(height: 3),
                        Icon(
                          Icons.info,
                          color: Colors.grey,
                          size: 14,
                        ),
                      ],
                    ),
                    const SizedBox(width: 5),
                    SizedBox(
                      width: dw - 55,
                      child: KTextWidget(
                          text: data['proposalType'] == 'driver'
                              ? '카드 결제를 진행하지 않으셨다면, 기사와 직접적으로 결제절차를 진행하셔야 합니다.'
                              : '주선사 제안의 경우, 혼적콜이 아닌 외부 플렛폼을 이용하여 해당 운송건을 처리할 수 있습니다. 이러한 경우, 실시간 화물 위치 표시 및 상태 관리를 이용하실 수 없습니다.',
                          size: 14,
                          fontWeight: null,
                          color: Colors.grey),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Column(
                      children: [
                        SizedBox(height: 3),
                        Icon(
                          Icons.info,
                          color: Colors.grey,
                          size: 14,
                        ),
                      ],
                    ),
                    const SizedBox(width: 5),
                    SizedBox(
                      width: dw - 55,
                      child: KTextWidget(
                          text: data['proposalType'] == 'driver'
                              ? '제안 선택후 기사에게 오는 전화를 꼭 받아주세요. 전화를 받지 않으면 운송이 원할하게 진행될 수 없습니다.'
                              : '이러한 경우, 앱에 표시된 상태를 확인하시거나 선택된 주선사에 문의하시어 궁금증을 해소하실 수 있습니다.',
                          size: 14,
                          fontWeight: null,
                          color: Colors.grey),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Column(
                      children: [
                        SizedBox(height: 3),
                        Icon(
                          Icons.info,
                          color: Colors.grey,
                          size: 14,
                        ),
                      ],
                    ),
                    const SizedBox(width: 5),
                    SizedBox(
                      width: dw - 55,
                      child: KTextWidget(
                          text: data['proposalType'] == 'driver'
                              ? '배차이후, 앱에 표시되는 정보를 이용하여 운송 상태를 관리하실 수 있습니다.'
                              : '다만, 운송 위탁 내역은 언제든 확인하실 수 있습니다.',
                          size: 14,
                          fontWeight: null,
                          color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context, true); // true 값을 반환
                  },
                  child: Container(
                    height: 52,
                    // margin: const EdgeInsets.only(left: 10, right: 10),
                    width: dw,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: kGreenFontColor),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        KTextWidget(
                            text: _step02 == false ? '다음' : '제안 승락하기',
                            size: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
      });
    },
  );
}

Future<bool?> bidingSelStep02BottomSheet(
    context, Map<String, dynamic> data, Map<String, dynamic> cargo) async {
  final dw = MediaQuery.of(context).size.width;
  bool _step02 = false;

  return await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return BottomSheetWidget(
            contents: SafeArea(
          child: FutureBuilder<DocumentSnapshot>(
              future: data['proposalType'] == 'driver'
                  ? FirebaseFirestore.instance
                      .collection('user_driver')
                      .doc(data['uid'])
                      .get()
                  : FirebaseFirestore.instance
                      .collection('cargoComInfo')
                      .doc(data['comUid'])
                      .get(),
              builder: (context, snapshot) {
                // 로딩 중일 때
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 20),
                      CircularProgressIndicator(
                        color: kGreenFontColor,
                      ),
                      SizedBox(height: 20),
                      KTextWidget(
                        text: '정보를 불러오는 중입니다...',
                        size: 14,
                        color: Colors.grey,
                        fontWeight: null,
                      ),
                    ],
                  );
                }

                // 에러 발생 시
                if (snapshot.hasError) {
                  return const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 20),
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 40,
                      ),
                      SizedBox(height: 10),
                      KTextWidget(
                        text: '정보를 불러오는데 실패했습니다',
                        size: 14,
                        color: Colors.grey,
                        fontWeight: null,
                      ),
                    ],
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 12),
                          SizedBox(
                            width: dw,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: noState.withOpacity(0.5),
                                  ),
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(100), // 여기를 수정
                                    child: data['photoUrl'] == null ||
                                            data['photoUrl'] ==
                                                'https://firebasestorage.googleapis.com/v0/b/mixcall.appspot.com/o/user.png?alt=media&token=30cb61dc-dc75-4bfd-a6d8-927a9031bca2'
                                        ? Image.asset(
                                            'asset/img/logo.png',
                                            fit: BoxFit
                                                .cover, // 이미지가 컨테이너에 꽉 차게 표시
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              print('이미지 로드 에러: $error');
                                              return const Center(
                                                child: Text('이미지를 불러올 수 없습니다'),
                                              );
                                            },
                                          )
                                        : Image.network(
                                            data['photoUrl'],
                                            fit: BoxFit
                                                .cover, // 이미지가 컨테이너에 꽉 차게 표시
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              print('이미지 로드 에러: $error');
                                              return const Center(
                                                child: Text('이미지를 불러올 수 없습니다'),
                                              );
                                            },
                                          ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          KTextWidget(
                              text: data['proposalType'] == 'driver'
                                  ? maskLastCharacter(data['name'])
                                  : data['name'],
                              size: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          KTextWidget(
                              text: data['proposalType'] == 'driver'
                                  ? data['carInfo']
                                  : '전문 주선사',
                              size: 13,
                              fontWeight: null,
                              color: Colors.grey),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.star,
                                color: kOrangeBssetColor,
                                size: 14,
                              ),
                              const SizedBox(width: 5),
                              KTextWidget(
                                  text: '--',
                                  size: 14,
                                  fontWeight: FontWeight.bold,
                                  color: kOrangeBssetColor),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const KTextWidget(
                                  text: '제안 운송료',
                                  size: 14,
                                  fontWeight: null,
                                  color: Colors.grey),
                              const Spacer(),
                              KTextWidget(
                                  text: formatCurrency(data['price']),
                                  size: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              const SizedBox(width: 5),
                              const KTextWidget(
                                  text: '원',
                                  size: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)
                            ],
                          ),
                          Row(
                            children: [
                              const KTextWidget(
                                  text: '결제 방법',
                                  size: 14,
                                  fontWeight: null,
                                  color: Colors.grey),
                              const Spacer(),
                              KTextWidget(
                                  text: cargo['norPayType'],
                                  size: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Column(
                                children: [
                                  SizedBox(height: 3),
                                  Icon(
                                    Icons.info,
                                    color: Colors.grey,
                                    size: 14,
                                  ),
                                ],
                              ),
                              const SizedBox(width: 5),
                              SizedBox(
                                width: dw - 55,
                                child: KTextWidget(
                                    text: data['proposalType'] == 'driver'
                                        ? '실제 기사의 제안을 수락합니다.'
                                        : '전문 주선사의 제안을 수락합니다.',
                                    size: 14,
                                    fontWeight: null,
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Column(
                                children: [
                                  SizedBox(height: 3),
                                  Icon(
                                    Icons.info,
                                    color: Colors.grey,
                                    size: 14,
                                  ),
                                ],
                              ),
                              const SizedBox(width: 5),
                              SizedBox(
                                width: dw - 55,
                                child: const KTextWidget(
                                    text: '수락후 3분 이내에 응답하지 않으면 자동으로 취소됩니다.',
                                    size: 14,
                                    fontWeight: null,
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Column(
                                children: [
                                  SizedBox(height: 3),
                                  Icon(
                                    Icons.info,
                                    color: Colors.grey,
                                    size: 14,
                                  ),
                                ],
                              ),
                              const SizedBox(width: 5),
                              SizedBox(
                                width: dw - 55,
                                child: const KTextWidget(
                                    text:
                                        '혼적콜은 화물정보를 중개하는 것으로, 고객과 기사 또는 주선사의 위탁, 대행업무에 관여하지 않음으로 분쟁발생시 책임을 지지 않습니다. 단, 분쟁해결을 위해 적극적으로 정보를 제공합니다. 분쟁이 발생할 경우 고객센터로 문의하세요.',
                                    size: 14,
                                    fontWeight: null,
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          makePhoneCall(data['phone']);
                        },
                        child: Container(
                          height: 52,
                          //margin: const EdgeInsets.only(left: 10, right: 10),
                          width: dw,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: noState),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.phone,
                                color: Colors.grey,
                                size: 15,
                              ),
                              SizedBox(width: 5),
                              KTextWidget(
                                  text: '문의 전화하기',
                                  size: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context, true); // true 값을 명시적으로 반환
                        },
                        child: Container(
                          height: 52,
                          //  margin: const EdgeInsets.only(left: 10, right: 10),
                          width: dw,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: kGreenFontColor),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              KTextWidget(
                                  text: '제안 승락하기',
                                  size: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
        ));
      });
    },
  );
}
