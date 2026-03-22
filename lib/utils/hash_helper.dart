import 'dart:convert';
import 'package:crypto/crypto.dart';

class HashHelper {
  /// Hashes a plaintext password using SHA-256
  static String hashPassword(String plaintext) {
    if (plaintext.isEmpty) return '';
    final bytes = utf8.encode(plaintext);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
