import 'dart:convert';
import 'package:blog_app/components/reusable_scaffold.dart';
import 'package:blog_app/utils/shared.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateBlog extends StatefulWidget {
  final Function() goBackToHome;
  const CreateBlog({super.key, required this.goBackToHome});

  @override
  State<CreateBlog> createState() => _CreateBlogState();
}

class _CreateBlogState extends State<CreateBlog> {
  final _formKey = GlobalKey<FormState>();
  String? userToken;
  bool _isLoading = false;
  String? _title;
  String? _description;

  @override
  void initState() {
    super.initState();
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

  void navigateToHomePage() {
    final route = MaterialPageRoute(
      builder: (context) => const ReusableScaffold(),
    );
    Navigator.push(context, route);
  }

  Future<void> _createBlog() async {
    final userData = await SharedPrefService.getUserData();
    if (userData == null) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });
      final title = _title;
      final description = _description;

      final payload = {
        'title': title,
        'description': description,
      };

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${userData['token']}',
      };

      const url = 'https://blog-website-api.vercel.app/api/blog';
      final uri = Uri.parse(url);
      final response =
          await http.post(uri, body: jsonEncode(payload), headers: headers);

      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
        });
        showSuccessMessage("Blog created successfully");
        _title = "";
        _description = "";
        navigateToHomePage();
      }
    } catch (e) {
      print(e);
      showErrorMessage("Failed to create blog. Error: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey, // Assign form key for validation
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFE8ECF4),
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xFF39605B),
                        size: 24.0,
                      ),
                      onPressed: () {
                        widget.goBackToHome();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  cursorColor: const Color(0xFF39605B),
                  decoration: const InputDecoration(
                    hintText: "Enter your blog Title here",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFF7F8F9)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF39605B)),
                    ),
                  ),
                  autovalidateMode: AutovalidateMode
                      .onUserInteraction, // Enable real-time validation
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _title = value;
                  },
                ),
                const SizedBox(height: 40),
                TextFormField(
                  maxLines: 10,
                  cursorColor: const Color(0xFF39605B),
                  decoration: const InputDecoration(
                    hintText: "Enter your blog Description here",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFF7F8F9)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF39605B)),
                    ),
                  ),
                  autovalidateMode: AutovalidateMode
                      .onUserInteraction, // Enable real-time validation
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _description = value;
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        _createBlog();
                        // Perform the form submission logic here
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF39605B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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
                            "Create Blog",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
