import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/bottomSheet.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class PickImageBottom extends StatefulWidget {
  final String callType;
  final String? cargoId;
  final String? listId;
  final String? num;
  final String? upDowncall;
  final String comUid;
  final int? count;
  final Map<String, dynamic>? cargoData;

  const PickImageBottom({
    super.key,
    required this.callType,
    required this.comUid,
    this.cargoId,
    this.listId,
    this.num,
    this.upDowncall,
    this.cargoData,
    this.count,
  });

  @override
  State<PickImageBottom> createState() => _PickImageBottomState();
}

class _PickImageBottomState extends State<PickImageBottom> {
  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;
    final addProvider = Provider.of<AddProvider>(context);
    return SingleChildScrollView(
      child: Container(
        width: dw,
        // height: 238,
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            color: dialogColor),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const BottomTobMarker(),
              const SizedBox(height: 35),
              GestureDetector(
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    addProvider.addLoadingState(true);

                    if (mounted) {
                      // 카메라 권한 체크
                      var status = await Permission.camera.status;

                      if (status.isDenied) {
                        // 권한 요청
                        status = await Permission.camera.request();
                        if (!status.isGranted) {
                          // 권한이 거부된 경우
                          Navigator.pop(context);
                          return;
                        }
                      }

                      // 기존 카메라 로직
                      if (widget.callType.contains('기업')) {
                        await addProvider.comAddImage(
                          source: ImageSource.camera,
                          callType: widget.callType,
                        );
                      } else {
                        await addProvider.captureAndCompressImage(
                          source: ImageSource.camera,
                          callType: widget.callType,
                        );
                      }
                    }

                    if (addProvider.cargoImage != null) {
                      Navigator.pop(context, true);
                    } else {
                      Navigator.pop(context);
                    }

                    addProvider.addLoadingState(false);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 8, right: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: noState,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.grey.withOpacity(0.2)),
                          child: const Center(
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            KTextWidget(
                                text: '스마트폰 카메라 촬영',
                                size: 16,
                                lineHeight: 1.2,
                                fontWeight: FontWeight.bold,
                                color: null),
                            KTextWidget(
                                text: '촬영하여 이미지를 등록합니다.',
                                size: 14,
                                fontWeight: null,
                                color: Colors.grey),
                          ],
                        )
                      ],
                    ),
                  )),
              const SizedBox(height: 10),
              GestureDetector(
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    addProvider.addLoadingState(true);

                    if (mounted) {
                      if (widget.callType.contains('기업')) {
                        await addProvider.comAddImage(
                          source: ImageSource.gallery,
                          callType: widget.callType,
                        );
                      } else {
                        await addProvider.captureAndCompressImage(
                          source: ImageSource.gallery,
                          callType: widget.callType,
                        );
                      }
                    }
                    if (addProvider.cargoImage != null) {
                      Navigator.pop(context, true);
                    } else {
                      Navigator.pop(context);
                    }
                    addProvider.addLoadingState(false);
                    //  mapProvider.isLoadingState(false);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(left: 8, right: 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: noState),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.grey.withOpacity(0.2)),
                          child: const Center(
                            child: Icon(
                              Icons.photo_library,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            KTextWidget(
                                text: '휴대폰 사진 갤러리',
                                size: 16,
                                lineHeight: 1.2,
                                fontWeight: FontWeight.bold,
                                color: null),
                            KTextWidget(
                                text: '저장된 이미지를 등록합니다.',
                                size: 14,
                                fontWeight: null,
                                color: Colors.grey),
                          ],
                        )
                      ],
                    ),
                  )),
              const SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String?> uploadImage(
    File imageFile, String coll, String coll2, String filename) async {
  try {
    // Firebase 초기화
    await Firebase.initializeApp();

    DateTime now = DateTime.now();

// Format the date and time as yyyy/mm/dd/hh/mm
    String formattedDate = DateFormat('yyyy-MM-dd-HH-mm').format(now);

    // Storage에 대한 참조 생성

    String uniqueId = filename.contains('upDone') == true ||
            filename.contains('downDone') == true
        ? '$filename'
        : '${filename}_${formattedDate}';
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("images/${coll}/${coll2}/${uniqueId}.jpg");

    // 이미지 업로드
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;

    // 업로드된 이미지의 URL 가져오기
    String downloadURL = await snapshot.ref.getDownloadURL();

    return downloadURL;
  } catch (e) {
    print("Error uploading image: $e");
    return null;
  }
}
