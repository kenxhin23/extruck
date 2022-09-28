import 'package:encrypt/encrypt.dart';

final key = Key.fromUtf8('SoAxVBnw8PYHzHHTFBQdG0MFCLNdmGFf'); //32 chars
final iv = IV.fromUtf8('T1g994xo2UAqG81M'); //16 chars

String encrypt(String string) {
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  final encrypted = encrypter.encrypt(string, iv: iv);
  // print(encrypted.base64);
  return encrypted.base64;
}

String decrypt(String string) {
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  final decrypted = encrypter.decrypt(Encrypted.fromBase64(string), iv: iv);
  // print(decrypted);
  return decrypted;
}
