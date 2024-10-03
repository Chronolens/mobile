import 'dart:convert';

/*
List<LoginRequest> loginRequestFromJson(String str) =>
    List<LoginRequest>.from(json.decode(str).map((x) => LoginRequest.fromJson(x)));
*/

String loginRequestToJson(List<LoginRequest> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LoginRequest {
  String username;
  String password;

  LoginRequest(this.username, this.password);

  // factory LoginRequest(String username, String password) {
  //   return LoginRequest(username, password);
  // }

  Map<String, dynamic> toJson() {
    return {
      "username": this.username,
      "password": this.password,
    };
  }
}
