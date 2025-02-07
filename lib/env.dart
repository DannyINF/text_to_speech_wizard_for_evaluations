import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: 'secret.env')
final class Env {
  @EnviedField(varName: 'GOOGLE_KEY', obfuscate: true)
  static final String GOOGLE_KEY = _Env.GOOGLE_KEY;
}