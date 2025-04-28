import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/btn/btn_state.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/multi/widget/cargo.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/multi/widget/price.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/multi/widget/updown_first.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/normal/cargo_info.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class FullMultiMainPage extends StatelessWidget {
  final Map<String, dynamic> cargo;
  const FullMultiMainPage({super.key, required this.cargo});

  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Text(cargo['id']),
                FullUpDownFirstPage(callType: '', cargoData: cargo),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 3,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.grey.withOpacity(0.2)),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                FullMultiCargoPage(callType: '', cargoData: cargo),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 3,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.grey.withOpacity(0.2)),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                FullMultiPricePage(
                  callType: '',
                  cargoData: cargo,
                ),
                const SizedBox(height: 8),
                fullCaution(dw),
                const SizedBox(height: 50),
                FullBtnState(
                  cargo: cargo,
                  callType: '왕복',
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        if (cargo['isShow'] == false)
          Positioned.fill(
              child: Container(
            color: msgBackColor.withOpacity(0.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: dw * 0.6,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: msgBackColor),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.info,
                        color: kOrangeAssetColor,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      const KTextWidget(
                          text: '비활성된 운송입니다.',
                          size: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      const SizedBox(height: 8),
                      const KTextWidget(
                          text: '현재 화물이 비활성된 상태입니다.\n운송을 활성하시려면 아래 버튼을 클릭하세요.',
                          size: 12,
                          textAlign: TextAlign.center,
                          fontWeight: null,
                          color: Colors.grey),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          await FirebaseFirestore.instance
                              .collection('cargoLive')
                              .doc(cargo['id'])
                              .update({'isShow': true});

                          await FirebaseFirestore.instance
                              .collection('cargoInfo')
                              .doc(cargo['uid'])
                              .collection(extractFour(cargo['id']))
                              .doc(cargo['id'])
                              .update({'isShow': true});
                        },
                        child: Container(
                          width: 150,
                          padding: const EdgeInsets.only(
                              top: 6, bottom: 6, right: 8, left: 8),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: kOrangeAssetColor),
                          child: const Center(
                            child: KTextWidget(
                                text: '운송 활성',
                                size: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                )
              ],
            ),
          ))
      ],
    );
  }
}
