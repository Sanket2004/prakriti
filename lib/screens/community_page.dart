import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prakriti/components/button.dart';
import 'package:prakriti/responsive/responsive.dart';
import 'package:prakriti/screens/posts_list_screen.dart';

class CommunityPageScreen extends StatefulWidget {
  const CommunityPageScreen({super.key});

  @override
  State<CommunityPageScreen> createState() => _CommunityPageScreenState();
}

class _CommunityPageScreenState extends State<CommunityPageScreen> {
  final _textController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _postContent() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Post cannot be empty',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xffFF7777),
        ),
      );
      return;
    }

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please choose an image for your post',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xffFF7777),
        ),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      // Extract the file extension from the picked image file
      final fileExtension = _imageFile!.path.split('.').last;

      // Create a unique file path
      final filePath =
          'community_posts/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      // Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child(filePath);
      final uploadTask = storageRef.putFile(_imageFile!);
      final snapshot = await uploadTask.whenComplete(() {});
      final imageUrl = await snapshot.ref.getDownloadURL();

      // Get the current user's UID
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Handle the case where the user is not authenticated
        return;
      }
      final uid = user.uid;

      // Create a reference to the document so we can get its ID later
      final postRef =
          FirebaseFirestore.instance.collection('community_posts').doc();

      // Save post details to Firestore
      await postRef.set({
        'text': _textController.text,
        'imageUrl': imageUrl, // Save the image URL for displaying
        'imagePath': filePath, // Save the image path for deletion
        'uid': uid,
        'timestamp': FieldValue.serverTimestamp(),
        'post_id': postRef.id, // Store document ID
        'likes': [], // Initialize with an empty list
      });

      // Clear fields after posting
      _textController.clear();
      setState(() {
        _imageFile = null;
      });
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Failed to post content: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Add Post',
            style: GoogleFonts.amaranth(
              textStyle:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.keyboard_backspace_sharp,
              color: Colors.black,
            ),
          )),
      body: ResponsiveWrapper(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Share your thoughts with the community',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Color(0xff399918),
                  ),
                ),
                const SizedBox(height: 16),
                _imageFile != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: SizedBox(
                              width: double.infinity,
                              height: 300,
                              child: Image.file(
                                _imageFile!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: const HugeIcon(
                                icon: HugeIcons.strokeRoundedDelete02,
                                color: Colors.red,
                                size: 24.0,
                              ),
                              onPressed: () {
                                setState(() {
                                  _imageFile = null;
                                });
                              },
                            ),
                          ),
                        ],
                      )
                    : GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 300,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Center(
                                child: Text(
                                  'No image selected\nTap to select an image',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                            const Positioned(
                                top: 15,
                                right: 15,
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedImageAdd02,
                                  color: Colors.black,
                                  size: 24.0,
                                )),
                          ],
                        ),
                      ),
                const SizedBox(height: 16),
                TextField(
                  controller: _textController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(20),
                    labelText: 'Enter your post...',
                    labelStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: Colors.grey.shade500,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Button(
                    onPressed: _postContent,
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : const Text('Post'),
                  ),
                ),
                const SizedBox(
                    height:
                        16), // Add some space before the 'View Posts' button
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('View Posts',
                      style: TextStyle(color: Color(0xff399918))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
