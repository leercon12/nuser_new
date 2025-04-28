import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'KAKAO_KEY', obfuscate: true)
  static String KAKAO_KEY = _Env.KAKAO_KEY;

  @EnviedField(varName: 'NEVER_OPEN_KEY', obfuscate: true)
  static String NEVER_OPEN_KEY = _Env.NEVER_OPEN_KEY;

  @EnviedField(varName: 'NEVER_OPEN_SCRET', obfuscate: true)
  static String NEVER_OPEN_SCRET = _Env.NEVER_OPEN_SCRET;

  @EnviedField(varName: 'HASH_KEY', obfuscate: true)
  static String HASH_KEY = _Env.HASH_KEY;

  @EnviedField(varName: 'CLIENT_ID', obfuscate: true)
  static String CLIENT_ID = _Env.CLIENT_ID;

  @EnviedField(varName: 'BAROBIL_KEY', obfuscate: true)
  static String BAROBIL_KEY = _Env.BAROBIL_KEY;

  @EnviedField(varName: 'NAVER_MAP_KEY', obfuscate: true)
  static String NAVER_MAP_KEY = _Env.NAVER_MAP_KEY;

  @EnviedField(varName: 'NEVER_SCRET_KEY', obfuscate: true)
  static String NEVER_SCRET_KEY = _Env.NEVER_SCRET_KEY;

  @EnviedField(varName: 'REFLASH_TOKEN', obfuscate: true)
  static String REFLASH_TOKEN = _Env.REFLASH_TOKEN;
}
