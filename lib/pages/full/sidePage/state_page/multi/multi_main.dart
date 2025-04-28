import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/sidePage/state_page/invoice/invoice.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/service/pick_image_service.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/image_dialog.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class FullStateMultiPage extends StatefulWidget {
  final Map<String, dynamic> cargo;
  final String? listId;
  final String callType;

  const FullStateMultiPage(
      {super.key,
      required this.cargo,
      required this.listId,
      required this.callType});

  @override
  State<FullStateMultiPage> createState() => _FullStateMultiPageState();
}

class _FullStateMultiPageState extends State<FullStateMultiPage> {
  late PageController _pageController;
  late int currentPage;

  @override
  void initState() {
    super.initState();
    final locations = widget.cargo['locations'] as List;
    // 마지막으로 완료된 위치의 다음 페이지를 찾기
    int lastCompletedIndex = findLastCompletedLocation(locations);
    // 다음 페이지를 초기 페이지로 설정 (마지막 페이지를 넘지 않도록)
    currentPage = (lastCompletedIndex + 1).clamp(0, locations.length - 1);

    _pageController = PageController(
      initialPage: currentPage,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int findLastCompletedLocation(List locations) {
    int lastDoneIndex = -1; // -1로 시작하여 아무것도 완료되지 않은 경우 처리
    for (int i = 0; i < locations.length; i++) {
      if (locations[i]['isDone'] == true) {
        lastDoneIndex = i;
      }
    }
    return lastDoneIndex;
  }

  int? _page;

  @override
  Widget build(BuildContext context) {
    final locations = widget.cargo['locations'] as List;
    final pageCount = locations.length;

    return SizedBox(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KTextWidget(
            text: widget.callType == '왕복' ? '왕복 운송 상태' : '다구간 운송 상태',
            size: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey),
        const SizedBox(height: 12),
        _step01(locations),
        //   DonePaperState(cargo: widget.cargo),
        /*   if (widget.cargo['payType'] == '인수증')
          AllNewEtaxPage(cargoData: widget.cargo), */
      ],
    ));
  }

