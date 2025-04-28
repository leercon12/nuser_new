import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/providers/weatherProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';

import 'package:provider/provider.dart';

class WeatherMainPage extends StatefulWidget {
  const WeatherMainPage({super.key});

  @override
  State<WeatherMainPage> createState() => _WeatherMainPageState();
}

class _WeatherMainPageState extends State<WeatherMainPage> {
  @override
  void initState() {
    super.initState();
    final weatherProvider =
        Provider.of<WeatherProvider>(context, listen: false);
    print('Chart2Page initState called');

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('PostFrameCallback called');
      if (weatherProvider.availableRegions.isEmpty) {
        print('날씨 데이터 초기화 시작...');
        await weatherProvider.initializeData();
        print('날씨 데이터 초기화 완료');
        print('사용 가능한 지역: ${weatherProvider.availableRegions}');
        if (mounted) setState(() {}); // UI 갱신
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final regions = weatherProvider.availableRegions;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const KTextWidget(
            text: '날씨 예보', size: 20, fontWeight: null, color: Colors.white),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            if (weatherProvider.isLoading == true)
              const Center(
                child: SizedBox(
                  width: 25,
                  height: 25,
                  child: CircularProgressIndicator(
                    color: Colors.grey,
                  ),
                ),
              )
            else if (regions.isEmpty)
              const Center(
                child: Text('날씨 데이터를 불러올 수 없습니다.'),
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: regions.length,
                  itemBuilder: (context, index) {
                    final region = regions[index];
                    final weather = weatherProvider.getRegionWeather(region);
                    final temperatures = weather != null
                        ? weatherProvider.getRegionDayTemperatures(
                            region, weather.date)
                        : {'max': 0, 'min': 0};

                    return InkWell(
                      onTap: () => showWeatherDetailDialog(
                          context, region, weatherProvider),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: msgBackColor,
                            borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                KTextWidget(
                                  text: region,
                                  size: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                const Spacer(),
                                KTextWidget(
                                  text: '${weather!.time.substring(0, 2)}시, ',
                                  size: 12,
                                  fontWeight: null,
                                  color: Colors.grey,
                                ),
                                KTextWidget(
                                  text: weather.getWeatherDescription(),
                                  size: 12,
                                  fontWeight: null,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                            const Spacer(),
                            if (weather != null) ...[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 70,
                                    child: Image.asset(
                                      weather.getWeatherImage(),
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        print('Error loading image: $error');
                                        return const Icon(Icons.cloud,
                                            size: 24);
                                      },
                                    ),
                                  ),
                                  const Spacer(),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const SizedBox(height: 8),
                                      KTextWidget(
                                        text: '${weather.temperature}°C',
                                        size: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          KTextWidget(
                                            text: '↓${temperatures['min']}°',
                                            size: 12,
                                            fontWeight: null,
                                            color: Colors.blue,
                                          ),
                                          const SizedBox(width: 8),
                                          KTextWidget(
                                            text: '↑${temperatures['max']}°',
                                            size: 12,
                                            fontWeight: null,
                                            color: Colors.red,
                                          ),
                                        ],
                                      ),
                                      KTextWidget(
                                        text: '강수 확률 ${weather.precipitation}%',
                                        size: 12,
                                        fontWeight: null,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              const Spacer(),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            /*   Expanded(
                child: ListView.builder(
                    itemCount: regions.length,
                    itemBuilder: (context, index) {
                      final region = regions[index];
                      final weather = weatherProvider.getRegionWeather(region);
                      final temperatures = weather != null
                          ? weatherProvider.getRegionDayTemperatures(
                              region, weather.date)
                          : {'max': 0, 'min': 0};
                      return GestureDetector(
                        onTap: () => showWeatherDetailDialog(
                            context, region, weatherProvider),
                        child: Container(
                          margin: EdgeInsets.only(top: 8, right: 8, left: 8),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: msgBackColor,
                              borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      KTextWidget(
                                        text: region,
                                        size: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      Row(
                                        children: [
                                          KTextWidget(
                                            text:
                                                '${weather!.time.substring(0, 2)}시, ',
                                            size: 12,
                                            fontWeight: null,
                                            color: Colors.grey,
                                          ),
                                          KTextWidget(
                                            text: weather.getWeatherDescription(),
                                            size: 12,
                                            fontWeight: null,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  SizedBox(
                                    width: 110,
                                    child: Image.asset(
                                      weather.getWeatherImage(),
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        print('Error loading image: $error');
                                        return const Icon(Icons.cloud, size: 24);
                                      },
                                    ),
                                  ),
                                  const Spacer(),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      KTextWidget(
                                        text: '${weather.temperature}°C',
                                        size: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          KTextWidget(
                                            text: '↓${temperatures['min']}°',
                                            size: 12,
                                            fontWeight: null,
                                            color: Colors.blue,
                                          ),
                                          const SizedBox(width: 8),
                                          KTextWidget(
                                            text: '↑${temperatures['max']}°',
                                            size: 12,
                                            fontWeight: null,
                                            color: Colors.red,
                                          ),
                                        ],
                                      ),
                                      KTextWidget(
                                        text: '강수 확률 ${weather.precipitation}%',
                                        size: 12,
                                        fontWeight: null,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              ) */
          ],
        ),
      )),
    );
  }

