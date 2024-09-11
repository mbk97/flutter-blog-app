import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:blog_app/components/reusable_scaffold.dart';
import 'package:blog_app/screens/blog_details_page.dart';
import 'package:blog_app/screens/create_blog.dart';
import 'package:blog_app/screens/edit_blog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userToken;
  List<dynamic>? blogsData;
  bool _isLoading = false;
  bool _isDeleteLoading = true;

  @override
  void initState() {
    super.initState();
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
      await fetchAllBlogs();
    }
  }

  Future<void> fetchAllBlogs() async {
    setState(() {
      _isLoading = true;
    });
    if (userToken == null) {
      return;
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $userToken',
    };

    const url = 'https://blog-website-api.vercel.app/api/blog';
    final uri = Uri.parse(url);
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map;
      final result = data['blogs']; // Assuming 'blogs' key contains the data
      setState(() {
        blogsData = result;
      });
    } else {
      showErrorMessage('Failed to fetch');
    }
  }

  Future<void> _handleDelete(String id) async {
    try {
      setState(() {
        _isDeleteLoading = true;
      });
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $userToken',
      };

      final url = 'https://blog-website-api.vercel.app/api/blog/$id';
      final uri = Uri.parse(url);
      final response = await http.delete(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        fetchAllBlogs();
        showSuccessMessage(data["message"]);
        Navigator.of(context)
            .pop(); // Close the dialog after successful deletion
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? SingleChildScrollView(
              child: Column(children: [
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 10, // Space between skeleton cards horizontally
                    runSpacing: 10, // Space between rows
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: (MediaQuery.of(context).size.width / 2) -
                            15, // Match the card width
                        child: Container(
                          height: 180, // Same height as the blog card
                          decoration: BoxDecoration(
                            color: Colors
                                .grey[300], // Light grey color for skeleton
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ]),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Text(
                                'WR',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'I',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF39605B), // Make "I" green
                                ),
                              ),
                              Text(
                                'TE',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: const Color(0xFF39605B)),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CreateBlog(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Create Blog",
                                style: TextStyle(color: Colors.white),
                              ))
                        ]),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      spacing: 10, // Space between cards horizontally
                      runSpacing: 10, // Space between rows
                      children: blogsData != null && blogsData!.isNotEmpty
                          ? blogsData!.map((blog) {
                              return SizedBox(
                                width: (MediaQuery.of(context).size.width / 2) -
                                    15,
                                child: Card(
                                  color: Colors.white,
                                  shadowColor: Colors.black,
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Container(
                                    height: 240,
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                blog['title'],
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.start,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            PopupMenuButton<String>(
                                              color: Colors.white,
                                              elevation: 2,
                                              shadowColor: Colors.black,
                                              onSelected: (String result) {
                                                if (result == 'read') {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          BlogDetailsPage(
                                                        blogId: blog['_id'],
                                                        singleBlog: blog,
                                                        userToken: userToken,
                                                      ),
                                                    ),
                                                  );
                                                } else if (result == 'edit') {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditBlogPage(
                                                        singleBlog: blog,
                                                      ),
                                                    ),
                                                  );
                                                } else if (result == 'delete') {
                                                  _showDialog(context, blog);
                                                }
                                              },
                                              itemBuilder:
                                                  (BuildContext context) =>
                                                      <PopupMenuEntry<String>>[
                                                if (blog['description']
                                                        .split(' ')
                                                        .length >
                                                    50)
                                                  const PopupMenuItem<String>(
                                                    value: 'read',
                                                    child: Text('Read More'),
                                                  ),
                                                const PopupMenuItem<String>(
                                                  value: 'edit',
                                                  child: Text('Edit'),
                                                ),
                                                PopupMenuItem<String>(
                                                  value: 'delete',
                                                  child: _isDeleteLoading
                                                      ? const Text(
                                                          'Deleting...',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        )
                                                      : const Text('Delete'),
                                                )
                                              ],
                                              icon: const Icon(Icons
                                                  .more_vert), // Three-dot icon
                                            ),
                                          ],
                                        ),
                                        Text(
                                          blog['description'],
                                          style: const TextStyle(fontSize: 14),
                                          textAlign: TextAlign.left,
                                          maxLines: 7,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList()
                          : [const Text('No blogs available')],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
