import 'package:mobile/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../utils/theme.dart';
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
          Navigator.of(context).pushReplacementNamed("/");
        case 401:
          showErrorDialog(context, LOGIN_ERROR_401);
        case null:
          showErrorDialog(context, LOGIN_ERROR_UNKNOWN);
        default:
          showErrorDialog(context, LOGIN_ERROR_UNKNOWN);
      }
    }

    Widget buildPassword() => Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          child: TextField(
            onChanged: (value) => setState(() => password = value),
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: const TextStyle(color: Colors.white),
              suffixIcon: IconButton(
                icon: isPasswordVisible
                    ? const Icon(Icons.visibility, color: Colors.white)
                    : const Icon(Icons.visibility_off, color: Colors.white),
                onPressed: () =>
                    setState(() => isPasswordVisible = !isPasswordVisible),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            obscureText: !isPasswordVisible,
            style: const TextStyle(color: Colors.white),
          ),
        );

    Widget buildUsername() => Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          child: TextField(
            onChanged: (value) => setState(() => username = value),
            decoration: const InputDecoration(
              labelText: 'Username',
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        );

    Widget buildServer() {
      if (isLoadingServerAddress) {
        return const CircularProgressIndicator();
      }
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 32), 
        child: TextFormField(
          initialValue: serverAddress,
          onChanged: (value) => setState(() => serverAddress = value),
          decoration: const InputDecoration(
            labelText: 'Server',
            labelStyle: TextStyle(color: Colors.white),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    Widget loginButton() => TextButton(
          onPressed: () => login(username, password),
          child: const Text("Log In", style: TextStyle(color: Colors.white)),
        );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.darkPurple, Colors.black],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Spacer(flex: 5),
              buildServer(),
              const SizedBox(height: 16),
              buildUsername(),
              const SizedBox(height: 16),
              buildPassword(),
              const SizedBox(height: 16),
              loginButton(),
              Spacer(flex: 2),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushReplacementNamed("/"),
        child: const Icon(Icons.arrow_forward, color: Colors.white),
      ),
    );
  }
}
