import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart';
import 'package:maybe_just_nothing/maybe_just_nothing.dart';
import '../services/login_service.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final loginServiceClient = LoginServiceClient();

  String username = "";
  String password = "";
  bool isPasswordVisible = false;
  bool wrongCredentials = false;

  @override
  Widget build(BuildContext context) {
    void showErrorDialog(BuildContext context, String message) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    void login(String username, String password) async {
      final response = await loginServiceClient.login(username, password);
      print(response);

      if (response is Just<GrpcError?>) {
        var error = response.value;
        if (error == null) {
          // NOTE: Other error
          showErrorDialog(context, "unkown error");
        } else {
          // NOTE: GRPC error
          switch (error.code) {
            case 5:
              showErrorDialog(context, error.message ?? "");
            case 14:
              showErrorDialog(context, error.message ?? "");
            case _:
              showErrorDialog(context, error.message ?? "");
          }
        }
      } else {
        print("OK");
        Navigator.of(context).pushReplacementNamed("/");
      }
    }

    Widget buildPassword() => TextField(
          onChanged: (value) => setState(() => password = value),
          decoration: InputDecoration(
            labelText: 'Password',
            suffixIcon: IconButton(
              icon: isPasswordVisible
                  ? const Icon(Icons.visibility)
                  : const Icon(Icons.visibility_off),
              onPressed: () =>
                  setState(() => isPasswordVisible = !isPasswordVisible),
            ),
            border: OutlineInputBorder(),
          ),
          obscureText: !isPasswordVisible,
        );

    Widget buildUsername() => TextField(
          onChanged: (value) => setState(() => username = value),
          decoration: const InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(),
          ),
        );

    Widget submitCredentials() => TextButton(
          onPressed: () => login(username, password),
          child: const Text("Log In"),
        );

    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            buildUsername(),
            buildPassword(),
            submitCredentials()
          ]),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.of(context).pushReplacementNamed("/")));
  }
}
