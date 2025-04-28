import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class RemoteConfigService {
  static RemoteConfigService? _instance;
  final FirebaseRemoteConfig _remoteConfig;
  final BuildContext context;

  RemoteConfigService._(this._remoteConfig, this.context);

  static Future<RemoteConfigService> getInstance(BuildContext context) async {
    if (_instance == null) {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await _initializeRemoteConfig(remoteConfig);
      _instance = RemoteConfigService._(remoteConfig, context);
    }
    return _instance!;
  }

  static Future<void> _initializeRemoteConfig(
      FirebaseRemoteConfig remoteConfig) async {
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    await remoteConfig.setDefaults(const {
      'normalStop': false,
      'normalAnd': '',
      'normalIos': '',
    });
  }

  Future<void> fetchAndActivate() async {
    await _remoteConfig.fetchAndActivate();

    // Remote Config 값들을 MapProvider로 전달
    final mapProvider = Provider.of<MapProvider>(context, listen: false);

    // Remote Config에서 값 가져오기
    final normalStop = _remoteConfig.getBool('normalStop');
    final normalAnd = _remoteConfig.getString('normalAnd');
    final normalIos = _remoteConfig.getString('normalIos');

    // MapProvider에 값 설정
    mapProvider.updateRemoteConfig(
      normalStop: normalStop,
      normalAnd: normalAnd,
      normalIos: normalIos,
    );
  }

  String getString(String key) => _remoteConfig.getString(key);
  bool getBool(String key) => _remoteConfig.getBool(key);
  int getInt(String key) => _remoteConfig.getInt(key);
  double getDouble(String key) => _remoteConfig.getDouble(key);
}

void checkVersion() async {
  String version = await getCurrentVersion();
  print(version);
}

Future<String> getCurrentVersion() async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version; // 예: "1.0.0"
}
