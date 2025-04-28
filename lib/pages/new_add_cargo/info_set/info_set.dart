import 'package:delayed_widget/delayed_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/bottomSheet.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class AddInfoSet extends StatefulWidget {
  final String? callType;
  const AddInfoSet({super.key, this.callType});

  @override
  State<AddInfoSet> createState() => _AddInfoSetState();
}

class _AddInfoSetState extends State<AddInfoSet> {
  @override
  Widget build(BuildContext context) {
    final addProvider = Provider.of<AddProvider>(context);
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          // height: 125,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), color: msgBackColor),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KTextWidget(
                  text: '단골 또는 지정 주선사가 있으신가요?(필요시)',
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)
              //   UnderLineWidget(text: '단골 주선사, 기사가 있으신가요?', color: Colors.grey)
            ],
          ),
        ),
        if (addProvider.addMainType == '다구간' || addProvider.addMainType == '왕복')
          _cargoInfo(addProvider),
      ],
    );
  }

  Widget _cargoInfo(AddProvider addProvider) {
    final dw = MediaQuery.of(context).size.width;
    return SizedBox(
      width: dw,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Container(
            // height: 125,
            padding: const EdgeInsets.only(top: 15, bottom: 15),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), color: msgBackColor),
            child: Column(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 20),
                    const KTextWidget(
                        text: '상세 정보',
                        size: 14,
                        fontWeight: null,
                        color: Colors.grey),
                    const Expanded(child: SizedBox()),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        addProvider.setIsBlindState(false);
                      },
                      child: Container(
                        //width: 76,
                        padding: const EdgeInsets.only(right: 16),
                        height: 34,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: addProvider.setIsBlind == false
                                ? kGreenFontColor.withOpacity(0.16)
                                : null),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Icon(
                              Icons.check,
                              color: addProvider.setIsBlind == false
                                  ? kGreenFontColor
                                  : Colors.grey,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            KTextWidget(
                                text: '공개',
                                size: 15,
                                fontWeight: FontWeight.bold,
                                color: addProvider.setIsBlind == false
                                    ? kGreenFontColor
                                    : Colors.grey)
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        addProvider.setIsBlindState(true);
                      },
                      child: Container(
                        //  width: 76,
                        margin: const EdgeInsets.only(right: 16),
                        height: 34,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: addProvider.setIsBlind == true
                                ? kRedColor.withOpacity(0.16)
                                : null),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Icon(
                              Icons.check,
                              color: addProvider.setIsBlind == true
                                  ? kRedColor
                                  : Colors.grey,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            KTextWidget(
                                text: '비공개',
                                size: 15,
                                fontWeight: FontWeight.bold,
                                color: addProvider.setIsBlind == true
                                    ? kRedColor
                                    : Colors.grey),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Divider(
                    height: 1,
                    color: Colors.grey.withOpacity(0.25),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const SizedBox(width: 20),
                    const KTextWidget(
                        text: '동승 여부',
                        size: 14,
                        fontWeight: null,
                        color: Colors.grey),
                    const Expanded(child: SizedBox()),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        addProvider.isWithState(true);
                      },
                      child: Container(
                        height: 34,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: addProvider.isWith == true
                                ? kBlueBssetColor.withOpacity(0.16)
                                : null),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Icon(
                              Icons.check,
                              color: addProvider.isWith == true
                                  ? kBlueBssetColor
                                  : Colors.grey,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            KTextWidget(
                                text: '1인 동승',
                                size: 15,
                                fontWeight: FontWeight.bold,
                                color: addProvider.isWith == true
                                    ? kBlueBssetColor
                                    : Colors.grey),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        addProvider.isWithState(false);
                      },
                      child: Container(
                        //  width: 76,
                        height: 34,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: addProvider.isWith == false
                                ? kRedColor.withOpacity(0.16)
                                : null),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Icon(
                              Icons.check,
                              color: addProvider.isWith == false
                                  ? kRedColor
                                  : Colors.grey,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            KTextWidget(
                                text: '없음',
                                size: 15,
                                fontWeight: FontWeight.bold,
                                color: addProvider.isWith == false
                                    ? kRedColor
                                    : Colors.grey),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 13),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
