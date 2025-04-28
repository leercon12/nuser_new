import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/model/multi_cargo_add_model.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class MultiDownCargoDialog extends StatelessWidget {
  final int? num;
  const MultiDownCargoDialog({super.key, required this.num});

  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;
    final addProvider = Provider.of<AddProvider>(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const KTextWidget(
                  text: '하차 화물 정보 등록',
                  size: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              const Expanded(child: SizedBox()),
              GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.cancel,
                    color: Colors.grey,
                  )),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: addProvider.locations.length,
              itemBuilder: (context, index) {
                final item = addProvider.locations[index];
                return InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context, index);
                    },
                    child: Container() // _downCargoList(item, dw),
                    );
              }),
          //  Expanded(child: _mainContents(addProvider)),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  /*  Widget _downCargoList(CargoLocation item, double dw) {
    return item.type == '하차'
        ? SizedBox()
        : Column(
            children: [
              /*   Divider(
          color: Colors.grey.withOpacity(0.5),
        ), */
              Container(
                //padding: const EdgeInsets.all(8),
                /* s */
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.imgFile != null)
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: noState.withOpacity(0.3)),
                        child: ClipRRect(
                          // 이미지에도 borderRadius 적용하기 위해 ClipRRect 사용
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            item.imgFile as File,
                            fit: BoxFit.cover, // 여기서 BoxFit 변경
                            errorBuilder: (context, error, stackTrace) {
                              print('이미지 로드 에러: $error');
                              return const Center(
                                child: Text('이미지를 불러올 수 없습니다'),
                              );
                            },
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: item.type == '상차'
                                ? kBlueBssetColor.withOpacity(0.3)
                                : kRedColor.withOpacity(0.3)),
                        child: Center(
                          child: RotatedBox(
                            quarterTurns: item.type == '상차' ? 3 : 1,
                            child: Icon(
                              Icons.double_arrow_rounded,
                              color: item.type == '상차'
                                  ? kBlueBssetColor
                                  : kRedColor,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        KTextWidget(
                            text: item.type == '상차'
                                ? '상차 화물 ${item.cargoWe}${item.cargoWeType}'
                                : '하차 화물  ${item.cargoWe}${item.cargoWeType}',
                            size: 14,
                            fontWeight: FontWeight.bold,
                            color: item.type == '상차'
                                ? kBlueBssetColor
                                : kRedColor),
                        const SizedBox(height: 5),
                        SizedBox(
                          width: dw - 94,
                          child: KTextWidget(
                              text: item.cargoType.toString(),
                              size: 13,
                              fontWeight: null,
                              color: Colors.white),
                        ),
                        if (item.cbm != null)
                          Row(
                            children: [
                              KTextWidget(
                                  text:
                                      'cbm ${item.cbm}, 가로 ${item.garo}m X 세로 ${item.garo}m X 높이 ${item.garo}m',
                                  size: 12,
                                  fontWeight: null,
                                  color: Colors.grey)
                            ],
                          )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              /*  Divider(
          color: Colors.grey.withOpacity(0.5),
        ) */
            ],
          );
  } */
}
