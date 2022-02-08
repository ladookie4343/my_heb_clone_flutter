import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_heb_clone/models/user.dart';

class SecureStorage {

  static const _storage = FlutterSecureStorage();

  static Future<void> storeUserInfo(User user) async {
    final userJsonString = json.encode(user);
    await _storage.write(key: 'user', value: userJsonString);
  }

  static Future<User?> retrieveUserInfo() async {
    final userJson = await _storage.read(key: 'user');
    return userJson != null ? User.fromJson(json.decode(userJson)) : null;
  }

  static Future<void> clearUserInfo() async {
    await _storage.delete(key: 'user');
  }
}