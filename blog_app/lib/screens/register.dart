import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blog_app/screens/home.dart';
import 'package:blog_app/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String? _fullName;
  String? _email;
  String? _password;
  bool _isLoading = false;
  bool _obscureText = true;

  void togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 50),
            Row(
              children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to the register page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const LoginPage(), // Replace with your login page
                          ),
                        );
                      },
                      child: Container(
                          width: 40,
                          height: 40,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFE8ECF4), // Border color
                              width: 2.0, // Set the width of the border
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: Color(0xFF39605B),
                              size: 24.0,
                            ),
                          )),
                    ))
              ],
            ),
            const SizedBox(height: 30),
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
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextFormField(
                decoration: const InputDecoration(
                  hintText: "Enter your full name",
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
                autovalidateMode: AutovalidateMode
                    .onUserInteraction, // Enable real-time validation
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _fullName = value;
                },
                style: const TextStyle(fontSize: 15),
                cursorColor: const Color(0xFF39605B),
              ),
            ),
            const SizedBox(height: 2),
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
                    return 'Please enter your email';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                onSaved: (newValue) {
                  _email = newValue;
                },
              ),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: "Enter your password",
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
                cursorColor: const Color(0xFF39605B),
                obscureText: _obscureText,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  } else if (value.length < 8) {
                    return 'Password is too short';
                  } else if (!RegExp(r'^(?=.*[A-Z])').hasMatch(value)) {
                    return 'Password must contain at least one uppercase letter';
                  } else if (!RegExp(r'^(?=.*\d)').hasMatch(value)) {
                    return 'Password must contain at least one number';
                  } else if (!RegExp(r'^(?=.*[!@#\$&*~])').hasMatch(value)) {
                    return 'Password must contain at least one special character';
                  }
                  return null;
                },
                onSaved: (newValue) {
                  _password = newValue;
                },
              ),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      handleRegisterUser();
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
                          'Register',
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
                  const Text("Already have an account?"),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      // Navigate to the register page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const LoginPage(), // Replace with your login page
                        ),
                      );
                    },
                    child: const Text(
                      "Login",
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

  void handleRegisterUser() async {
    final fullName = _fullName;
    final email = _email;
    final password = _password;

    setState(() {
      _isLoading = true;
    });

    final payload = {
      "name": fullName,
      "email": email,
      "password": password,
    };

    const url = "https://blog-website-api.vercel.app/api/user/register";
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
      // Handle any network errors or exceptions
      showErrorMessage('Failed to register user');
      // showErrorMessage("Network error occurred. Please try again later.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
    _fullName = "";
    _email = "";
    _password = "";
  }

  void navigateToHomePage() {
    final route = MaterialPageRoute(
      builder: (context) => const HomePage(),
    );
    Navigator.push(context, route);
  }
}
