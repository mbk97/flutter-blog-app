import 'package:blog_app/screens/create_blog.dart';
import 'package:blog_app/screens/home.dart';
import 'package:flutter/material.dart';

class ReusableScaffold extends StatefulWidget {
  final Widget child; // Define a final variable for the child widget

  // Constructor with named parameter for the child widget
  const ReusableScaffold({
    super.key,
    required this.child, // Mark child as required
  });

  @override
  State<ReusableScaffold> createState() => _ReusableScaffoldState();
}

class _ReusableScaffoldState extends State<ReusableScaffold> {
  int _selectedIndex = 0; // Track the selected bottom nav item

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define pages for navigation
    final List<Widget> _pages = [
      const HomePage(), // Replace with your actual Home page widget
      const CreateBlog(), // Replace with your actual Create page widget
    ];

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        elevation: 4.0,
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: (index) {
          _onItemTapped(index);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => _pages[index],
            ),
          );
        },
        selectedItemColor: const Color(0xFF39605B),
        selectedFontSize: 14,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            tooltip: "Home",
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.create),
            label: 'Create',
          ),
        ],
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Blog App",
          style: TextStyle(
            color: Color(0xFF39605B),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1, // Set elevation if needed
      ),
      body: _pages[_selectedIndex], // Display the current page
    );
  }
}
