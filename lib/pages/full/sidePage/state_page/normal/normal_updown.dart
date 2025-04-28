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

class NormalUpDownState extends StatefulWidget {
  final Map<String, dynamic> cargo;
  const NormalUpDownState({super.key, required this.cargo});

  @override
  State<NormalUpDownState> createState() => _NormalUpDownStateState();
}

class _NormalUpDownStateState extends State<NormalUpDownState> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _upInfoState(),
        if (widget.cargo['upDoneTime'] != null) _downInfoState(),
      ],
    );
  }

  Widget _upInfoState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            KTextWidget(
                text: widget.cargo['upDoneTime'] == null ? '상차 보고' : '상차 완료',
                size: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey),
            const Spacer(),
          ],
        ),
        if (widget.cargo['upDoneTime'] == null)
          const KTextWidget(
              text: '사진을 등록하면 모든 관련자가 확인할 수 있어요.',
              size: 12,
              fontWeight: null,
              color: Colors.grey),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            color: msgBackColor,
          ),
          child: Row(
            children: [
              _imgBox('상차', 0),
              _imgBox('상차', 1),
              _imgBox('상차', 2),
            ],
          ),
        ),
        _downState('상차'),
      ],
    );
  }

  Widget _downInfoState() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              KTextWidget(
                  text:
                      widget.cargo['downDoneTime'] == null ? '하차 보고' : '하차 완료',
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
              const Spacer(),
            ],
          ),
          if (widget.cargo['downDoneTime'] == null)
            const KTextWidget(
                text: '사진을 등록하면 모든 관련자가 확인할 수 있어요.',
                size: 12,
                fontWeight: null,
                color: Colors.grey),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              color: msgBackColor,
            ),
            child: Row(
              children: [
                _imgBox('하차', 0),
                _imgBox('하차', 1),
                _imgBox('하차', 2),
              ],
            ),
          ),
          _downState('하차'),
        ],
      ),
    );
  }

  Widget _downState(String callType) {
    bool isT = callType == '상차'
        ? widget.cargo['upDoneTime'] != null
        : widget.cargo['downDoneTime'] != null;
    return GestureDetector(
      onTap: () {
        print(widget.cargo['id']);
      },
      child: Container(
        margin: const EdgeInsets.only(top: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          color: isT == true
              ? callType == '상차'
                  ? kBlueBssetColor.withOpacity(0.2)
                  : kRedColor.withOpacity(0.2)
              : msgBackColor,
        ),
        child: isT == true
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (callType == '상차')
                    KTextWidget(
                        text:
                            '상차 완료 ${formatDateTime(widget.cargo['upDoneTime'].toDate())}',
                        size: 14,
                        fontWeight: FontWeight.bold,
                        color: kBlueBssetColor)
                  else
                    KTextWidget(
                        text:
                            '하차 완료 ${formatDateTime(widget.cargo['downDoneTime'].toDate())}',
                        size: 14,
                        fontWeight: FontWeight.bold,
                        color: kRedColor)
                ],
              )
            : GestureDetector(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  if (callType == '상차') {
                    await stateUpdateNoImg('상차');
                  } else {
                    await stateUpdateNoImg('하차');
                  }
                },
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: callType == '상차' ? kBlueBssetColor : kRedColor),
                  child: Center(
                    child: KTextWidget(
                        text: callType == '상차' ? '상차 완료' : '하차 완료',
                        size: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _imgBox(
    String callType,
    int count,
  ) {
    final addProvider = Provider.of<AddProvider>(context);
    final mapProvider = Provider.of<MapProvider>(context);
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        addProvider.cargoImageState(null);
        if (callType == '상차'
            ? widget.cargo['upDonePhotoURl$count'] == null
            : widget.cargo['downDonePhotoURl$count'] == null) {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return PickImageBottom(
                callType: '상차보고',
                comUid: widget.cargo['comUid'].toString(),
                count: count,
              );
            },
          ).then((value) async {
            if (value == true) {
              if (addProvider.cargoImage != null) {
                mapProvider.isLoadingState(true);
                await donePhotoUpdate(callType, count, addProvider);
                mapProvider.isLoadingState(false);
              }
            }
          });
        } else {
          await showDialog(
            context: context,
            builder: (context) => ImageViewerDialog(
              networkUrl: callType == '상차'
                  ? widget.cargo['upDonePhotoURl$count'][0].toString()
                  : widget.cargo['downDonePhotoURl$count'][0].toString(),
              cargo: callType == '상차'
                  ? widget.cargo['upDonePhotoURl$count']
                  : widget.cargo['downDonePhotoURl$count'],
            ),
          ).then((value) async {
            if (value != null) {
              print(value);

              String name = callType == '상차'
                  ? 'upDonePhotoURl$count'
                  : 'downDonePhotoURl$count';
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
      child: callType == '상차'
          ? Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.only(right: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: noState,
              ),
              child: widget.cargo['upDonePhotoURl$count'] == null
                  ? const Center(
                      child: Icon(
                        Icons.add,
                        color: Colors.grey,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: widget.cargo['upDonePhotoURl$count'][0],
                        fit: BoxFit.cover, // 이미지를 컨테이너에 맞춰서 보여줍니다.
                      ),
                    ),
            )
          : Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.only(right: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: noState,
              ),
              child: widget.cargo['downDonePhotoURl$count'] == null
                  ? const Center(
                      child: Icon(
                        Icons.add,
                        color: Colors.grey,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: widget.cargo['downDonePhotoURl$count'][0],
                        fit: BoxFit.cover, // 이미지를 컨테이너에 맞춰서 보여줍니다.
                      ),
                    ),
            ),
    );
  }

  Future donePhotoUpdate(
      String callType, int count, AddProvider addProvider) async {
    User? _user = FirebaseAuth.instance.currentUser;
    String? downUrl = await uploadImage(
        addProvider.cargoImage!,
        'cargo',
        widget.cargo['id'],
        callType == '상차' ? 'upDonePhotoURl$count' : 'downDonePhotoURl$count');
    String _name =
        callType == '상차' ? 'upDonePhotoURl$count' : 'downDonePhotoURl$count';
    Map<String, dynamic> updateData = {
      _name: [downUrl, _user!.uid],
    };

    if (callType == '상차') {
      if (widget.cargo['cargoStat'] == null ||
          widget.cargo['cargoStat'] == '대기' ||
          widget.cargo['cargoStat'] == '배차') {
        updateData.addAll({'upDoneTime': DateTime.now(), 'cargoStat': '상차완료'});
        await FirebaseFirestore.instance
            .collection('user_driver_cargo')
            .doc(widget.cargo['pickUserUid'])
            .collection('history')
            .doc(widget.cargo['id'])
            .update({'state': '상차완료', 'updatedAt': DateTime.now()});
      }
    } else {
      if (widget.cargo['cargoStat'] == '상차완료') {
        updateData
            .addAll({'downDoneTime': DateTime.now(), 'cargoStat': '하차완료'});
        await FirebaseFirestore.instance
            .collection('user_driver_cargo')
            .doc(widget.cargo['pickUserUid'])
            .collection('history')
            .doc(widget.cargo['id'])
            .update({'state': '하차완료', 'updatedAt': DateTime.now()});
      }
    }
    if (widget.cargo['comUid'] == null) {
      await FirebaseFirestore.instance
          .collection('cargoInfo')
          .doc(widget.cargo['uid'])
          .collection(extractFour(widget.cargo['id']))
          .doc(widget.cargo['id'])
          .update(updateData);
      print(updateData);

      await FirebaseFirestore.instance
          .collection('user_driver')
          .doc(widget.cargo['pickUserUid'])
          .collection('upDownHistory')
          .doc('photo')
          .set({
        'historyPhoto': FieldValue.arrayUnion([
          {
            'cargoId': widget.cargo['id'],
            'timestamp': DateTime.now(),
            'callType': callType,
            'status': false,
            'url': downUrl,
          }
        ])
      }, SetOptions(merge: true));
    } else {
      await FirebaseFirestore.instance
          .collection('cargoInfo')
          .doc(widget.cargo['uid'])
          .collection(extractFour(widget.cargo['id']))
          .doc(widget.cargo['id'])
          .update(updateData);
      ;
      await FirebaseFirestore.instanceFor(
              app: FirebaseFirestore.instance.app, databaseId: 'mixcallcompany')
          .collection(widget.cargo['comUid'])
          .doc('cargoInfo')
          .collection(extractFour(widget.cargo['id']))
          .doc(widget.cargo['id'])
          .update(updateData);

      await FirebaseFirestore.instance
          .collection('user_driver')
          .doc(widget.cargo['pickUserUid'])
          .collection('upDownHistory')
          .doc('photo')
          .set({
        'historyPhoto': FieldValue.arrayUnion([
          {
            'cargoId': widget.cargo['id'],
            'timestamp': DateTime.now(),
            'callType': callType,
            'status': false,
            'url': downUrl,
          }
        ])
      }, SetOptions(merge: true));

      await FirebaseFirestore.instanceFor(
              app: FirebaseFirestore.instance.app, databaseId: 'mixcallcompany')
          .collection(widget.cargo['comUid'])
          .doc('history')
          .set({
        'historyPhoto': FieldValue.arrayUnion([
          {
            'cargoId': widget.cargo['id'],
            'timestamp': DateTime.now(),
            'callType': callType,
            'status': false,
            'url': downUrl,
          }
        ])
      }, SetOptions(merge: true));
    }
    await _delCargo(callType, widget.cargo);
    addProvider.cargoImageState(null);
  }

  Future stateUpdateNoImg(String callType) async {
    print('@@@@@');
    print(widget.cargo['id']);
    try {
      if (callType == '상차') {
        if (widget.cargo['cargoStat'] == null ||
            widget.cargo['cargoStat'] == '대기' ||
            widget.cargo['cargoStat'] == '배차') {
          await FirebaseFirestore.instance
              .collection('user_driver_cargo')
              .doc(widget.cargo['pickUserUid'])
              .collection('history')
              .doc(widget.cargo['id'])
              .update({'state': '상차완료', 'updatedAt': DateTime.now()});
          if (widget.cargo['comUid'] == null) {
            await FirebaseFirestore.instance
                .collection('cargoInfo')
                .doc(widget.cargo['uid'])
                .collection(extractFour(widget.cargo['id']))
                .doc(widget.cargo['id'])
                .update({'cargoStat': '상차완료', 'upDoneTime': DateTime.now()});
          } else {
            await FirebaseFirestore.instance
                .collection('cargoInfo')
                .doc(widget.cargo['uid'])
                .collection(extractFour(widget.cargo['id']))
                .doc(widget.cargo['id'])
                .update({'cargoStat': '상차완료', 'upDoneTime': DateTime.now()});
            await FirebaseFirestore.instanceFor(
                    app: FirebaseFirestore.instance.app,
                    databaseId: 'mixcallcompany')
                .collection(widget.cargo['comUid'])
                .doc('cargoInfo')
                .collection(extractFour(widget.cargo['id']))
                .doc(widget.cargo['id'])
                .update({'cargoStat': '상차완료', 'upDoneTime': DateTime.now()});
          }
        }
      } else {
        if (widget.cargo['cargoStat'] == '상차완료') {
          await FirebaseFirestore.instance
              .collection('user_driver_cargo')
              .doc(widget.cargo['pickUserUid'])
              .collection('history')
              .doc(widget.cargo['id'])
              .update({'state': '하차완료', 'updatedAt': DateTime.now()});
          if (widget.cargo['comUid'] == null) {
            await FirebaseFirestore.instance
                .collection('cargoInfo')
                .doc(widget.cargo['uid'])
                .collection(extractFour(widget.cargo['id']))
                .doc(widget.cargo['id'])
                .update({'cargoStat': '하차완료', 'downDoneTime': DateTime.now()});
          } else {
            await FirebaseFirestore.instance
                .collection('cargoInfo')
                .doc(widget.cargo['uid'])
                .collection(extractFour(widget.cargo['id']))
                .doc(widget.cargo['id'])
                .update({'cargoStat': '하차완료', 'downDoneTime': DateTime.now()});

            await FirebaseFirestore.instanceFor(
                    app: FirebaseFirestore.instance.app,
                    databaseId: 'mixcallcompany')
                .collection(widget.cargo['comUid'])
                .doc('cargoInfo')
                .collection(extractFour(widget.cargo['id']))
                .doc(widget.cargo['id'])
                .update({'cargoStat': '하차완료', 'downDoneTime': DateTime.now()});
          }
        }
      }
      await _delCargo(callType, widget.cargo);
    } catch (e) {
      print(e);
    }
  }

  Future _delCargo(String callType, Map<String, dynamic> cargo) async {
    if (cargo['pickUserUid'] == null) return;

    final docId =
        callType.contains('상차') ? cargo['id'] + 'up' : cargo['id'] + 'down';

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
}
