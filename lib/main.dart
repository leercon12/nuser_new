import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/env.dart';
import 'package:flutter_mixcall_normaluser_new/fold_state.dart';
import 'package:flutter_mixcall_normaluser_new/pages/homePage.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/hashProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/weatherProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart'; // 이 줄 추가

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize Firebase App Check
      await FirebaseAppCheck.instance.activate(
        // Use Play Integrity for Android
        androidProvider: AndroidProvider.playIntegrity,
        // You can also provide AppleProvider.appAttest for iOS
        // appleProvider: AppleProvider.appAttest,
      );
      print('Firebase App Check activated successfully.');
    } catch (e) {
      print('Error during Firebase initialization or App Check activation: $e');
      if (e is FirebaseException && e.code == 'duplicate-app') {
        // 이미 초기화되어 있으므로 기존 앱 인스턴스 사용
        Firebase.app();
      } else {
        // 다른 예외는 다시 던지기
        // Consider handling App Check activation errors specifically if needed
        rethrow;
      }
    }

    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
    );

    String apiKey = Env.NAVER_MAP_KEY;

    await FlutterNaverMap().init(
        clientId: apiKey,
        onAuthFailed: (ex) => switch (ex) {
              NQuotaExceededException(:final message) =>
                print("사용량 초과 (message: $message)"),
              NUnauthorizedClientException() ||
              NClientUnspecifiedException() ||
              NAnotherAuthFailedException() =>
                print("인증 실패: $ex"),
            });
    /*  await NaverMapSdk.instance.initialize(
        clientId: apiKey,
        onAuthFailed: (ex) {
          print("********* 네이버맵 인증오류 : $ex *********");
          print(ex);
        });
 */
    await _init();
    runApp(MyApp());
  }, (error, stack) {
    print('Caught error: $error');
    print('Stack trace: $stack');
  });
}

Future<void> _init() async {
  ThemeMode? themeMode;
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final prefs = await SharedPreferences.getInstance();
  final String? savedThemeMode = prefs.getString('themeMode');

  if (savedThemeMode == null) {
    themeMode = ThemeMode.light;
  } else if (savedThemeMode == "light") {
    themeMode = ThemeMode.light;
  } else if (savedThemeMode == "dark") {
    themeMode = ThemeMode.dark;
  } else if (savedThemeMode == "system") {
    themeMode = ThemeMode.system;
  }
  //fcmSetting();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Hive.initFlutter();

  Hive.registerAdapter(TimestampAdapter());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MapProvider()),
        ChangeNotifierProvider(create: (_) => AddProvider()),
        ChangeNotifierProvider(create: (_) => HashProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: Builder(
        builder: (context) {
          return Platform.isAndroid
              ? FoldableWrapper(
                  // 추가된 부분
                  child: MaterialApp(
                    debugShowMaterialGrid: false,
                    builder: (context, child) {
                      return MediaQuery(
                          data: MediaQuery.of(context)
                              .copyWith(textScaleFactor: 1.0),
                          child: child!);
                    },
                    debugShowCheckedModeBanner: false,
                    theme: MyThemes.lightTheme,
                    darkTheme: MyThemes.darkTheme,
                    themeMode: Provider.of<ThemeProvider>(context).themeMode,
                    home: const HomePage(),
                  ),
                )
              : MaterialApp(
                  debugShowMaterialGrid: false,
                  builder: (context, child) {
                    return MediaQuery(
                        data: MediaQuery.of(context)
                            .copyWith(textScaleFactor: 1.0),
                        child: child!);
                  },
                  debugShowCheckedModeBanner: false,
                  theme: MyThemes.lightTheme,
                  darkTheme: MyThemes.darkTheme,
                  themeMode: Provider.of<ThemeProvider>(context).themeMode,
                  home: const HomePage(),
                );
        },
      ),
    );
  }
}

class TimestampAdapter extends TypeAdapter<Timestamp> {
  @override
  final int typeId = 0; // 사용자 정의 타입 ID (유일한 값이어야 함)

  @override
  Timestamp read(BinaryReader reader) {
    // BinaryReader에서 데이터를 읽고 Timestamp 객체로 변환하여 반환
    final seconds = reader.readInt();
    final nanoseconds = reader.readInt();
    return Timestamp(seconds, nanoseconds);
  }

  @override
  void write(BinaryWriter writer, Timestamp obj) {
    // Timestamp 객체를 BinaryWriter에 쓰기
    writer.writeInt(obj.seconds);
    writer.writeInt(obj.nanoseconds);
  }
}


/* https://mixcall-members.co.kr/

Android 앱 패키지 이름	
com.ideadot.flutter_application_mixcall

com.ideadot.flutter_mixcall_normaluser

iOS Bundle ID	
com.example.flutterApplicationMixcall

com.example.flutterMixcallNormaluser */