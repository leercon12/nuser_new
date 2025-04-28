import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class NotiCationPage extends StatefulWidget {
  const NotiCationPage({super.key});

  @override
  State<NotiCationPage> createState() => _NotiCationPageState();
}

class _NotiCationPageState extends State<NotiCationPage> {
  int? _selectedItemIndex; // 선택된 항목의 인덱스

  @override
  void initState() {
    super.initState();
    _selectedItemIndex = null; // 초기에는 선택된 항목이 없음
  }

  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('notice')
          .orderBy('date', descending: true)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 데이터를 가져오는 중일 때의 UI
          return const SizedBox();
        } else if (snapshot.hasError) {
          // 데이터 가져오는 동안 에러가 발생한 경우의 UI
          return Text('Error: ${snapshot.error}');
        } else {
          // 데이터를 성공적으로 가져온 경우의 UI
          List<DocumentSnapshot> documents = snapshot.data!.docs;

          return Column(
            children: [
              const SizedBox(height: 5),
              Expanded(
                child: ListView.builder(
                  itemCount: documents.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        //const SizedBox(height: 10),
                        if (documents[index]['userType'].contains('all') ||
                            documents[index]['userType'].contains('normal'))
                          _test(documents[index], index)
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _test(DocumentSnapshot<Object?> document, int index) {
    final isSelected = _selectedItemIndex == index;
    final dw = MediaQuery.of(context).size.width;
    return Padding(
        padding: const EdgeInsets.only(top: 10, left: 5, right: 5),
        child: GestureDetector(
          onTap: () async {
            HapticFeedback.lightImpact();
            /*  setState(() {
              // 선택된 항목이 다른 항목이면 선택 상태 업데이트
              if (_selectedItemIndex != index) {
                _selectedItemIndex = index;
              } else {
                // 이미 선택된 항목을 다시 탭하면 선택 해제
                _selectedItemIndex = null;
              }
            }); */
            var url = '${document['contents']}';
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              throw 'Could not launch $url';
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(10),
            height: isSelected ? null : null,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5), color: msgBackColor),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.grey[800]),
                  child: Center(
                      child: document['type'] == 'test'
                          ? Image.asset('asset/img/msg_test.png')
                          : document['type'] == 'tip'
                              ? Image.asset('asset/img/msg_tip.png')
                              : Image.asset('asset/img/msg_event.png')),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: dw - 65,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KTextWidget(
                          text: document['title'].toString(),
                          size: 18,
                          fontWeight: FontWeight.bold,
                          color: null),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /*  KTextWidget(
                                    text: document['contents'].toString(),
                                    size: 16,
                                    overflow: TextOverflow.ellipsis,
                                    fontWeight: null,
                                    color: Colors.grey), */
                          const SizedBox(height: 5),
                          KTextWidget(
                              text:
                                  formatDateKorTime(document['date'].toDate()),
                              size: 13,
                              fontWeight: null,
                              color: Colors.grey)
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _sel(DocumentSnapshot<Object?> document) {
    final dw = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        if (document['img'] != 'def')
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              /* showDialog(
                context: context,
                builder: (context) => FullScreenImageDialog(
                  imagePath: document['img'],
                  callType: 'url',
                ),
              ); */
            },
            child: Container(
              width: dw - 56,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                // ClipRRect로 이미지를 감싸서 borderRadius 적용
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: document['img'].toString(),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        SizedBox(
          width: dw - 56,
          child: Text(
            document['contents'].toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: null,
              color: Colors.grey,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 15),
        KTextWidget(
            text: formatDateKorTime(document['date'].toDate()),
            size: 13,
            fontWeight: null,
            color: Colors.grey)
      ],
    );
  }
}
