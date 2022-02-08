import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:my_heb_clone/models/auth.dart';
import 'package:my_heb_clone/services/heb_service_error.dart';
import 'package:my_heb_clone/services/heb_service_exception.dart';

class HebAuthService {
  static const _authority = 'identitytoolkit.googleapis.com';
  static const _refreshAuthority = 'securetoken.googleapis.com';
  static const _webApiKey = 'your-web-api-key';

  // TODO: handle errors (EMAIL_EXISTS, TOO_MANY_ATTEMPTS_TRY_LATER) etc.
  Future<Auth> signupNewUser(String email, String password) async {
    return await _authenticate(email, password, true);
  }

  Future<Auth> loginUser(String email, String password) async {
    return await _authenticate(email, password);
  }

  Future<Auth> _authenticate(String email, String password, [bool createAccount = false]) async {
    final uri = Uri.https(
      _authority,
      'v1/accounts:${createAccount ? 'signUp' : 'signInWithPassword'}',
      {'key': _webApiKey},
    );

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );

    if (response.statusCode >= 400) {
      final error =
          HebServiceError.fromJson(json.decode(response.body)['error']);
      throw HebServiceException('http error ${error.message}');
    }

    return Auth.fromJson(json.decode(response.body), isRefresh: false, dateTime: DateTime.now());
  }

  Future<Auth> refreshAuth(String refreshToken) async {
    final uri = Uri.https(
      _refreshAuthority,
      'v1/token',
      {'key': _webApiKey}
    );

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
      }),
    );

    return Auth.fromJson(json.decode(response.body), isRefresh: true, dateTime: DateTime.now());
  }
}