  Widget _step01(List<dynamic> locations) {
    final pageCount = locations.length;
    final mapProvider = Provider.of<MapProvider>(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            color: msgBackColor,
          ),
          child: Column(
            children: [
              SizedBox(
                  height: 35,
                  child: Container(
                    height: 42,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: pageCount,
                      itemBuilder: (context, index) {
                        final pageNumber = index + 1;
                        final isCompleted = locations[index]['isDone'] == true;
                        final isCurrentPage = index == currentPage;

                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 5),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                height: 32,
                                width: widget.callType == '왕복' ? null : 32,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isCompleted
                                        ? locations[index]['type'] == '상차'
                                            ? isCurrentPage
                                                ? kBlueBssetColor
                                                : kBlueBssetColor
                                                    .withOpacity(0.5)
                                            : isCurrentPage
                                                ? kRedColor
                                                : kRedColor.withOpacity(0.5)
                                        : isCurrentPage
                                            ? locations[index]['type'] == '상차'
                                                ? kBlueBssetColor
                                                : kRedColor
                                            : Colors.grey.withOpacity(0.3),
                                    //width: isCurrentPage ? 3 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: KTextWidget(
                                    text: widget.callType == '왕복'
                                        ? pageNumber == 1
                                            ? '시작'
                                            : pageNumber == 2
                                                ? '회차(경유)'
                                                : '종료'
                                        : pageNumber.toString(),
                                    size: widget.callType == '왕복' ? 16 : 18,
                                    fontWeight: FontWeight.bold,
                                    color: isCompleted
                                        ? locations[index]['type'] == '상차'
                                            ? isCurrentPage
                                                ? kBlueBssetColor
                                                : kBlueBssetColor
                                                    .withOpacity(0.5)
                                            : isCurrentPage
                                                ? kRedColor
                                                : kRedColor.withOpacity(0.5)
                                        : isCurrentPage
                                            ? locations[index]['type'] == '상차'
                                                ? kBlueBssetColor
                                                : kRedColor
                                            : Colors.grey.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )),
              SizedBox(
                height: 70,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pageCount,
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final location = locations[index];
                    return _upState(location, currentPage);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (locations[currentPage]['isDone'] == true)
          Center(
            child: Container(
              height: 52,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12)),
                color: locations[currentPage]['type'] == '상차'
                    ? kBlueBssetColor.withOpacity(0.3)
                    : kRedColor.withOpacity(0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.callType == '왕복')
                    KTextWidget(
                        text: currentPage == 0
                            ? '시작 지점 ${locations[currentPage]['type']} 완료, ${formatDateKorTime(locations[currentPage]['isDoneDate'].toDate())}'
                            : currentPage == 1
                                ? '회차 지점 ${locations[currentPage]['type']} 완료, ${formatDateKorTime(locations[currentPage]['isDoneDate'].toDate())}'
                                : '종료 지점 ${locations[currentPage]['type']} 완료, ${formatDateKorTime(locations[currentPage]['isDoneDate'].toDate())}',
                        size: 16,
                        fontWeight: FontWeight.bold,
                        color: locations[currentPage]['type'] == '상차'
                            ? kBlueBssetColor
                            : kRedColor)
                  else
                    KTextWidget(
                        text:
                            '${currentPage + 1}번 ${locations[currentPage]['type']} 완료, ${formatDateKorTime(locations[currentPage]['isDoneDate'].toDate())}',
                        size: 16,
                        fontWeight: FontWeight.bold,
                        color: locations[currentPage]['type'] == '상차'
                            ? kBlueBssetColor
                            : kRedColor),
                ],
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12)),
              color: msgBackColor,
            ),
            child: GestureDetector(
              onTap: () async {
                HapticFeedback.lightImpact();
                mapProvider.isLoadingState(true);
                if (widget.callType == '왕복') {
                  await stateMultiUpdateNoImg(widget.cargo['type'].toString(),
                      currentPage, 0, widget.cargo, true);
                } else {
                  await stateMultiUpdateNoImg(widget.cargo['type'].toString(),
                      currentPage, 0, widget.cargo, false);
                }

                mapProvider.isLoadingState(false);
              },
              child: Container(
                height: 52,
                padding:
                    const EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: locations[currentPage]['type'] == '상차'
                        ? kBlueBssetColor
                        : kRedColor),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.callType == '왕복')
                      KTextWidget(
                          text: currentPage == 0
                              ? '시작 ${locations[currentPage]['type']} 완료 보고'
                              : currentPage == 1
                                  ? '회차(경유지) ${locations[currentPage]['type']} 완료 보고'
                                  : '종료 ${locations[currentPage]['type']} 완료 보고',
                          size: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)
                    else
                      KTextWidget(
                          text: locations[currentPage]['isDone'] == true
                              ? '${currentPage + 1}번 ${locations[currentPage]['type']} 완료'
                              : '${locations[currentPage]['type']} 완료 보고',
                          size: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)
                  ],
                ),
              ),
            ),
          )
      ],
    );
  }

  Widget _upState(dynamic location, int page) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            _imgBox(widget.cargo['type'].toString(), page, 0),
            _imgBox(widget.cargo['type'].toString(), page, 1),
            _imgBox(widget.cargo['type'].toString(), page, 2),
          ],
        ),
      ],
    );
  }

  Widget _imgBox(
    String callType,
    int index,
    int count,
  ) {
    final mapProvider = Provider.of<MapProvider>(context);
    final addProvider = Provider.of<AddProvider>(context);
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();

        addProvider.cargoImageState(null);
        if (widget.cargo['locationUrl${index}_${count}'] == null) {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return PickImageBottom(
                callType: '상차보고',
                comUid: widget.cargo['uid'].toString(),
                count: count,
              );
            },
          ).then((value) async {
            print('@@@@@@@@@');
            if (value != null) {
              print(value);

              if (value == true) {
                try {
                  print(callType);
                  mapProvider.isLoadingState(true);
                  await doneMultiPhotoUpdate(
                      callType,
                      index,
                      count,
                      widget.cargo,
                      addProvider.cargoImage as File,
                      widget.callType == '왕복' ? true : false);
                  mapProvider.isLoadingState(false);
                } catch (e) {
                  print(e);
                }
              }
            }
          });
        } else {
          await showDialog(
            context: context,
            builder: (context) => ImageViewerDialog(
              networkUrl:
                  widget.cargo['locationUrl${index}_${count}'][0].toString(),
              cargo: widget.cargo['locationUrl${index}_${count}'],
            ),
          ).then((value) async {
            if (value != null) {
              print(value);

              String name = 'locationUrl${index}_${count}';
              if (widget.cargo['comUid'] == null) {
                await FirebaseFirestore.instance
                    .collection('cargoInfo')
                    .doc(widget.cargo['uid'])
                    .collection(extractFour(widget.cargo['id']))
                    .doc(widget.cargo['id'])
                    .update({
                  name: null,
                });
              } else {
                await FirebaseFirestore.instance
                    .collection('cargoInfo')
                    .doc(widget.cargo['uid'])
                    .collection(extractFour(widget.cargo['id']))
                    .doc(widget.cargo['id'])
                    .update({
                  name: null,
                });
                await FirebaseFirestore.instanceFor(
                        app: FirebaseFirestore.instance.app,
                        databaseId: 'mixcallcompany')
                    .collection(widget.cargo['comUid'])
                    .doc('cargoInfo')
                    .collection(extractFour(widget.cargo['id']))
                    .doc(widget.cargo['id'])
                    .update({
                  name: null,
                });
              }
            }
          });
        }
      },
      child: Container(
        width: 60,
        height: 60,
        margin: const EdgeInsets.only(right: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: noState,
        ),
        child: widget.cargo['locationUrl${index}_${count}'] == null
            ? const Center(
                child: Icon(
                  Icons.add,
                  color: Colors.grey,
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: widget.cargo['locationUrl${index}_${count}'][0],
                  fit: BoxFit.cover, // 이미지를 컨테이너에 맞춰서 보여줍니다.
                ),
              ),
      ),
    );
  }
}

