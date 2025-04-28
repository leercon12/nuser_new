import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/providers/hashProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';

import 'package:provider/provider.dart';

class ComInfoBottom extends StatefulWidget {
  final Map<String, dynamic> cargoData;
  final Map<String, dynamic> comInfo;
  const ComInfoBottom(
      {super.key, required this.cargoData, required this.comInfo});

  @override
  State<ComInfoBottom> createState() => _ComInfoBottomState();
}

class _ComInfoBottomState extends State<ComInfoBottom> {
  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.only(left: 18, right: 18),
          child: Column(
            children: [
              if (widget.comInfo == null)
                const SizedBox()
              else
                _step01(widget.cargoData)
            ],
          )),
    );
  }

  Widget _step01(Map<String, dynamic> cargoData) {
    final dw = MediaQuery.of(context).size.width;
    final dh = MediaQuery.of(context).size.height;
    final hashProvider = Provider.of<HashProvider>(context);
    var cargoData = widget.comInfo;
    return Column(
      children: [
        Column(
          children: [
            const SizedBox(height: 16),
            if (cargoData['logoUrl'] == null)
              const SizedBox()
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: cargoData['logoUrl'],
                      fit: BoxFit.cover, // 이미지를 컨테이너에 맞춰서 보여줍니다.
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Row(
                children: [
                  const SizedBox(
                    width: 68,
                    child: KTextWidget(
                        text: '상 호',
                        size: 14,
                        fontWeight: null,
                        color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  KTextWidget(
                      text: cargoData['comName'].toString(),
                      size: 14,
                      fontWeight: null,
                      color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(
              height: 2,
              color: dialogColor,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Row(
                children: [
                  const SizedBox(
                    width: 68,
                    child: KTextWidget(
                        text: '사업자 번호',
                        size: 14,
                        fontWeight: null,
                        color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  KTextWidget(
                      text: cargoData['comNum'].toString(),
                      size: 14,
                      fontWeight: null,
                      color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(
              height: 2,
              color: dialogColor,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Row(
                children: [
                  const SizedBox(
                    width: 68,
                    child: KTextWidget(
                        text: '대표 이메일',
                        size: 14,
                        fontWeight: null,
                        color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  KTextWidget(
                      text: cargoData['comEmail'].toString(),
                      size: 14,
                      fontWeight: null,
                      color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(
              height: 2,
              color: dialogColor,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Row(
                children: [
                  const SizedBox(
                    width: 68,
                    child: KTextWidget(
                        text: '대표 전화',
                        size: 14,
                        fontWeight: null,
                        color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  KTextWidget(
                      text: cargoData['tel'].toString(),
                      size: 14,
                      fontWeight: null,
                      color: Colors.white),
                ],
              ),
            ),
            if (cargoData['fax'] != null && cargoData['fax'] != '')
              Column(
                children: [
                  const SizedBox(height: 16),
                  const Divider(
                    height: 2,
                    color: dialogColor,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 68,
                          child: KTextWidget(
                              text: 'Fax 번호',
                              size: 14,
                              fontWeight: null,
                              color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        KTextWidget(
                            text: cargoData['fax'].toString(),
                            size: 14,
                            fontWeight: null,
                            color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            const Divider(
              height: 2,
              color: dialogColor,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Row(
                children: [
                  const SizedBox(
                    width: 68,
                    child: KTextWidget(
                        text: '대표자',
                        size: 14,
                        fontWeight: null,
                        color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  KTextWidget(
                      text: hashProvider.decryptData(cargoData['masterName']),
                      size: 14,
                      fontWeight: null,
                      color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(
              height: 2,
              color: dialogColor,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Row(
                children: [
                  const SizedBox(
                    width: 68,
                    child: KTextWidget(
                        text: '업태, 종목',
                        size: 14,
                        fontWeight: null,
                        color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  KTextWidget(
                      text:
                          '${cargoData['comClass']} / ${cargoData['comType']}',
                      size: 14,
                      fontWeight: null,
                      color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(
              height: 2,
              color: dialogColor,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Row(
                children: [
                  const SizedBox(
                    width: 68,
                    child: KTextWidget(
                        text: '사업자 주소',
                        size: 14,
                        fontWeight: null,
                        color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: dw - 148,
                    child: KTextWidget(
                        text: cargoData['comAddress'] +
                            " " +
                            cargoData['comAddressDis'] +
                            ' (${cargoData['zone1']})',
                        size: 14,
                        fontWeight: null,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
            if (cargoData['comAddress2'] != "")
              Column(
                children: [
                  const Divider(
                    height: 2,
                    color: dialogColor,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 68,
                          child: KTextWidget(
                              text: '우편물 주소',
                              size: 14,
                              fontWeight: null,
                              color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: dw - 148,
                          child: KTextWidget(
                              text: cargoData['comAddress2'] +
                                  " " +
                                  cargoData['comAddressDis2'] +
                                  ' (${cargoData['zone2']})',
                              size: 14,
                              fontWeight: null,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            const SizedBox(height: 16),
            if (cargoData['sjNum'] != null)
              Column(
                children: [
                  const Divider(
                    height: 2,
                    color: dialogColor,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 68,
                          child: KTextWidget(
                              text: '산재 보헙\n' + cargoData['sjType'],
                              size: 14,
                              fontWeight: null,
                              color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: dw - 148,
                          child: KTextWidget(
                              text: cargoData['sjNum'],
                              size: 14,
                              fontWeight: null,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _step02(
    Map<String, dynamic> cargoData,
  ) {
    final dw = MediaQuery.of(context).size.width;
    final dh = MediaQuery.of(context).size.height;
    final hashProvider = Provider.of<HashProvider>(context);
    return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('user_driver')
            .doc(widget.cargoData['uid'])
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: cargoData['userProfileIMG'],
                        fit: BoxFit.cover, // 이미지를 컨테이너에 맞춰서 보여줍니다.
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 68,
                          child: KTextWidget(
                              text: '상 호',
                              size: 14,
                              fontWeight: null,
                              color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        KTextWidget(
                            text: cargoData['businessName'].toString(),
                            size: 14,
                            fontWeight: null,
                            color: Colors.white),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(
                    height: 2,
                    color: dialogColor,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 68,
                          child: KTextWidget(
                              text: '사업자 번호',
                              size: 14,
                              fontWeight: null,
                              color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        KTextWidget(
                            text: cargoData['businessNum'].toString(),
                            size: 14,
                            fontWeight: null,
                            color: Colors.white),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(
                    height: 2,
                    color: dialogColor,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 68,
                          child: KTextWidget(
                              text: '대표 이메일',
                              size: 14,
                              fontWeight: null,
                              color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        KTextWidget(
                            text: cargoData['businessEmail'].toString(),
                            size: 14,
                            fontWeight: null,
                            color: Colors.white),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(
                    height: 2,
                    color: dialogColor,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 68,
                          child: KTextWidget(
                              text: '대표 전화',
                              size: 14,
                              fontWeight: null,
                              color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        KTextWidget(
                            text: cargoData['phone'].toString(),
                            size: 14,
                            fontWeight: null,
                            color: Colors.white),
                      ],
                    ),
                  ),
                  if (cargoData['fax'] != null && cargoData['fax'] != '')
                    Column(
                      children: [
                        const SizedBox(height: 16),
                        const Divider(
                          height: 2,
                          color: dialogColor,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 68,
                                child: KTextWidget(
                                    text: 'Fax 번호',
                                    size: 14,
                                    fontWeight: null,
                                    color: Colors.grey),
                              ),
                              const SizedBox(width: 12),
                              KTextWidget(
                                  text: cargoData['fax'].toString(),
                                  size: 14,
                                  fontWeight: null,
                                  color: Colors.white),
                            ],
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  const Divider(
                    height: 2,
                    color: dialogColor,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 68,
                          child: KTextWidget(
                              text: '대표자',
                              size: 14,
                              fontWeight: null,
                              color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        KTextWidget(
                            text: cargoData['name'],
                            size: 14,
                            fontWeight: null,
                            color: Colors.white),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(
                    height: 2,
                    color: dialogColor,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 68,
                          child: KTextWidget(
                              text: '업태, 종목',
                              size: 14,
                              fontWeight: null,
                              color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        KTextWidget(
                            text:
                                '${cargoData['businessType01']} / ${cargoData['businessType02']}',
                            size: 14,
                            fontWeight: null,
                            color: Colors.white),
                      ],
                    ),
                  ),
                  if (cargoData['busAds'] != null)
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 16, right: 16, top: 16),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 68,
                            child: KTextWidget(
                                text: '사업장 주소지',
                                size: 14,
                                fontWeight: null,
                                color: Colors.grey),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            children: [
                              KTextWidget(
                                  text:
                                      '${cargoData['busAds']} / ${cargoData['zone1']}',
                                  size: 14,
                                  fontWeight: null,
                                  color: Colors.white),
                              KTextWidget(
                                  text: cargoData['busDis'],
                                  size: 14,
                                  fontWeight: null,
                                  color: Colors.grey),
                            ],
                          ),
                        ],
                      ),
                    ),
                  if (cargoData['busAds2'] != null)
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 16, right: 16, top: 16),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 68,
                            child: KTextWidget(
                                text: '사업장 주소지',
                                size: 14,
                                fontWeight: null,
                                color: Colors.grey),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            children: [
                              KTextWidget(
                                  text:
                                      '${cargoData['busAds2']} (${cargoData['zone2']})',
                                  size: 14,
                                  fontWeight: null,
                                  color: Colors.white),
                              KTextWidget(
                                  text: cargoData['busDis2'],
                                  size: 14,
                                  fontWeight: null,
                                  color: Colors.grey),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Divider(
                    height: 2,
                    color: dialogColor,
                  ),
                  const SizedBox(height: 16),
                  /* Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 68,
                      child: KTextWidget(
                          text: '사업자 주소',
                          size: 14,
                          fontWeight: null,
                          color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: dw - 148,
                      child: KTextWidget(
                          text:
                              cargoData['comAddress'] + ' (${cargoData['zone1']})',
                          size: 14,
                          fontWeight: null,
                          color: Colors.white),
                    ),
                  ],
                ),
              ), */
                  const SizedBox(height: 16),
                  if (cargoData['comAddress2'] != null)
                    Column(
                      children: [
                        const Divider(
                          height: 2,
                          color: dialogColor,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 68,
                                child: KTextWidget(
                                    text: '우편물 주소',
                                    size: 14,
                                    fontWeight: null,
                                    color: Colors.grey),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: dw - 148,
                                child: KTextWidget(
                                    text: cargoData['comAddress2'] +
                                        ' (${cargoData['zone2']})',
                                    size: 14,
                                    fontWeight: null,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  if (cargoData['sjNum'] != null)
                    Column(
                      children: [
                        const Divider(
                          height: 2,
                          color: dialogColor,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 68,
                                child: KTextWidget(
                                    text: '산재 보헙\n' + cargoData['sjType'],
                                    size: 14,
                                    fontWeight: null,
                                    color: Colors.grey),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: dw - 148,
                                child: KTextWidget(
                                    text: cargoData['sjNum'],
                                    size: 14,
                                    fontWeight: null,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    )
                ],
              ),
            );
          }
          return const SizedBox();
        });
  }
}
