import 'dart:convert';
import 'package:blog_app/components/reusable_scaffold.dart';
import 'package:blog_app/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EditBlogPage extends StatefulWidget {
  final dynamic singleBlog;

  EditBlogPage({super.key, required this.singleBlog});

  @override
  State<EditBlogPage> createState() => _EditBlogPageState();
}

class _EditBlogPageState extends State<EditBlogPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  bool _isLoading = false;
  String? userToken;

  @override
  void initState() {
    super.initState();
    _title = widget.singleBlog['title'] ?? '';
    _description = widget.singleBlog['description'] ?? '';
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? userData = pref.getString('user_details');
    if (userData != null) {
      Map<String, dynamic> newData = jsonDecode(userData);
      setState(() {
        userToken = newData['data']['token'];
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

  void navigateToHomePage() {
    final route = MaterialPageRoute(
      builder: (context) => const ReusableScaffold(),
    );
    Navigator.push(context, route);
  }

  Future<void> _handleUpdateBlog() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final blog = widget.singleBlog;
      final payload = {'title': _title, 'description': _description};

      final id = blog['_id'];
      print(id);

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $userToken',
      };

      final url = 'https://blog-website-api.vercel.app/api/blog/$id';
      final uri = Uri.parse(url);
      final respose =
          await http.put(uri, body: jsonEncode(payload), headers: headers);
      if (respose.statusCode == 200) {
        final responseData = jsonDecode(respose.body);
        if (responseData.containsKey('message')) {
          showSuccessMessage(responseData['message']);
          navigateToHomePage();
          _title = "";
          _description = "";
        }
      }
    } catch (e) {
      showErrorMessage("Failed to update Blog, ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),
              TextFormField(
                initialValue: _title,
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
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value ?? '';
                },
              ),
              const SizedBox(height: 40),
              TextFormField(
                initialValue: _description,
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
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value ?? '';
                },
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _handleUpdateBlog();
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
                          "Edit Blog",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
