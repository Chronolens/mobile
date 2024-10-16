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
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    final serverAddressPrefs = await prefs.getString(BASE_URL) ?? "";
    setState(() {
      serverAddress = serverAddressPrefs;
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

    Widget buildPassword() => Container(
          margin: const EdgeInsets.symmetric(horizontal: 48),
          child: TextField(
            onChanged: (value) => setState(() => password = value),
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.7)), 
              suffixIcon: IconButton(
                icon: isPasswordVisible
                    ? const Icon(Icons.visibility, color: Colors.white70)  
                    : const Icon(Icons.visibility_off, color: Colors.white70),
                onPressed: () =>
                    setState(() => isPasswordVisible = !isPasswordVisible),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 2), 
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 2), 
              ),
            ),
            obscureText: !isPasswordVisible,
            style: const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.7)),  
          ),
        );

    Widget buildUsername() => Container(
          margin: const EdgeInsets.symmetric(horizontal: 48),
          child: TextField(
            onChanged: (value) => setState(() => username = value),
            decoration: const InputDecoration(
              labelText: 'Username',
              labelStyle: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.7)),  
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 2), 
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 2), 
              ),
            ),
            style: const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.7)),  
          ),
        );

    Widget buildServer() {
      if (isLoadingServerAddress) {
        return const CircularProgressIndicator();
      }
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 48), 
        child: TextFormField(
          initialValue: serverAddress,
          onChanged: (value) => setState(() => serverAddress = value),
          decoration: const InputDecoration(
            labelText: 'Server',
            labelStyle: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.7)),  
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2), 
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2), 
            ),
          ),
          style: const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.7)),  
        ),
      );
    }


    Widget loginButton() => Container(
          margin: const EdgeInsets.symmetric(horizontal: 48), 
          width: double.infinity, 
          child: Material(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(4), 
            child: InkWell(
              onTap: () => login(username, password), 
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12), 
                child: Center(
                  child: Text(
                    "Log In",
                    style: TextStyle(
                      color: Colors.black, 
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

    
    Widget buildTitle() => Container(
          margin: const EdgeInsets.only(top: 128),  
          alignment: Alignment.center,  
          child: const Text(
            "ChronoLens",
            style: TextStyle(
              fontSize: 38,  
              fontWeight: FontWeight.normal,
              color: Colors.white,  
            ),
            textAlign: TextAlign.center,  
          ),
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
              mainAxisAlignment: MainAxisAlignment.start, 
              children: [
                buildTitle(),  
                const Spacer(flex: 5), 
                buildServer(),
                const SizedBox(height: 16),  
                buildUsername(),
                const SizedBox(height: 16),  
                buildPassword(),
                const SizedBox(height: 48),  
                loginButton(),
                const Spacer(flex: 4), 
              ],
            ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushReplacementNamed("/home"),
        child: const Icon(Icons.arrow_forward, color: Colors.white),
      ),
    );
  }
}
