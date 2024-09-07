import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:prakriti/screens/community_page.dart';
import 'package:prakriti/screens/home.dart';
import 'package:prakriti/screens/loan_page.dart';
import 'package:prakriti/screens/market_screen.dart';
import 'package:prakriti/screens/news_page.dart';
import 'package:prakriti/screens/posts_list_screen.dart';
import 'package:prakriti/screens/schemes_screen.dart';
import 'package:prakriti/screens/voice_chat.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _selectedIndex = 0;

  // List of screens for each tab
  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    PostsListScreen(),
    // LoanPage(),
    const MarketScreen(),
    const SchemesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      floatingActionButton: keyboardIsOpened
          ? null
          : FloatingActionButton(
              heroTag: 'unique_bottom_fab', // Ensure this is unique
              backgroundColor: const Color(0xff399918),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VoiceChatScreen(),
                  ),
                );
              },
              shape: const CircleBorder(),
              elevation: 0,
              child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedVoiceId, color: Colors.white),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 4.0,
          color: Colors.transparent,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedHome09,
                  color: _selectedIndex == 0
                      ? const Color(0xff399918)
                      : Colors.grey,
                ),
                tooltip: "Home",
                onPressed: () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                },
              ),
              IconButton(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedUserGroup,
                  color: _selectedIndex == 1
                      ? const Color(0xff399918)
                      : Colors.grey,
                ),
                tooltip: "Community",
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
              ),
              const SizedBox(width: 40), // Add a space for the FAB
              IconButton(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedStore02,
                  color: _selectedIndex == 2
                      ? const Color(0xff399918)
                      : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                },
                tooltip: "Markets",
              ),
              IconButton(
                icon: const Icon(Icons.currency_rupee_sharp),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 3;
                  });
                },
                tooltip: "Schemes & Loans",
                color:
                    _selectedIndex == 3 ? const Color(0xff399918) : Colors.grey,
              ),
            ],
          ),
        ),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
    );
  }
}
