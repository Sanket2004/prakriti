import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:prakriti/components/button.dart';
import 'package:prakriti/responsive/responsive.dart';
import 'package:prakriti/screens/login_screen.dart';
import 'package:prakriti/screens/profile_page.dart';
import 'package:prakriti/screens/review_page.dart';
import 'package:prakriti/screens/weather_screen.dart';
import 'package:prakriti/services/news_service.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  User? _user;
  Map<String, dynamic>? _userData;
  final TextEditingController _searchController = TextEditingController();
  String _selectedTag = ''; // Track the selected tag
  List<Map<String, dynamic>> _filteredPasswords = [];
  List<Map<String, dynamic>> _passwords = [];

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _newsArticles = NewsService().fetchNews('farming agriculture');
  }

  // Function to fetch the current user details from Firestore
  Future<void> _fetchUserDetails() async {
    _user = FirebaseAuth.instance.currentUser;

    if (_user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .get();

        if (userDoc.exists) {
          if (mounted) {
            setState(() {
              _userData = userDoc.data() as Map<String, dynamic>?;
            });
          }

          // Fetch passwords subcollection
          // QuerySnapshot passwordSnapshot = await FirebaseFirestore.instance
          //     .collection('users')
          //     .doc(_user!.uid)
          //     .collection('password')
          //     .orderBy(
          //       'createdAt',
          //       descending: true,
          //     )
          //     .get();

          // List<Map<String, dynamic>> passwords = passwordSnapshot.docs
          //     .map((doc) => doc.data() as Map<String, dynamic>)
          //     .toList();

          // setState(() {
          //   _passwords = passwords;
          //   _filteredPasswords = passwords; // Initialize filtered passwords
          // });
        }
      } catch (e) {
        print('Error fetching user details: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Error fetching user details: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xff312651),
        ));
      }
    }
  }

  // Function to show logout confirmation dialog
  Future<void> _showLogoutConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 0,
          backgroundColor: const Color(0xffe6e4e6),
          title: const Text(
            'Confirm Logout',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          content: const Text(
            'Are you sure you want to log out?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _logout(); // Call logout function
              },
              child: const Text(
                'Logout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                    color: Color(0xff312651), fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }

  // Function to handle logout
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate back to login screen or any other initial screen
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const LoginScreen()));
    } catch (e) {
      print('Error logging out: $e');
      // Show error message or handle gracefully
    }
  }

  String _getFirstName(String fullName) {
    List<String> nameParts = fullName.split(' ');
    return nameParts.isNotEmpty ? nameParts[0] : '';
  }

  // Function to filter passwords based on search query
  void _filterPasswords(String query) {
    List<Map<String, dynamic>> filteredList = _passwords.where((password) {
      String website = password['website'] ?? '';
      String username = password['username'] ?? '';

      return website.toLowerCase().contains(query.toLowerCase()) ||
          username.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredPasswords = filteredList;
    });
  }

  // Menu bottom sheet
  void _openBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      elevation: 0,
      backgroundColor: Colors.grey.shade100,
      isScrollControlled: true, // Ensure the bottom sheet occupies full height
      builder: (BuildContext context) {
        return SingleChildScrollView(
          // Wrap with SingleChildScrollView
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context)
                  .viewInsets
                  .bottom, // Adjust for keyboard
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff312651),
                  ),
                ).animate().slideY(
                    duration: 500.ms,
                    begin: 5,
                    end: 0,
                    curve: Curves.easeInOut),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    // Navigator.pushNamed(context, '/profile');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfileScreen()));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: const Color(0xffe6e4e6),
                        borderRadius: BorderRadius.circular(22)),
                    child: Row(
                      children: [
                        Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 211, 210, 211),
                                borderRadius: BorderRadius.circular(15)),
                            child: const Icon(
                              Icons.account_circle_outlined,
                              color: Color(0xff444262),
                              size: 18,
                            )),
                        const SizedBox(
                          width: 10,
                        ),
                        const Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Profile',
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Personal details and other details',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ).animate().slideY(
                      duration: 500.ms,
                      begin: 5,
                      end: 0,
                      curve: Curves.easeInOut),
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    // Navigator.pushNamed(context, '/profile');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ReviewScreen()));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: const Color(0xffe6e4e6),
                        borderRadius: BorderRadius.circular(22)),
                    child: Row(
                      children: [
                        Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 211, 210, 211),
                                borderRadius: BorderRadius.circular(15)),
                            child: const Icon(
                              HugeIcons.strokeRoundedStar,
                              color: Color(0xff444262),
                              size: 18,
                            )),
                        const SizedBox(
                          width: 10,
                        ),
                        const Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Review the app',
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Give your feedback about this app',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ).animate().slideY(
                      duration: 500.ms,
                      begin: 5,
                      end: 0,
                      curve: Curves.easeInOut),
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    _showLogoutConfirmationDialog();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: const Color(0xffe6e4e6),
                        borderRadius: BorderRadius.circular(22)),
                    child: Row(
                      children: [
                        Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 211, 210, 211),
                                borderRadius: BorderRadius.circular(15)),
                            child: const Icon(
                              Icons.logout_outlined,
                              color: Color(0xff444262),
                              size: 18,
                            )),
                        const SizedBox(
                          width: 10,
                        ),
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Logout',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'This action is irreversible',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.normal),
                            ),
                          ],
                        )
                      ],
                    ),
                  ).animate().slideY(
                      duration: 500.ms,
                      begin: 5,
                      end: 0,
                      curve: Curves.easeInOut),
                ),
                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        );
      },
      // resizeToAvoidBottomInset: true, // Ensure bottom sheet adjusts with keyboard
    );
  }

  late Future<List<dynamic>> _newsArticles;
  int _currentPage = 1;

  Future<void> _refreshNews() async {
    setState(() {
      _newsArticles =
          NewsService().fetchNews('farming agriculture', page: _currentPage++);
      _fetchUserDetails();
    });
  }

  Future<void> _launchURL(String url) async {
    final Uri _url = Uri.parse(url);
    try {
      if (await launchUrl(_url)) {
        throw Exception('Could not launch $_url');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: null,
      body: ResponsiveWrapper(
        child: SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: RefreshIndicator(
              onRefresh: _refreshNews,
              color: const Color(0xff399918),
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: _userData != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Hello ',
                                          style: GoogleFonts.amaranth(
                                            textStyle: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Text(
                                          _getFirstName(_userData!['fullName']),
                                          style: GoogleFonts.amaranth(
                                            textStyle: const TextStyle(
                                                fontSize: 20,
                                                color: Color(0xff399918),
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      _getFirstName(_userData!['role']),
                                      style: GoogleFonts.amaranth(
                                        textStyle: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xff399918),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _openBottomSheet();
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 235, 235, 235),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.network(
                                            _userData!['avatar'])),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _searchController,
                                    onChanged: _filterPasswords,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.search,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.all(18),
                                      hintText: 'What are you looking for ?',
                                      hintStyle: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontWeight: FontWeight.w300),
                                      labelStyle:
                                          const TextStyle(color: Colors.grey),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade500),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade100,
                                    ),
                                  ),
                                ),
                                _searchController.text.isNotEmpty
                                    ? const SizedBox(
                                        width: 10,
                                      )
                                    : Container(),
                                _searchController.text.isNotEmpty
                                    ? SizedBox(
                                        width: 60,
                                        height: 60,
                                        child: Button(
                                          onPressed: () {
                                            setState(() {
                                              _searchController.clear();
                                              _filterPasswords('');
                                              _selectedTag = '';
                                            });
                                          },
                                          child: const Icon(
                                            Icons.close,
                                            size: 18,
                                          ),
                                        ),
                                      ).animate().slideX(
                                        duration: 200.ms,
                                        begin: 1,
                                        end: 0,
                                        curve: Curves.easeInOut)
                                    : const SizedBox(
                                        width: 0,
                                        height: 0,
                                      ),
                              ],
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            const SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: BouncingScrollPhysics(),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  WeatherScreen(),
                                  SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Text(
                              "Latest news",
                              style: GoogleFonts.amaranth(
                                textStyle: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            FutureBuilder<List<dynamic>>(
                              future: _newsArticles,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xff399918),
                                      strokeWidth: 8,
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return const Center(
                                      child: Text('No news articles found.'));
                                }

                                final articles = snapshot.data!;

                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: articles.length,
                                  itemBuilder: (context, index) {
                                    final article = articles[index];

                                    return GestureDetector(
                                      onTap: () {
                                        final url = article['url'];
                                        if (url != null && url.isNotEmpty) {
                                          _launchURL(url);
                                        }
                                      },
                                      child: Card(
                                        elevation: 0,
                                        color: Colors.grey.shade100,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (article['urlToImage'] == null)
                                              Container(
                                                height: 250,
                                                width: double.infinity,
                                                decoration: const BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(20),
                                                    topRight:
                                                        Radius.circular(20),
                                                  ),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(20),
                                                    topRight:
                                                        Radius.circular(20),
                                                  ),
                                                  child: Image.network(
                                                    "https://img.freepik.com/free-photo/top-view-old-french-newspaper-pieces_23-2149318857.jpg?t=st=1725516131~exp=1725519731~hmac=ed0c244c517a2ead5439bc2bfe05c6436557927d21fd94398e1b2d44b91b3e82&w=996",
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return const Center(
                                                          child: Text(
                                                              'Image not available'));
                                                    },
                                                  ),
                                                ),
                                              ),
                                            if (article['urlToImage'] != null)
                                              Container(
                                                height: 250,
                                                width: double.infinity,
                                                decoration: const BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(20),
                                                    topRight:
                                                        Radius.circular(20),
                                                  ),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(20),
                                                    topRight:
                                                        Radius.circular(20),
                                                  ),
                                                  child: Image.network(
                                                    article['urlToImage'],
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return const Center(
                                                          child: Text(
                                                              'Image not available'));
                                                    },
                                                  ),
                                                ),
                                              ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Text(
                                                article['title'] ?? 'No Title',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10,
                                                  left: 10,
                                                  right: 10),
                                              child: Text(
                                                article['description'] ??
                                                    'No Description',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ).animate().slideY(
                                        duration: 500.ms,
                                        begin: 5,
                                        end: 0,
                                        curve: Curves.easeInOut);
                                  },
                                );
                              },
                            ),
                          ],
                        )
                      : SizedBox(
                          height: MediaQuery.of(context).size.height * 0.9,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xff399918),
                              strokeWidth: 8,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