Future stateMultiUpdateNoImg(
  String callType,
  int index,
  int imgNum,
  Map<String, dynamic> cargo,
  bool isReturn,
) async {
// 전체 locations 배열 복사
  List<dynamic> updatedLocations = List.from(cargo['locations']);

// 특정 인덱스의 location 업데이트
  Map<String, dynamic> updatedLocation = Map.from(cargo['locations'][index]);
  updatedLocation['isDone'] = true;
  updatedLocation['isDoneDate'] = DateTime.now();

// 수정된 location을 배열에 다시 넣기 (이 부분이 빠져있었습니다)
  updatedLocations[index] = updatedLocation;

// 최종 업데이트 데이터 준비

  List _all = cargo['locations'];

  bool isAllDone() {
    return _all.every((item) => item['isDone'] == true);
  }

  String msg = (_all.length == index + 1 || isAllDone())
      ? isReturn
          ? '하차완료'
          : '운송완료'
      : isReturn
          ? index == 0
              ? '상차완료'
              : index == 1
                  ? '회차완료'
                  : '하차완료'
          : '${index + 1}번 ${cargo['locations'][index]['type']}완료';

  print('_____________________________________________');
  print(_all.length);
  print(index);
  Map<String, dynamic> finalUpdateData = {
    'locations': updatedLocations,
    'cargoStat': msg,
    'updatedAt': DateTime.now(),
  };

  await FirebaseFirestore.instance
      .collection('user_driver_cargo')
      .doc(cargo['pickUserUid'])
      .collection('history')
      .doc(cargo['id'])
      .update({'state': msg, 'updatedAt': DateTime.now()});

  if (cargo['comUid'] != null) {
    await FirebaseFirestore.instanceFor(
            app: FirebaseFirestore.instance.app, databaseId: 'mixcallcompany')
        .collection(cargo['comUid'])
        .doc('cargoInfo')
        .collection(extractFour(cargo['id']))
        .doc(cargo['id'])
        .update(finalUpdateData);
  }

  if (cargo['normalUid'] != null) {
    await FirebaseFirestore.instance
        .collection('cargoInfo')
        .doc(cargo['uid'])
        .collection(extractFour(cargo['id']))
        .doc(cargo['id'])
        .update(finalUpdateData);
  }

  await _delMultiCargo(index, cargo);
}

