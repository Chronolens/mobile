import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final apiServiceClient = APIServiceClient();

  String username = "";
  String password = "";
  String serverAddress = "";
  bool isPasswordVisible = false;
  bool wrongCredentials = false;
  bool isLoadingServerAddress = true;

  @override
  void initState() {
    super.initState();
    _loadServerAddress();
  }

  Future<void> _loadServerAddress() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      serverAddress = prefs.getString(BASE_URL) ?? "";
      isLoadingServerAddress = false;
    });
  }

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
      final response =
          await apiServiceClient.login(username, password, serverAddress);

      switch (response) {
        case 200:
          Navigator.of(context).pushReplacementNamed("/home");
        case 401:
          showErrorDialog(context, LOGIN_ERROR_401);
        case null:
          showErrorDialog(context, LOGIN_ERROR_UNKNOWN);
        default:
          showErrorDialog(context, LOGIN_ERROR_UNKNOWN);
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
            border: const OutlineInputBorder(),
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

    Widget buildServer() {
      if (isLoadingServerAddress) {
        return const CircularProgressIndicator(); // TODO: Do a full loading page instead??
      }
      return TextFormField(
        //key: ValueKey(serverAddress),
        initialValue: serverAddress,
        onChanged: (value) => setState(() => serverAddress = value),
        decoration: const InputDecoration(
          labelText: 'Server',
          border: OutlineInputBorder(),
        ),
      );
    }

    Widget loginButton() => TextButton(
          onPressed: () => login(username, password),
          child: const Text("Log In"),
        );

    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            buildServer(),
            buildUsername(),
            buildPassword(),
            loginButton()
          ]),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () =>
                {Navigator.of(context).pushReplacementNamed("/home")}));
  }
}
