import 'package:flutter/material.dart';
import 'main.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  bool _wifiPassVisibility = true;
  bool _userPassVisibility = true;
  TextEditingController userInputController = TextEditingController();
  TextEditingController wifiPasswordInputController = TextEditingController();
  TextEditingController userPasswordInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: Text("Welcome to CleverFeeder!"),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
              child: TextField(
                controller: userInputController,
                key: const Key('username-input'),
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.visiblePassword,
                decoration: const InputDecoration(
                    hintText: "Username", border: OutlineInputBorder()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
              child: TextField(
                controller: userPasswordInputController,
                key: const Key('user-password-input'),
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.visiblePassword,
                obscureText: _userPassVisibility,
                decoration: InputDecoration(
                    hintText: "Password",
                    helperText: "Temporary Account password for Database/MQTT",
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _userPassVisibility = !_userPassVisibility;
                          });
                        },
                        icon: _userPassVisibility
                            ? const Icon(Icons.visibility_off)
                            : const Icon(Icons.visibility)),
                    border: const OutlineInputBorder()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
              child: TextField(
                controller: wifiPasswordInputController,
                key: const Key('wifi-password-input'),
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.visiblePassword,
                obscureText: _wifiPassVisibility,
                decoration: InputDecoration(
                    hintText: "Wi-Fi Password",
                    helperText:
                        "Wi-Fi Password of the Network you're Connected to",
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _wifiPassVisibility = !_wifiPassVisibility;
                          });
                        },
                        icon: _wifiPassVisibility
                            ? const Icon(Icons.visibility_off)
                            : const Icon(Icons.visibility)),
                    border: const OutlineInputBorder()),
              ),
            ),
            MaterialButton(
              onPressed: () {
                print(UserInfo.isUserNew);
                UserInfo.isUserNew = false;
                print(UserInfo.isUserNew);
                setState(() {});
              },
              child: const Text("SUBMIT"),
            )
          ],
        ));
  }
}
