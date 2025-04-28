import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_mixcall_normaluser_new/pages/login_join/login_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/splash.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    Platform.isIOS
        ? SystemChrome.setSystemUIOverlayStyle(
            Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark)
        : SystemChrome.setSystemUIOverlayStyle(
            Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
                ? const SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.light,
                    //statusBarBrightness: Brightness.light,
                    systemNavigationBarColor: kDarkBackground2,
                    systemNavigationBarIconBrightness: Brightness.light)
                : const SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.dark,
                    //statusBarBrightness: Brightness.dark,
                    systemNavigationBarColor: Colors.white,
                    systemNavigationBarIconBrightness: Brightness.dark));

    return user == null ? const LoginMainPage() : const SplashPage();
  }
}
