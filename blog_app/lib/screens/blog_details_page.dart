import 'dart:convert'; // For jsonDecode
import 'package:blog_app/components/reusable_scaffold.dart';
import 'package:blog_app/screens/edit_blog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BlogDetailsPage extends StatefulWidget {
  final String blogId;
  final dynamic singleBlog;
  final String? userToken;

  BlogDetailsPage(
      {super.key,
      required this.blogId,
      required this.singleBlog,
      required this.userToken});

  @override
  _BlogDetailsPageState createState() => _BlogDetailsPageState();
}

class _BlogDetailsPageState extends State<BlogDetailsPage> {
  bool _isDeleteLoading = false;

  Future<void> _handleDelete(String id) async {
    try {
      setState(() {
        _isDeleteLoading = true;
      });

      final headers = {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer ${widget.userToken}', // Make sure userToken is defined
      };

      final url = 'https://blog-website-api.vercel.app/api/blog/$id';
      final uri = Uri.parse(url);
      final response = await http.delete(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        showSuccessMessage(data["message"]);
        Navigator.of(context)
            .pop(); // Close the dialog after successful deletion
        navigateToHomePage();
      }
    } catch (e) {
      showErrorMessage('Failed to delete: ${e.toString()}');
    } finally {
      setState(() {
        _isDeleteLoading = false;
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

  void _showDialog(BuildContext context, dynamic data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Delete Blog'),
              content:
                  Text('Are you sure you want to delete ${data['title']}?'),
              actions: [
                TextButton(
                  onPressed: () async {
                    setState(() {
                      _isDeleteLoading = true;
                    }); // Update the dialog state
                    await _handleDelete(data["_id"]);
                    setState(() {
                      _isDeleteLoading = false;
                    });
                  },
                  child: Text(
                    _isDeleteLoading ? "Deleting..." : 'Delete',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text(
                    'No',
                    style: TextStyle(color: Color(0xFF39605B)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void navigateToHomePage() {
    final route = MaterialPageRoute(
      builder: (context) => const ReusableScaffold(),
    );
    Navigator.push(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final blog = widget.singleBlog.isNotEmpty ? widget.singleBlog : {};

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFE8ECF4), // Border color
                    width: 2.0, // Set the width of the border
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
                      Navigator.pop(
                          context); // Navigate back to the previous page
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${blog?['title']}', // Include the blog ID in the title
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                blog?['description'] ??
                    'No description available', // Provide fallback for description
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: const Color(0xFF39605B)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditBlogPage(
                                  singleBlog: blog,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            "Edit",
                            style: TextStyle(color: Colors.white),
                          ))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Colors.red),
                          onPressed: () {
                            _showDialog(context, blog);
                          },
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.white),
                          )))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
