import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:io' show Platform;

import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';

class FoldableWrapper extends StatefulWidget {
  final Widget child;

  const FoldableWrapper({
    required this.child,
    super.key,
  });

  @override
  State<FoldableWrapper> createState() => _FoldableWrapperState();
}

class _FoldableWrapperState extends State<FoldableWrapper> {
  String _deviceState = 'checking...';

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _checkFoldState();
      _setupFoldStateListener();
    } else {
      setState(() {
        _deviceState = 'NOT_SUPPORTED';
      });
    }
  }

  Future<void> _checkFoldState() async {
    if (!Platform.isAndroid) {
      setState(() {
        _deviceState = 'NOT_SUPPORTED';
      });
      return;
    }

    try {
      final state = await const MethodChannel('fold_state_channel')
          .invokeMethod<String>('checkFoldState');
      setState(() {
        _deviceState = state ?? 'NOT_SUPPORTED';
      });
    } catch (e) {
      print('Error checking fold state: $e');
      setState(() {
        _deviceState = 'NOT_SUPPORTED';
      });
    }
  }

  void _setupFoldStateListener() {
    if (!Platform.isAndroid) return;

    const MethodChannel('fold_state_channel')
        .setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onFoldStateChanged') {
        setState(() {
          _deviceState = call.arguments as String;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_deviceState) {
      case 'FOLDED':
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            body: Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.open_in_full,
                        size: 48, color: kOrangeBssetColor),
                    SizedBox(height: 16),
                    Text(
                      '화면을 펼쳐주세요',
                      style: TextStyle(
                        color: kOrangeBssetColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

      case 'UNFOLDED':
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            body: Center(
              child: Container(
                width: MediaQuery.of(context).size.width <= 800
                    ? MediaQuery.of(context).size.width
                    : MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 1,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: widget.child,
                ),
              ),
            ),
          ),
        );

      default: // NOT_SUPPORTED 또는 checking... 상태
        return widget.child;
    }
  }
}
