import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_widget/delayed_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/login_join/pw_reset/reset.dart';
import 'package:flutter_mixcall_normaluser_new/pages/login_join/pw_reset/verif.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/loading_page.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class PwResetMainPage extends StatefulWidget {
  const PwResetMainPage({super.key});

  @override
  State<PwResetMainPage> createState() => _PwResetMainPageState();
}

class _PwResetMainPageState extends State<PwResetMainPage> {
  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: KTextWidget(
                text: '비밀번호 재설정',
                size: 20,
                fontWeight: null,
                color: Colors.white),
          ),
          body: SafeArea(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                if (mapProvider.isResetVerif == false)
                  Expanded(child: PhoneVerif())
                else
                  Expanded(child: ReSetPart()),
              ],
            ),
          )),
        ),
        if (mapProvider.isLoading == true) Positioned.fill(child: LoadingPage())
      ],
    );
  }
}