Future _delMultiCargo(int index, Map<String, dynamic> cargo) async {
  if (cargo['pickUserUid'] == null) return;

  final docId = cargo['id'] + '_$index';
  print(docId);
  final docRef = FirebaseFirestore.instance
      .collection('user_driver_cargo')
      .doc(cargo['pickUserUid'])
      .collection('cargo_info')
      .doc(docId);

  final docSnapshot = await docRef.get();

  if (docSnapshot.exists) {
    await docRef.delete();
  }
}

Future doneMultiPhotoUpdate(String callType, int index, int count,
    Map<String, dynamic> cargo, File img, bool isReturn) async {
  User? _user = FirebaseAuth.instance.currentUser;
  String? downUrl = await uploadImage(
      img, 'cargo', cargo['id'], 'locationUrl${index}_${count}');
  String _name = 'locationUrl${index}_${count}';
  Map<String, dynamic> updateData = {
    _name: [downUrl, _user!.uid],
  };
  Map<String, dynamic> updatedLocation =
      Map.from(cargo['locations'][index]); // 현재 데이터 복사
  updatedLocation['isDone'] = true;
  updatedLocation['isDoneDate'] = DateTime.now();

  List _all = cargo['locations'];

  String msg = _all.length == index + 1
      ? isReturn
          ? '하차완료'
          : '운송완료'
      : isReturn
          ? index == 0
              ? '상차완료'
              : index == 1
                  ? '회차완료'
                  : '하차완료'
          : '${index + 1}번 ${cargo['locations'][index]['type']}완료';
  await FirebaseFirestore.instance
      .collection('user_driver_cargo')
      .doc(cargo['pickUserUid'])
      .collection('history')
      .doc(cargo['id'])
      .update({'state': msg, 'updatedAt': DateTime.now()});

  await FirebaseFirestore.instance
      .collection('user_driver')
      .doc(cargo['pickUserUid'])
      .collection('upDownHistory')
      .doc('photo')
      .set({
    'historyPhoto': FieldValue.arrayUnion([
      {
        'cargoId': cargo['id'],
        'timestamp': DateTime.now(),
        'callType': callType,
        'status': false,
        'url': downUrl,
      }
    ])
  }, SetOptions(merge: true));
  // 전체 locations 배열 복사
  List<dynamic> updatedLocations = List.from(cargo['locations']);
// 특정 인덱스만 업데이트
  updatedLocations[index] = updatedLocation;

// 두 업데이트를 하나로 합치기
  Map<String, dynamic> finalUpdateData = {
    _name: [downUrl, _user!.uid],
    'locations': updatedLocations, // locations 전체 배열 업데이트
    'cargoStat': msg, 'updatedAt': DateTime.now(),
  };
  if (cargo['normalUid'] != null) {
    await FirebaseFirestore.instance
        .collection('cargoInfo')
        .doc(cargo['uid'])
        .collection(extractFour(cargo['id']))
        .doc(cargo['id'])
        .update(finalUpdateData);
  }

  if (cargo['comUid'] != null) {
    await FirebaseFirestore.instanceFor(
            app: FirebaseFirestore.instance.app, databaseId: 'mixcallcompany')
        .collection(cargo['comUid'])
        .doc('cargoInfo')
        .collection(extractFour(cargo['id']))
        .doc(cargo['id'])
        .update(finalUpdateData);

    await FirebaseFirestore.instanceFor(
            app: FirebaseFirestore.instance.app, databaseId: 'mixcallcompany')
        .collection(cargo['comUid'])
        .doc('history')
        .set({
      'historyPhoto': FieldValue.arrayUnion([
        {
          'cargoId': cargo['id'],
          'timestamp': DateTime.now(),
          'callType': callType,
          'status': false,
          'url': downUrl,
        }
      ])
    }, SetOptions(merge: true));
  }

  await _delMultiCargo(index, cargo);
}
