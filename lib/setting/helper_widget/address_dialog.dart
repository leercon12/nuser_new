import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class Address2Dialog extends StatefulWidget {
  final String callType;

  const Address2Dialog({
    super.key,
    required this.callType,
  });

  @override
  State<Address2Dialog> createState() => _Address2DialogState();
}

class _Address2DialogState extends State<Address2Dialog> {
  @override
  Widget build(BuildContext context) {
    final addProvider = Provider.of<AddProvider>(context);
    AddProvider _local = Provider.of<AddProvider>(context);
    return _local.dataA!['documents'].length == 0
        ? SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                KTextWidget(
                    text: '검색 결과가 없습니다.',
                    size: 14,
                    fontWeight: FontWeight.bold,
                    color: null),
              ],
            ),
          )
        : Column(
            children: [
              Row(
                children: [
                  const KTextWidget(
                      text: '주소 검색 내역',
                      size: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  const Expanded(child: SizedBox()),
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.cancel,
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: _local.dataA!['documents'].length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 270,
                                  child: KTextWidget(
                                    text:
                                        '${_local.dataA!['documents'][index]['address_name']}',
                                    size: 15,
                                    fontWeight: FontWeight.bold,
                                    color: null,
                                  ),
                                ),
                                SizedBox(
                                  width: 270,
                                  child: KTextWidget(
                                    text:
                                        '${_local.dataA!['documents'][index]['road_address']['zone_no']}',
                                    size: 14,
                                    fontWeight: FontWeight.bold,
                                    color: null,
                                  ),
                                ),
                              ],
                            ),
                            const Expanded(child: SizedBox()),
                            InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.pop(context, {
                                  'address_name': _local.dataA!['documents']
                                      [index]['address_name'],
                                  'zone_no': _local.dataA!['documents'][index]
                                      ['road_address']['zone_no'],
                                });
                              },
                              child: UnderLineWidget(
                                  text: '주소 선택',
                                  color: kBlueBssetColor,
                                  size: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
  }
}
