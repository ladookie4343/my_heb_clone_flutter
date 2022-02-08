class Auth {
  final String idToken;
  final String refreshToken;
  final String expiresIn;
  final String localId;
  final DateTime issueTime;

  Auth({
    required this.idToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.localId,
    required this.issueTime,
  });

  bool get isExpired {
    var durationInSeconds = Duration(seconds: int.parse(expiresIn));
    return DateTime.now().isAfter(issueTime.add(durationInSeconds));
  }

  /// refresh token response:
  /// {
  ///   "access_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjE1MjU1NWEyMjM3MWYxMGY0ZTIyZjFhY2U3NjJmYzUwZmYzYmVlMGMiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vbXktaC1lLWItY2xvbmUiLCJhdWQiOiJteS1oLWUtYi1jbG9uZSIsImF1dGhfdGltZSI6MTYzNTQ3NjAwOSwidXNlcl9pZCI6Ijh1WGEwOVhTUEtaTjRFdks3QUZnZmM4ejU1SzIiLCJzdWIiOiI4dVhhMDlYU1BLWk40RXZLN0FGZ2ZjOHo1NUsyIiwiaWF0IjoxNjM1NDgyMDk1LCJleHAiOjE2MzU0ODU2OTUsImVtYWlsIjoidHlyZWVrLmhpbGxAbmZsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjpmYWxzZSwiZmlyZWJhc2UiOnsiaWRlbnRpdGllcyI6eyJlbWFpbCI6WyJ0eXJlZWsuaGlsbEBuZmwuY29tIl19LCJzaWduX2luX3Byb3ZpZGVyIjoicGFzc3dvcmQifX0.ZPlToz-k-Ra49dgQNIEf2M_SbZUOp9z0S5U3_3sle-HlcEH63VShtIhM7FxwE6b5DE8KNXsf9wt4v-N8oH803Y7Nu4xsFZmlmj-SlbMStvMLtqGVFYq2QDcQnUyEMbWpYdvWT0y8d6C_S6_boXf_nWLTYvytk7ymTZ-hJY0dCnyKV0q6n6c1qpO9q6M_cZXoPuYqU3epOkdBmFbVcXTQobJKTBnu9QdfYiRRJVBiACJpKv9YkWDFdVUs_yWBqqRq1xhEllZ2J0jNum0jWCWm4bqboN9Q0e3B8UM-gszW-1I-WbVvxMTz2n41oUfJXpGFXKzfrYGTVr8c9PdwiKANYg",
  ///   "expires_in": "3600",
  ///   "token_type": "Bearer",
  ///   "refresh_token": "AFxQ4_qkpRcPICrxR9fmTM6cKEDF8vcYZvSLlWT43Jv8_gr-_w4VtwZ35JNPJEg6zAeblMkeNKKcM8riPlThoIadcX3o-yKNDCSmbk33w0Kf2XhGnRa-fluItJOs9gCtiUhuuYJcIDFM9gH8SC4YMjoILpHD6dY4HGFXBNBxphExFrV4cIodO52rubwlEYT6U_6yrsa2plOiUBVMKC8dpMeiIyGQu7O2Iw",
  ///   "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjE1MjU1NWEyMjM3MWYxMGY0ZTIyZjFhY2U3NjJmYzUwZmYzYmVlMGMiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vbXktaC1lLWItY2xvbmUiLCJhdWQiOiJteS1oLWUtYi1jbG9uZSIsImF1dGhfdGltZSI6MTYzNTQ3NjAwOSwidXNlcl9pZCI6Ijh1WGEwOVhTUEtaTjRFdks3QUZnZmM4ejU1SzIiLCJzdWIiOiI4dVhhMDlYU1BLWk40RXZLN0FGZ2ZjOHo1NUsyIiwiaWF0IjoxNjM1NDgyMDk1LCJleHAiOjE2MzU0ODU2OTUsImVtYWlsIjoidHlyZWVrLmhpbGxAbmZsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjpmYWxzZSwiZmlyZWJhc2UiOnsiaWRlbnRpdGllcyI6eyJlbWFpbCI6WyJ0eXJlZWsuaGlsbEBuZmwuY29tIl19LCJzaWduX2luX3Byb3ZpZGVyIjoicGFzc3dvcmQifX0.ZPlToz-k-Ra49dgQNIEf2M_SbZUOp9z0S5U3_3sle-HlcEH63VShtIhM7FxwE6b5DE8KNXsf9wt4v-N8oH803Y7Nu4xsFZmlmj-SlbMStvMLtqGVFYq2QDcQnUyEMbWpYdvWT0y8d6C_S6_boXf_nWLTYvytk7ymTZ-hJY0dCnyKV0q6n6c1qpO9q6M_cZXoPuYqU3epOkdBmFbVcXTQobJKTBnu9QdfYiRRJVBiACJpKv9YkWDFdVUs_yWBqqRq1xhEllZ2J0jNum0jWCWm4bqboN9Q0e3B8UM-gszW-1I-WbVvxMTz2n41oUfJXpGFXKzfrYGTVr8c9PdwiKANYg",
  ///   "user_id": "8uXa09XSPKZN4EvK7AFgfc8z55K2",
  ///   "project_id": "194444552590"
  /// }
  ///
  factory Auth.fromJson(Map<String, dynamic> decodedJson, {required bool isRefresh, DateTime? dateTime}) {
    return Auth(
      idToken: decodedJson[isRefresh ? 'id_token' : 'idToken'],
      refreshToken: decodedJson[isRefresh ? 'refresh_token' : 'refreshToken'],
      expiresIn: decodedJson[isRefresh ? 'expires_in' : 'expiresIn'],
      localId: decodedJson[isRefresh ? 'user_id' : 'localId'],
      issueTime: dateTime ?? DateTime.parse(decodedJson['issueTime']),
    );
  }

  Map<String, dynamic> toJson() => {
    'idToken': idToken,
    'refreshToken': refreshToken,
    'expiresIn': expiresIn,
    'localId': localId,
    'issueTime': issueTime.toIso8601String(),
  };
}
