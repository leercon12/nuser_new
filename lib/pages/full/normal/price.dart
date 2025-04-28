import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/bottom/large_updown/la_updown.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';

class DetailPricePage extends StatelessWidget {
  final Map<String, dynamic> cargo;
  const DetailPricePage({super.key, required this.cargo});

  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: msgBackColor),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                'asset/img/tag.png',
                width: 15,
              ),
              const SizedBox(width: 5),
              const KTextWidget(
                  text: '결제 및 상태',
                  size: 14,
                  fontWeight: null,
                  color: Colors.white)
            ],
          ),
          const SizedBox(height: 12),
          if (cargo['norPayType'] == '직접 결제')
            Column(
              children: [
                KTextWidget(
                    text: cargo['norPayType'].toString(),
                    size: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                KTextWidget(
                    text: cargo['norPayHowto']
                        .toString()
                        .replaceAll(RegExp(r'[\[\]]'), ''),
                    size: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ],
            )
          else
            Column(
              children: [
                KTextWidget(
                    text: cargo['norPayType'].toString(),
                    size: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                const KTextWidget(
                    text: '후불, 포인트 결제',
                    size: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ],
            ),
          const SizedBox(height: 16),
          /*  Row(
            children: [
              Image.asset(
                'asset/img/tag.png',
                width: 15,
              ),
              const SizedBox(width: 5),
              const KTextWidget(
                  text: '현재 상태',
                  size: 14,
                  fontWeight: null,
                  color: Colors.white)
            ],
          ), */
          // const SizedBox(height: 12),
          LargeUpDown(
            cargo: cargo,
            dw: dw,
            callType: '노링크',
          ),
          /* const SizedBox(height: 12),
          Divider(
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(
                Icons.info,
                color: Colors.grey,
                size: 14,
              ),
              SizedBox(width: 5),
              KTextWidget(
                  text: '혼적콜은 화물운송 과정에 있어 관여하지 않습니다.',
                  size: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)
            ],
          ),
          const Row(
            children: [
              Icon(
                Icons.info,
                color: Colors.grey,
                size: 14,
              ),
              SizedBox(width: 5),
              KTextWidget(
                  text: '따라서, 발생할 수 있는 문제는 ',
                  size: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            color: Colors.grey.withOpacity(0.5),
          ), */
        ],
      ),
    );
  }

  Widget _noPick() {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.info,
              size: 15,
              color: Colors.grey,
            ),
            const SizedBox(width: 5),
            KTextWidget(
                text: 'text', size: 13, fontWeight: null, color: Colors.grey)
          ],
        )
      ],
    );
  }
}
