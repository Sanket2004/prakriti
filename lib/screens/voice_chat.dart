import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prakriti/responsive/responsive.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceChatScreen extends StatefulWidget {
  const VoiceChatScreen({super.key});

  @override
  State<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen> {
  final Gemini gemini = Gemini.instance;
  User? _user;
  Map<String, dynamic>? _userData;
  ChatUser? currentUser; // Initialize as nullable
  ChatUser geminiUser = ChatUser(id: "1", firstName: "Prakriti");
  List<ChatMessage> messages = [];
  stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  bool _isInputActive = false; // New flag to manage chip visibility

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _initializeSpeechRecognizer();
  }

  Future<void> _fetchUserDetails() async {
    _user = FirebaseAuth.instance.currentUser;

    if (_user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _userData = userDoc.data() as Map<String, dynamic>?;
            currentUser = ChatUser(
              id: "0",
              firstName: _getFirstName(_userData!['fullName']),
              profileImage: _userData!['avatar'],
            );
          });
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

  String _getFirstName(String fullName) {
    List<String> nameParts = fullName.split(' ');
    return nameParts.isNotEmpty ? nameParts[0] : '';
  }

  Future<void> _initializeSpeechRecognizer() async {
    bool available = await _speechToText.initialize();
    if (!available) {
      print('Speech recognition not available');
    }
  }

  void _startListening() async {
    setState(() {
      _isListening = true;
      _isInputActive = true; // Set input active
    });
    _speechToText.listen(onResult: (result) {
      if (result.hasConfidenceRating && result.confidence > 0.5) {
        _sendMessage(ChatMessage(
          user: currentUser!,
          createdAt: DateTime.now(),
          text: result.recognizedWords,
        ));
        _speechToText.stop();
        setState(() {
          _isListening = false;
        });
      }
    });
  }

  void _stopListening() {
    _speechToText.stop();
    setState(() {
      _isListening = false;
      // _isInputActive = false; // Reset input active
    });
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });
    try {
      String question = chatMessage.text;
      List<Uint8List>? images;
      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [
          File(chatMessage.medias!.first.url).readAsBytesSync(),
        ];
      }
      gemini
          .streamGenerateContent(
        question,
        images: images,
      )
          .listen((event) {
        ChatMessage? lastMessage = messages.firstOrNull;
        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = messages.removeAt(0);
          String response = event.content?.parts?.fold(
                  "", (previous, current) => "$previous ${current.text}") ??
              "";
          lastMessage.text += response;
          setState(() {
            messages = [lastMessage!, ...messages];
          });
        } else {
          String response = event.content?.parts?.fold(
                  "", (previous, current) => "$previous ${current.text}") ??
              "";
          ChatMessage message = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: response,
          );
          setState(() {
            messages = [message, ...messages];
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void _sendMediaMessage() async {
    setState(() {
      _isInputActive = true;
    });
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (file != null) {
      ChatMessage chatMessage = ChatMessage(
        user: currentUser!,
        createdAt: DateTime.now(),
        text: "Describe this image",
        medias: [
          ChatMedia(
            url: file.path,
            fileName: "",
            type: MediaType.image,
          )
        ],
      );
      _sendMessage(chatMessage);
    }
  }

  void _handleSuggestion(String text) {
    _sendMessage(ChatMessage(
      user: currentUser!,
      createdAt: DateTime.now(),
      text: text,
    ));
    setState(() {
      _isInputActive = true; // Set input active when suggestion is sent
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Prakriti Assistant',
          style: GoogleFonts.amaranth(
            textStyle:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.keyboard_backspace_sharp,
              color: Colors.black,
            )),
      ),
      body: ResponsiveWrapper(
        child: SafeArea(
          child: currentUser == null
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xff399918),
                    strokeWidth: 8,
                  ),
                )
              : Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: DashChat(
                            messageListOptions: const MessageListOptions(
                              scrollPhysics: BouncingScrollPhysics(),
                              showDateSeparator: true,
                            ),
                            inputOptions: InputOptions(
                              trailing: [
                                IconButton(
                                  onPressed: _sendMediaMessage,
                                  icon: const HugeIcon(
                                    icon: HugeIcons.strokeRoundedImage01,
                                    color: Colors.black,
                                    size: 24.0,
                                  ),
                                ),
                                IconButton(
                                  onPressed: _isListening
                                      ? _stopListening
                                      : _startListening,
                                  icon: Icon(
                                    _isListening
                                        ? HugeIcons.strokeRoundedStop
                                        : HugeIcons.strokeRoundedMic01,
                                    color: Colors.green,
                                  ),
                                )
                              ],
                            ),
                            currentUser: currentUser!,
                            onSend: (message) {
                              _sendMessage(message);
                              setState(() {
                                _isInputActive =
                                    true; // Set input active when sending a message
                              });
                            },
                            messages: messages,
                            scrollToBottomOptions:
                                const ScrollToBottomOptions(),
                            messageOptions: const MessageOptions(
                              showCurrentUserAvatar: true,
                              borderRadius: 25,
                              currentUserContainerColor: Color(0xff399918),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!_isInputActive) // Conditionally show chips at the center
                      Positioned.fill(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'প্রकृtiii', // Centered title text
                                  style: TextStyle(
                                    fontSize: 40,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "An AI based farmer assistant for all you need.",
                                  style: GoogleFonts.amaranth(
                                    textStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _suggestionChip(
                                              "How do I improve soil health?")
                                          .animate()
                                          .slideX(
                                              duration: 500.ms,
                                              begin: 1,
                                              end: 0,
                                              curve: Curves.easeInOut),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      _suggestionChip(
                                              "How can I manage pests effectively?")
                                          .animate()
                                          .slideX(
                                              duration: 500.ms,
                                              begin: 2,
                                              end: 0,
                                              curve: Curves.easeInOut),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      _suggestionChip(
                                              "Tell me about organic farming methods")
                                          .animate()
                                          .slideX(
                                              duration: 500.ms,
                                              begin: 3,
                                              end: 0,
                                              curve: Curves.easeInOut),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      _suggestionChip(
                                              "How do I apply for a farming loan?")
                                          .animate()
                                          .slideX(
                                              duration: 500.ms,
                                              begin: 4,
                                              end: 0,
                                              curve: Curves.easeInOut),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      _suggestionChip(
                                              "What is the best crop for winter season?")
                                          .animate()
                                          .slideX(
                                              duration: 500.ms,
                                              begin: 5,
                                              end: 0,
                                              curve: Curves.easeInOut),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _suggestionChip(String label) {
    return GestureDetector(
      onTap: () {
        _handleSuggestion(label);
        setState(() {
          _isInputActive =
              true; // Set input active when a suggestion is selected
        });
      },
      child: Material(
        color: Colors
            .transparent, // Makes sure background color is applied correctly
        child: InkWell(
          borderRadius: BorderRadius.circular(10), // Matches chip radius
          onTap: () {
            _handleSuggestion(label);
            setState(() {
              _isInputActive = true;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xff399918),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
