import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final apiServiceClient = APIServiceClient();

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
      final response = await apiServiceClient.login(username, password);
      print(response);
      if (response == null) {
        print("Not OK");
        showErrorDialog(context, "bruh");
      } else {
        print("OK");
      }
    }

    Widget buildPassword() => TextField(
          onChanged: (value) => setState(() => password = value),
          decoration: InputDecoration(
            labelText: 'Password',
            //errorText: 'Password is wrong',
            suffixIcon: IconButton(
              icon: isPasswordVisible
                  ? const Icon(Icons.visibility_off)
                  : const Icon(Icons.visibility),
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
        onPressed: () => {login(username, password),print("")}, child: const Text("Log In"),);

    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            buildUsername(),
            buildPassword(),
            submitCredentials()
          ]),
        ),
        floatingActionButton:
            FloatingActionButton(onPressed: () => {}));
  }
}
