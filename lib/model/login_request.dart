import 'dart:convert';

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
