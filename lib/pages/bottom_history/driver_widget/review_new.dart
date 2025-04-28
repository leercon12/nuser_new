import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class BottomInfoNewReview extends StatefulWidget {
  final Map<String, dynamic> userData;
  final bool isReview;
  final List photo;
  final List review;
  final Map<String, dynamic> cargo;
  final String callType;
  const BottomInfoNewReview(
      {super.key,
      required this.userData,
      required this.isReview,
      required this.cargo,
      required this.review,
      required this.photo,
      required this.callType});

  @override
  State<BottomInfoNewReview> createState() => _BottomInfoNewReviewState();
}

class _BottomInfoNewReviewState extends State<BottomInfoNewReview> {
  bool _isOpen = false;

  List _review = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _review = widget.review;
    setState(() {});
    _processPhotoList();
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    return _isOpen == true
        ? _reviewOpen()
        : Column(
            children: [
              _review.isEmpty
                  ? Expanded(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info,
                          size: 60,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        const SizedBox(height: 8),
                        KTextWidget(
                            text: '표시할 수 있는 리뷰가 없습니다.',
                            size: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.withOpacity(0.5))
                      ],
                    ))
                  : Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: ListView.builder(
                          itemCount: _review.length,
                          itemBuilder: (context, index) {
                            final review = widget.review[index];
                            return _reviewCard(review);
                          },
                        ),
                      ),
                    ),
              const SizedBox(height: 10),
              if (widget.isReview == true)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (widget.cargo == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          errorSnackBar('실제로 운송한 유저만 리뷰를 남길 수 있어요.', context));
                    } else {
                      if (widget.cargo!['uid'] == dataProvider.userData!.uid) {
                        print('123');
                        setState(() {
                          _isOpen = true;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            errorSnackBar(
                                '실제로 운송한 유저만 리뷰를 남길 수 있어요.', context));
                      }
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    height: 52,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: noState),
                    child: const Center(
                      child: KTextWidget(
                          text: '운송 후기 남기기',
                          size: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  ),
                ),
            ],
          );
  }

  double _rating = 0; // 별점을 저장할 변수
  final _reviewController = TextEditingController(); // 리뷰 텍스트 컨트롤러

  List<String> cargoIds = [];
  Map<String, List<String>> cargoPhotos = {};
  List<String> photoUrl = []; // String 타입으로 명시

  void _processPhotoList() {
    String currentCargoId = widget.cargo['id'];

    for (var photo in widget.photo) {
      if (photo['cargoId'].toString() == currentCargoId) {
        String cargoId = photo['cargoId'].toString();
        String url = photo['url'];

        // cargoIds와 cargoPhotos 처리
        if (!cargoIds.contains(cargoId)) {
          cargoIds.add(cargoId);
        }
        if (!cargoPhotos.containsKey(cargoId)) {
          cargoPhotos[cargoId] = [];
        }
        cargoPhotos[cargoId]!.add(url);

        // photoUrl에 url 추가
        photoUrl.add(url);
      }
    }

    setState(() {});
  }

  Widget _reviewOpen() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _rating = index + 1;
                  });
                },
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 40,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: noState,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _reviewController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '기사님께 리뷰를 남겨주세요.',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...cargoIds
              .map((cargoId) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withOpacity(0.1),
                            ],
                            stops: const [0.0, 0.9, 1.0],
                          ),
                        ),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: cargoPhotos[cargoId]?.length ??
                              0, // cargoPhotos 맵 사용
                          itemBuilder: (context, index) {
                            return Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      cargoPhotos[cargoId]![
                                          index], // cargoPhotos 맵에서 URL 가져오기
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ))
              .toList(),
          const Spacer(),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (_rating == 0 || _reviewController.text.length <= 5) {
                ScaffoldMessenger.of(context).showSnackBar(
                    errorSnackBar('별점 및 후기를 5자 이상 입력하세요.', context));
              } else {
                if (widget.callType == '기사') {
                  final docRef = FirebaseFirestore.instance
                      .collection('user_driver')
                      .doc(widget.cargo['pickUserUid'])
                      .collection('upDownHistory')
                      .doc('review');

                  docRef.set({
                    'reviews': FieldValue.arrayUnion([
                      {
                        'rating': _rating,
                        'content': _reviewController.text.trim(),
                        'photos':
                            photoUrl, // Map<String, List<String>> 형태의 사진 데이터
                        'createdAt': DateTime.now(),
                        'cargoId': widget.cargo['id'], // 해당 cargo의 ID도 저장
                      }
                    ])
                  }, SetOptions(merge: true));
                  _isOpen = false;
                  setState(() {});
                } else {
                  final docRef = FirebaseFirestore.instance
                      .collection('cargoComInfo')
                      .doc(widget.cargo['comUid'])
                      .collection('upDownHistory')
                      .doc('review');

                  docRef.set({
                    'reviews': FieldValue.arrayUnion([
                      {
                        'rating': _rating,
                        'content': _reviewController.text.trim(),
                        'photos':
                            photoUrl, // Map<String, List<String>> 형태의 사진 데이터
                        'createdAt': DateTime.now(),
                        'cargoId': widget.cargo['id'], // 해당 cargo의 ID도 저장
                      }
                    ])
                  }, SetOptions(merge: true));
                  _isOpen = false;
                  setState(() {});
                }
              }
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 52,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), color: noState),
              child: const Center(
                child: KTextWidget(
                    text: '운송 후기 남기기',
                    size: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _set = 0;
  Widget _reviewCard(Map<String, dynamic> review) {
    _set = review['rating'].toInt();
    double averageRating = calculateAverageRating(widget.review);
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Icon(
                    index < _set ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  );
                }),
              ),
              const SizedBox(width: 5),
              KTextWidget(
                  text: averageRating.toString(),
                  size: 17,
                  fontWeight: FontWeight.bold,
                  color: kOrangeBssetColor),
              const Spacer(),
              KTextWidget(
                  text: agoKorTimestamp(review['createdAt']),
                  size: 14,
                  fontWeight: null,
                  color: Colors.grey)
            ],
          ),
          const SizedBox(height: 12),
          KTextWidget(
              text: review['content'],
              size: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white),
          const SizedBox(height: 12),
          // 고정 높이의 SizedBox로 ListView 감싸기
          SizedBox(
            height: 50, // 적절한 높이 설정
            child: ListView.builder(
                scrollDirection: Axis.horizontal, // 가로 스크롤로 변경
                itemCount: photoUrl.length,
                itemBuilder: (context, index) {
                  final rev = photoUrl[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 8), // 사진 간 간격
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: noState,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        rev.toString(),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.error),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }

  double calculateAverageRating(List reviews) {
    if (reviews.isEmpty) return 0.0;

    double totalRating = 0;
    for (Map<String, dynamic> review in reviews) {
      totalRating += review['rating'];
    }

    // 소수점 첫째 자리까지 표시하고 문자열을 다시 double로 변환
    return double.parse((totalRating / reviews.length).toStringAsFixed(1));
  }
}
