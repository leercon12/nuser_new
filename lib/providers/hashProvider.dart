import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_mixcall_normaluser_new/env.dart';

// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/block/modes/cbc.dart';
import 'package:pointycastle/padded_block_cipher/padded_block_cipher_impl.dart';
import 'package:pointycastle/paddings/pkcs7.dart';

class HashProvider extends ChangeNotifier {
  final String _encryptionKey = Env.HASH_KEY;
  final int _iterations = 300; // PBKDF2 iterations
  final int _keyLength = 32; // 256 bits

  Uint8List _generateSalt() {
    final random = Random.secure();
    return Uint8List.fromList(
        List<int>.generate(16, (_) => random.nextInt(256)));
  }

  Uint8List _deriveKey(String password, Uint8List salt) {
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    pbkdf2.init(Pbkdf2Parameters(salt, _iterations, _keyLength));
    return pbkdf2.process(utf8.encode(password));
  }

  String encryptData(String data) {
    final salt = _generateSalt();
    final key = _deriveKey(_encryptionKey, salt);
    final iv = _generateSalt(); // 16 bytes IV for AES

    final cipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      CBCBlockCipher(AESEngine()),
    );

    cipher.init(
      true,
      PaddedBlockCipherParameters(
        ParametersWithIV(KeyParameter(key), iv),
        null,
      ),
    );

    final dataBytes = utf8.encode(data);
    final cipherText = cipher.process(Uint8List.fromList(dataBytes));

    final combined = salt + iv + cipherText;
    return base64.encode(combined);
  }

  String encryptNLatLng(NLatLng latLng) {
    final coordinatesString = '${latLng.latitude},${latLng.longitude}';
    return encryptData(coordinatesString);
  }

  String decryptData(String encryptedData) {
    try {
      final combined = base64.decode(encryptedData);
      final salt = combined.sublist(0, 16);
      final iv = combined.sublist(16, 32);
      final cipherText = combined.sublist(32);

      final key = _deriveKey(_encryptionKey, salt);

      final cipher = PaddedBlockCipherImpl(
        PKCS7Padding(),
        CBCBlockCipher(AESEngine()),
      );

      cipher.init(
        false,
        PaddedBlockCipherParameters(
          ParametersWithIV(KeyParameter(key), iv),
          null,
        ),
      );

      final decrypted = cipher.process(Uint8List.fromList(cipherText));
      return utf8.decode(decrypted);
    } catch (e) {
      print('Decryption error: $e');
      return '';
    }
  }

  String decryptData2(String encryptedData) {
    try {
      final combined = base64.decode(encryptedData);
      final salt = combined.sublist(0, 16);
      final iv = combined.sublist(16, 32);
      final cipherText = combined.sublist(32);

      final key = _deriveKey(_encryptionKey, salt);

      final cipher = PaddedBlockCipherImpl(
        PKCS7Padding(),
        CBCBlockCipher(AESEngine()),
      );

      cipher.init(
        false,
        PaddedBlockCipherParameters(
          ParametersWithIV(KeyParameter(key), iv),
          null,
        ),
      );

      final decrypted = cipher.process(Uint8List.fromList(cipherText));
      return '${utf8.decode(decrypted)}';
    } catch (e) {
      print('Decryption error: $e');
      return '';
    }
  }

  NLatLng decLatLng(String decData) {
    final dec = decryptData(decData);
    final coordinates = dec.split(',');
    if (coordinates.length != 2) {
      throw FormatException('Invalid decrypted data format');
    }
    final latitude = double.parse(coordinates[0]);
    final longitude = double.parse(coordinates[1]);
    return NLatLng(latitude, longitude);
  }

  GeoFirePoint decGeoFirePoint(String decData) {
    final latLng = decLatLng(decData);
    return GeoFirePoint(GeoPoint(latLng.latitude, latLng.longitude));
  }

  Future<String> locationHash(
      BuildContext context, GeoFirePoint geoFirePoint) async {
    final latitudeString = _formatCoordinate(geoFirePoint.geopoint.latitude);
    final longitudeString = _formatCoordinate(geoFirePoint.geopoint.longitude);
    final geoString = '$latitudeString,$longitudeString';
    return encryptData(geoString);
  }

  String _formatCoordinate(double coordinate) {
    return coordinate.toStringAsFixed(6);
  }

  bool isValidGeoPoint(String data) {
    final parts = data.split(',');
    if (parts.length == 2) {
      return parts.every((part) => double.tryParse(part) != null);
    }
    return false;
  }

  /////////////////////////////////////////////
  ///
  ///
  /// 빠른 리스트 암호화
  final _fastKey = encrypt.Key.fromUtf8(Env.HASH_KEY.padRight(32, '0'));
  final _fastIv = encrypt.IV.fromLength(16);
  late final _fastEncrypter = encrypt.Encrypter(encrypt.AES(_fastKey));

  String fastEncryptPath(List<NLatLng> points) {
    if (points.isEmpty) return '';

    List<String> encryptedPoints = [];

    for (var point in points) {
      try {
        final iv = encrypt.IV.fromSecureRandom(16); // 매번 새로운 IV 생성
        String pointStr = '${point.latitude},${point.longitude}';
        String encrypted = _fastEncrypter.encrypt(pointStr, iv: iv).base64;
        encryptedPoints.add('${iv.base64}:$encrypted'); // IV도 함께 저장
      } catch (e) {
        print('Encryption error: $e');
      }
    }

    return encryptedPoints.join('|');
  }

  Future<List<NLatLng>> fastDecryptPath(String encrypted) async {
    if (encrypted.isEmpty) return [];

    List<NLatLng> points = [];
    List<String> encryptedPoints = encrypted.split('|');

    for (var encryptedPoint in encryptedPoints) {
      try {
        var parts = encryptedPoint.split(':');
        var iv = encrypt.IV.fromBase64(parts[0]); // IV 복원
        var decrypted =
            _fastEncrypter.decrypt64(parts[1], iv: iv); // 해당 IV로 복호화

        List<String> coords = decrypted.split(',');
        points.add(NLatLng(double.parse(coords[0]), double.parse(coords[1])));
      } catch (e) {
        print('Decryption error: $e');
      }
    }

    return points;
  }
}

class PasswordHash {
  static const _saltLength = 16;

  static String generateSalt() {
    final random = Random.secure();
    var values = List<int>.generate(_saltLength, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  static String hashPassword(String password, {String? salt}) {
    // 솔트가 제공되지 않았다면 새로 생성
    salt ??= generateSalt();

    // 비밀번호와 솔트를 결합
    var bytes = utf8.encode(password + salt);

    // SHA256 해시 생성
    var digest = sha256.convert(bytes);

    // 솔트와 해시를 결합하여 반환 (솔트:해시 형식)
    return '$salt:${digest.toString()}';
  }

  static bool verifyPassword(String password, String hashedPassword) {
    var parts = hashedPassword.split(':');
    if (parts.length != 2) return false;

    var salt = parts[0];
    var hash = parts[1];

    var newHashedPassword = hashPassword(password, salt: salt);
    return newHashedPassword == hashedPassword;
  }
}
