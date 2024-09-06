import 'dart:convert';
import 'package:blog_app/screens/home.dart';
import 'package:blog_app/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final loginFormKey = GlobalKey<FormState>();
  String? emailValue;
  String? passwordValue;
  bool _obscureText = true;
  bool _isLoading = false;

  void togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void clearInput() {
    setState(() {
      emailValue = "";
      passwordValue = "";
    });
  }

  void navigateToHomePage() {
    final route = MaterialPageRoute(
      builder: (context) => const HomePage(),
    );
    Navigator.push(context, route);
  }

  Future<void> handleLoginUser() async {
    final email = emailValue;
    final password = passwordValue;

    setState(() {
      _isLoading = true;
    });

    final payload = {
      "email": email,
      "password": password,
    };

    // Update the URL to point to the login endpoint
    const url = "https://blog-website-api.vercel.app/api/user/login";
    final uri = Uri.parse(url);

    try {
      final response = await http.post(
        uri,
        body: jsonEncode(payload),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData.containsKey('message')) {
          showSuccessMessage(responseData['message']);
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        final userDataPayload = {
          "name": responseData['user']['name'],
          "email": responseData['user']['email'],
          "token": responseData['user']['token'],
        };
        prefs.setString('user_details', jsonEncode({'data': userDataPayload}));

        clearInput();
        navigateToHomePage();
      } else {
        final errorData = jsonDecode(response.body);
        showErrorMessage(errorData['message']);
      }
    } catch (e) {
      showErrorMessage('Failed to log in ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: loginFormKey,
        child: Column(
          children: [
            const SizedBox(height: 100),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Welcome back! Glad to see you, Again!",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Color(0xFF39605B),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextFormField(
                decoration: const InputDecoration(
                  hintText: "Enter your Email",
                  filled: true,
                  fillColor: Color(0xFFDADADA),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFF7F8F9),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF39605B),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFF7F8F9),
                    ),
                  ),
                ),
                style: const TextStyle(fontSize: 15),
                cursorColor: const Color(0xFF39605B),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your email";
                  }
                  return null;
                },
                onSaved: (value) {
                  emailValue = value;
                },
              ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: "Enter your Password",
                  filled: true,
                  fillColor: const Color(0xFFDADADA),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFF7F8F9),
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF39605B),
                    ),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFF7F8F9),
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: togglePasswordVisibility,
                  ),
                ),
                style: const TextStyle(fontSize: 15),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                cursorColor: const Color(0xFF39605B),
                obscureText: _obscureText,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your password";
                  }
                  return null;
                },
                onSaved: (value) {
                  passwordValue = value;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (loginFormKey.currentState!.validate()) {
                      loginFormKey.currentState!.save();
                      handleLoginUser(); // Call the login function
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF39605B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20.0, // Adjust the height
                          width: 20.0, // Adjust the width
                          child: CircularProgressIndicator(
                            strokeWidth: 4.0,
                            // backgroundColor: Colors.white,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Register Now",
                      style: TextStyle(color: Color(0xFF35C2C1)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