  void showWeatherDetailDialog(
      BuildContext context, String region, WeatherProvider weatherProvider) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) {
        final threeDaysForecast = weatherProvider.getThreeDaysForecast(region);

        return DefaultTabController(
          length: threeDaysForecast.length,
          child: Dialog(
            insetPadding: EdgeInsets.symmetric(
              horizontal: 12, // 화면 너비의 10%만 여백으로
              vertical: 12, // 화면 높이의 5%만 여백으로
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              //  width: 500,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: msgBackColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 헤더
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.cancel,
                          color: Colors.grey,
                        ),
                      )
                    ],
                  ),
                  // 탭바
                  TabBar(
                    dividerColor: msgBackColor,
                    labelColor: kGreenFontColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.transparent,
                    indicator: const BoxDecoration(),
                    labelStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                    tabs: threeDaysForecast.keys.map((date) {
                      String label = date == threeDaysForecast.keys.first
                          ? "오늘"
                          : date == threeDaysForecast.keys.elementAt(1)
                              ? "내일"
                              : "모레";
                      return Tab(text: '${_formatDate(date)} ($label)');
                    }).toList(),
                  ),
                  // 탭 컨텐츠
                  Expanded(
                    child: TabBarView(
                      children: threeDaysForecast.entries.map((entry) {
                        final date = entry.key;
                        final forecasts = entry.value;

                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              // 현재 날씨 요약
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      forecasts.first.getWeatherImage(),
                                      width: 120,
                                    ),
                                    const SizedBox(width: 24),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${forecasts.first.temperature}°C',
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              region,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              forecasts.first
                                                  .getWeatherDescription(),
                                              style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.water_drop,
                                                color: Colors.blue, size: 20),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${forecasts.first.precipitation}%',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // 시간별 날씨 목록
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: forecasts.length,
                                separatorBuilder: (context, index) => Divider(
                                  height: 1,
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                                itemBuilder: (context, index) {
                                  final forecast = forecasts[index];
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 24,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // 시간
                                        SizedBox(
                                          width: 80,
                                          child: Text(
                                            '${forecast.time.substring(0, 2)}:${forecast.time.substring(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        // 날씨 아이콘
                                        Image.asset(
                                          forecast.getWeatherImage(),
                                          width: 40,
                                          height: 40,
                                        ),
                                        // 온도
                                        SizedBox(
                                          width: 80,
                                          child: Text(
                                            '${forecast.temperature}°C',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        // 강수확률
                                        SizedBox(
                                          width: 80,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              const Icon(
                                                Icons.water_drop,
                                                size: 16,
                                                color: Colors.blue,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${forecast.precipitation}%',
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(String yyyymmdd) {
    if (yyyymmdd.length != 8) return '';

    final year = yyyymmdd.substring(2, 4); // yy
    final month = yyyymmdd.substring(4, 6); // mm
    final day = yyyymmdd.substring(6, 8); // dd

    return '$year.$month.$day';
  }
}
