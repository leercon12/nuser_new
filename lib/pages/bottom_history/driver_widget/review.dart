import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class BottomReview extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final bool isReview;
  final List photo;
  final List review;
  final Map<String, dynamic>? cargo;
  const BottomReview(
      {super.key,
      required this.userData,
      required this.isReview,
      this.cargo,
      required this.review,
      required this.photo});

  @override
  State<BottomReview> createState() => _BottomReviewState();
}

class _BottomReviewState extends State<BottomReview> {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    _loadInitialReviews();
    _scrollController.addListener(_onScroll);
    _processPhotoList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialReviews() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('user_driver')
          .doc(widget.userData!['uid'])
          .collection('reviews')
          .orderBy('update', descending: true)
          .limit(5)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _reviews.addAll(querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>));
        _lastDocument = querySnapshot.docs.last;
      }

      setState(() {
        _hasMore = querySnapshot.docs.length == 5;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading reviews: $e');
    }
  }

  Future<void> _loadMoreReviews() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('user_driver')
          .doc(widget.userData!['uid'])
          .collection('reviews')
          .orderBy('update', descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(10)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _reviews.addAll(querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>));
        _lastDocument = querySnapshot.docs.last;
      }

      setState(() {
        _hasMore = querySnapshot.docs.length == 10;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading more reviews: $e');
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreReviews();
    }
  }

  List<String> cargoIds = []; // cargoId 리스트
  Map<String, List<String>> cargoPhotos = {}; // cargoId별 사진 URL 리스트

  void _processPhotoList() {
    // photo 리스트에서 cargoId별로 사진을 그룹화
    for (var photo in widget.photo) {
      String cargoId = photo['cargoId'];
      if (!cargoIds.contains(cargoId)) {
        cargoIds.add(cargoId);
      }

      if (!cargoPhotos.containsKey(cargoId)) {
        cargoPhotos[cargoId] = [];
      }
      cargoPhotos[cargoId]!.add(photo['url']);
    }
  }

  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    return _isOpen == true
        ? _reviewOpen()
        : Column(
            children: [
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
                          errorSnackBar('실제로 운송한 유저만 리뷰를 남길 수 있어요.', context));
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
              _reviews.isEmpty
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
                          controller: _scrollController,
                          itemCount: _reviews.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _reviews.length) {
                              return _hasMore
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : const SizedBox();
                            }

                            final review = _reviews[index];
                            return _reviewCard(review);
                          },
                        ),
                      ),
                    ),
            ],
          );
  }

  Widget _reviewCard(Map<String, dynamic> review) {
    return Container();
  }

  double _rating = 0; // 별점을 저장할 변수
  final _reviewController = TextEditingController(); // 리뷰 텍스트 컨트롤러

  Widget _reviewOpen() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 16),

                // 별점 위젯
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      // GestureDetector 대신 IconButton 사용
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        setState(() {
                          _rating = index + 1;
                          print(_rating);
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
                // 리뷰 텍스트 입력 필드
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
                              height: 60,
                              decoration: BoxDecoration(
                                // 스크롤 가능함을 나타내는 그라데이션 효과
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
                                physics:
                                    const BouncingScrollPhysics(), // 스크롤 효과 추가
                                itemCount: cargoPhotos[cargoId]?.length ?? 0,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        cargoPhotos[cargoId]![index],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ))
                    .toList(),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              HapticFeedback.lightImpact();
              if (_rating == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('별점을 선택해주세요')),
                );
                return;
              }
              if (_reviewController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('리뷰 내용을 입력해주세요')),
                );
                return;
              }

              /*   // 리뷰 데이터 저장
           await FirebaseFirestore.instance
               .collection('user_driver')
               .doc(widget.userData!['uid'])
               .collection('reviews')
               .add({
                 'rating': _rating,
                 'content': _reviewController.text,
                 'timestamp': Timestamp.now(),
                 'userId': FirebaseAuth.instance.currentUser?.uid,
                 'userName': // 현재 사용자 이름,
               }); */

              setState(() {
                _isOpen = false;
              });
            },
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: kGreenFontColor,
              ),
              child: const Center(
                child: KTextWidget(
                  text: '운송 후기 등록',
                  size: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isOpen = false;
              });
            },
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: noState,
              ),
              child: const Center(
                child: KTextWidget(
                  text: '돌아가기',
                  size: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reivewForm() {
    return Column(
      children: [],
    );
  }
}
