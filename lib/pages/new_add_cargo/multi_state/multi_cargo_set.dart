import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/multi_state/multi_cargo_widget.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/multi_state/updown/updown_set.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/normal_state/up_down/set_page/updown_set.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/bottomSheet.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class MultiCargoSetPage extends StatefulWidget {
  final String? callType;
  const MultiCargoSetPage({super.key, this.callType});

  @override
  State<MultiCargoSetPage> createState() => _MultiCargoSetPageState();
}

class _MultiCargoSetPageState extends State<MultiCargoSetPage> {
  String _type = '상차지'; // 상태 변수를 여기서 선언
  @override
  Widget build(BuildContext context) {
    final addProvider = Provider.of<AddProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '다구간 상, 하차 등록',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              if (addProvider.locationCount >= 3) {
                HapticFeedback.lightImpact();
                context.read<AddProvider>().checkAndUpdateRoute();
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    errorSnackBar('다구간은 3개 이상의 상, 하차지가 필요합니다.', context));
              }
            },
            child: const KTextWidget(
                text: '등록',
                size: 16,
                fontWeight: FontWeight.bold,
                color: kGreenFontColor),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: addProvider.locations.length + 1, // +1 for nullBox
            itemBuilder: (context, index) {
              // 마지막 아이템이면 nullBox 리턴
              if (index == addProvider.locations.length) {
                return _nullBox(addProvider);
              }

              // 그 외에는 리스트 아이템 표시
              final cargo = addProvider.locations[index];
              return MultiCargoWidget(
                no: index,
                cargo: cargo,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _nullBox(AddProvider addProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (addProvider.locations.length <= 14)
          GestureDetector(
            onTap: () {
              if (addProvider.locations.isNotEmpty &&
                  addProvider.locations.last.dateType == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                    errorSnackBar('이전 상, 하차 정보를 모두 입력하세요.', context));
              } else {
                HapticFeedback.lightImpact();

                addProvider.clearCargos();
                addProvider.addUpSenderTypeState(null);

                addProvider.locationsIndexState(addProvider.locationCount);
                addBottomSheet(context, false);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), color: msgBackColor),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  KTextWidget(
                      text: '이곳을 클릭하여 상, 하차 정보를 등록하세요.',
                      size: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        const Row(
          children: [
            Icon(Icons.info, size: 13, color: Colors.grey),
            SizedBox(width: 5),
            KTextWidget(
                text: '다양한 상, 하차지를 직접 구성할 수 있습니다.',
                size: 13,
                fontWeight: null,
                color: Colors.grey)
          ],
        ),
        const Row(
          children: [
            Icon(Icons.info, size: 13, color: Colors.grey),
            SizedBox(width: 5),
            KTextWidget(
                text: '최대 15개의 상, 하차지를 등록할 수 있습니다.',
                size: 13,
                fontWeight: null,
                color: Colors.grey)
          ],
        ),
        const Row(
          children: [
            Icon(Icons.info, size: 13, color: Colors.grey),
            SizedBox(width: 5),
            KTextWidget(
                text: '15개 이상의 상, 하차지를 등록하려면 혼적콜에 문의하세요.',
                size: 13,
                fontWeight: null,
                color: Colors.grey)
          ],
        ),
      ],
    );
  }
}

void addBottomSheet(context, bool isMid) {
  final dw = MediaQuery.of(context).size.width;
  final addProvider = Provider.of<AddProvider>(context, listen: false);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return BottomSheetWidget(
            contents: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              Icon(Icons.info, size: 70, color: Colors.grey.withOpacity(0.5)),
              const SizedBox(height: 40),
              const KTextWidget(
                  text: '다구간 화물의 상, 하차정보를 입력하세요.',
                  size: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              const KTextWidget(
                  text: '등록하실 유형을 선택하시면, 등록 페이지로 연결됩니다.',
                  size: 14,
                  fontWeight: null,
                  color: Colors.grey),
              const KTextWidget(
                  text: '상차와 하차가 모두 필요한 경우에는 하차지로 등록하세요.',
                  size: 14,
                  fontWeight: null,
                  color: Colors.grey),

              const SizedBox(height: 40),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                  addProvider.resetUpLocationData();
                  addProvider.cargoImageState(null);
                  addProvider.addCargoInfoState(null);
                  addProvider.addCargoTonState(null);
                  addProvider.addCargotonStringState('톤');
                  addProvider.addCargoCbmState(null);
                  addProvider.addCargoSizedState(null, null, null);
                  addProvider.clearCargos();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MultiUpDownSetPage(
                              callType: '다구간_상차',
                              isMidUpdate: isMid,
                            )),
                  );
                },
                child: Container(
                  height: 52,
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  width: dw,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: kBlueBssetColor.withOpacity(0.1)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'asset/img/cargo_up.png',
                        width: 16,
                        height: 16,
                      ),
                      const SizedBox(width: 5),
                      const KTextWidget(
                          text: '상차지 등록',
                          size: 15,
                          fontWeight: FontWeight.bold,
                          color: kBlueBssetColor)
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                  addProvider.resetDownLocationData();
                  addProvider.cargoImageState(null);
                  addProvider.addCargoInfoState(null);
                  addProvider.addCargoTonState(null);
                  addProvider.addCargotonStringState('톤');
                  addProvider.addCargoCbmState(null);
                  addProvider.addCargoSizedState(null, null, null);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MultiUpDownSetPage(
                              callType: '다구간_하차',
                              isMidUpdate: isMid,
                            )),
                  );
                },
                child: Container(
                  height: 52,
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  width: dw,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: kRedColor.withOpacity(0.1)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'asset/img/cargo_down.png',
                        width: 16,
                        height: 16,
                      ),
                      const SizedBox(width: 5),
                      const KTextWidget(
                          text: '하차지 등록',
                          size: 15,
                          fontWeight: FontWeight.bold,
                          color: kRedColor)
                    ],
                  ),
                ),
              ),
              //const SizedBox(height: 10),
            ],
          ),
        ));
      });
    },
  );
}
