import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/full_main.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';

class PriceInput extends StatelessWidget {
  final Map<String, dynamic> messageData;
  const PriceInput({super.key, required this.messageData});

  @override
  Widget build(BuildContext context) {
    final int offerCount = messageData['priceOfferCount'] ?? 0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FullMainPage(
                    cargo: null,
                    normalId: messageData['uid'],
                    id: messageData['cargoId'],
                  )),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: msgBackColor,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: noState.withOpacity(0.7)),
                  child: Center(
                    child: Image.asset('asset/img/msg_input.png', width: 30),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        KTextWidget(
                            text: '새로운 ',
                            size: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        /*      KTextWidget(
                            text: '$messageCount개의 ',
                            size: 16,
                            fontWeight: FontWeight.bold,
                            color: kBlueBssetColor), */
                        KTextWidget(
                            text: '운송료 제안',
                            size: 16,
                            fontWeight: FontWeight.bold,
                            color: kBlueBssetColor),
                        KTextWidget(
                            text: '이 있습니다.',
                            size: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ],
                    ),
                    Row(
                      children: [
                        const KTextWidget(
                            text: '총 ',
                            size: 14,
                            fontWeight: null,
                            color: Colors.grey),
                        KTextWidget(
                            text: '${offerCount}개의 ',
                            size: 14,
                            fontWeight: FontWeight.bold,
                            color: kBlueBssetColor),
                        const KTextWidget(
                            text: '운송료 제안이 있어요.',
                            size: 14,
                            fontWeight: null,
                            color: Colors.grey),
                      ],
                    ),
                    const Row(
                      children: [
                        KTextWidget(
                            text: '이곳을 클릭하여, 제안된 운송료를 확인하세요.',
                            size: 14,
                            fontWeight: null,
                            color: Colors.grey),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        KTextWidget(
                            text: agoKorTimestamp(messageData['date']),
                            size: 14,
                            fontWeight: null,
                            color: Colors.grey),
                      ],
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
