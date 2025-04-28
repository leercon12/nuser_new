import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/bottom_history/bottom_com_info.dart';
import 'package:flutter_mixcall_normaluser_new/pages/bottom_history/bottom_driver_info.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/sidePage/state_page/invoice/invoice.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/sidePage/state_page/multi/multi_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/sidePage/state_page/normal/normal_updown.dart';
import 'package:flutter_mixcall_normaluser_new/providers/hashProvider.dart';
import 'package:flutter_mixcall_normaluser_new/service/future_service.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/bottomSheet.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class SideStateMainPage extends StatefulWidget {
  final Map<String, dynamic> cargo;
  final String callType;
  const SideStateMainPage(
      {super.key, required this.cargo, required this.callType});

  @override
  State<SideStateMainPage> createState() => _SideStateMainPageState();
}

class _SideStateMainPageState extends State<SideStateMainPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.cargo['pickUserUid'] == null ? _noDiriver() : _driverInfo(),
            const SizedBox(height: 24),
            _ownerInfo(),
            const SizedBox(height: 24),
            _cargoState(),
          ],
        ),
      ),
    );
  }

  Widget _noDiriver() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KTextWidget(
            text: '기사님 정보',
            size: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: msgBackColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KTextWidget(
                  text: '아직 배정된 기사가 없습니다.',
                  size: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)
            ],
          ),
        ),
      ],
    );
  }

  List<String> carInfoList = [];
  Widget _driverInfo() {
    if (widget.cargo['driverCarInfo'] != null) {
      carInfoList = widget.cargo['driverCarInfo'].split('/');
    }

    final dw = MediaQuery.of(context).size.width;
    return widget.cargo['driverCarInfo'] == null
        ? const SizedBox()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const KTextWidget(
                  text: '기사님 정보',
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return StatefulBuilder(builder: (context, setState) {
                        return BottomDriverInfoPage(
                          pickUserUid: widget.cargo['pickUserUid'],
                          isReview: true,
                          cargo: widget.cargo,
                        );
                      });
                    },
                  );
                },
                child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: msgBackColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Image.network(widget.cargo['driverPhoto']),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      KTextWidget(
                                          text: widget.cargo['driverName'],
                                          size: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                      const SizedBox(width: 5),
                                      const KTextWidget(
                                          text: '기사님',
                                          size: 12,
                                          fontWeight: null,
                                          color: Colors.grey),
                                    ],
                                  ),
                                  //  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const KTextWidget(
                                          text: '차량 정보 ',
                                          size: 12,
                                          fontWeight: null,
                                          color: Colors.grey),
                                      SizedBox(
                                        width: dw - 180,
                                        child: Row(
                                          children: [
                                            KTextWidget(
                                                text:
                                                    ' ${carInfoList[2]}, ${carInfoList[1]}톤',
                                                size: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                            if (widget
                                                    .cargo['driverCarOption'] !=
                                                null)
                                              Expanded(
                                                child: KTextWidget(
                                                    text:
                                                        '| ${widget.cargo['driverCarOption']}',
                                                    size: 14,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const KTextWidget(
                                          text: '차량 번호 ',
                                          size: 12,
                                          fontWeight: null,
                                          color: Colors.grey),
                                      KTextWidget(
                                          text: ' ${carInfoList[0]}',
                                          size: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                makePhoneCall(
                                    widget.cargo['driverPhone'].toString());
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: noState),
                                child: const Center(
                                  child: Icon(
                                    Icons.phone,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ],
                        )
                      ],
                    )),
              ),
            ],
          );
  }

  Widget _ownerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KTextWidget(
            text: widget.cargo['isNormal'] == true ? '고객 정보' : '고객 & 주선사 정보',
            size: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey),
        const SizedBox(height: 12),
        _cunsumer(),
        if (widget.cargo['comUid'] != null) _com()
      ],
    );
  }

  Widget _cunsumer() {
    String clientInfo = widget.cargo['clientInfo'];
// 정규식으로 ' / 숫자' 패턴 제거
    String cleanedInfo = clientInfo.replaceAll(RegExp(r'\s\/\s\d+'), '');
    List<String> sbList = [cleanedInfo];
    RegExp phoneRegex = RegExp(r'\/\s*(\d+)');
    Match? match = phoneRegex.firstMatch(clientInfo);

    String phoneNumber = '';
    if (match != null && match.groupCount >= 1) {
      phoneNumber = match.group(1)!; // 추출된 전화번호
    }
    final hashProvider = Provider.of<HashProvider>(context);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: msgBackColor,
      ),
      child: Row(
        children: [
          const SizedBox(width: 5),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
            ),
            child: Image.asset('asset/img/cus.png'),
          ),
          const SizedBox(width: 13),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  KTextWidget(
                      text: sbList[0].length > 5
                          ? maskLastCharacter(
                              hashProvider.decryptData(sbList[0]))
                          : maskLastCharacter(sbList[0]),
                      size: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  const SizedBox(width: 5),
                  const KTextWidget(
                      text: '고객님',
                      size: 12,
                      fontWeight: null,
                      color: Colors.grey),
                ],
              ),
              widget.cargo['isNormal'] == true
                  ? const KTextWidget(
                      text: '고객님이 직접 등록한 운송건입니다.',
                      size: 12,
                      fontWeight: null,
                      color: Colors.grey)
                  : const KTextWidget(
                      text: '화물 운송을 의뢰하신 고객님 입니다.',
                      size: 12,
                      fontWeight: null,
                      color: Colors.grey),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();

              makePhoneCall(phoneNumber);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100), color: noState),
              child: const Center(
                child: Icon(
                  Icons.phone,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _com() {
    return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('cargoComInfo')
            .doc(widget.cargo['comUid'])
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              color: Colors.grey,
            ));
          }
          Map<String, dynamic> comData =
              snapshot.data!.data() as Map<String, dynamic>;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return StatefulBuilder(builder: (context, setState) {
                    return BottomComInfoPage(
                        comUid: widget.cargo['comUid'],
                        isReview: true,
                        cargo: widget.cargo,
                        userData: comData);
                  });
                },
              );
            },
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: msgBackColor,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 5),
                      Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: comData['logoUrl'] == null ||
                                  comData['logoUrl'] ==
                                      'https://firebasestorage.googleapis.com/v0/b/mixcall.appspot.com/o/comapny%2F4LTiwpYctZr12WwkCwqX%2Flogo.jpg?alt=media&token=b6a508ce-c7bf-4fc1-a7f6-496596375c1e'
                              ? Image.asset('asset/img/sign.png')
                              : Image.network(comData['logoUrl'])),
                      const SizedBox(width: 13),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              KTextWidget(
                                  text: comData['comName'],
                                  size: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              const SizedBox(width: 5),
                              const KTextWidget(
                                  text: '주선 사업소',
                                  size: 12,
                                  fontWeight: null,
                                  color: Colors.grey),
                            ],
                          ),
                          const KTextWidget(
                              text: '이곳을 클릭하여 상세정보를 확인하세요.',
                              size: 12,
                              fontWeight: null,
                              color: Colors.grey),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          makePhoneCall(widget.cargo['comPhone'].toString());
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: noState),
                          child: const Center(
                            child: Icon(
                              Icons.phone,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

///////////////////////
  ///
  ///

  Widget _cargoState() {
    return Column(
      children: [
        if (widget.cargo['aloneType'] == '왕복')
          FullStateMultiPage(cargo: widget.cargo, listId: '', callType: '왕복')
        else if (widget.cargo['aloneType'] == '다구간')
          FullStateMultiPage(cargo: widget.cargo, listId: '', callType: '다구간')
        else
          NormalUpDownState(
            cargo: widget.cargo,
          ),
        const SizedBox(height: 24),
        InvoiceState(
          cargo: widget.cargo,
        ),
      ],
    );
  }

  Widget _upState() {
    return Column(
      children: [],
    );
  }
}
