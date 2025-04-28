import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CountdownTimer extends StatefulWidget {
  final Timestamp? timestamp;
  final double? size;
  final Color? color;
  const CountdownTimer({Key? key, this.timestamp, this.size, this.color})
      : super(key: key);

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? _timer;

  int _secondsRemaining = 180; // 3분 = 180초

  @override
  void initState() {
    super.initState();
    _initializeTimer();
  }

  void _initializeTimer() {
    if (widget.timestamp != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final timestampMs = widget.timestamp!.toDate().millisecondsSinceEpoch;
      final difference = (now - timestampMs) ~/ 1000; // 초 단위로 변환

      if (difference > 180) {
        _secondsRemaining = 0;
      } else if (difference > 0) {
        _secondsRemaining = 180 - difference;
      }
    }
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatTime(_secondsRemaining),
      style: TextStyle(
          fontSize: widget.size == null ? 24 : widget.size,
          fontWeight: FontWeight.bold,
          color: widget.color),
    );
  }
}
