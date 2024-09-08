import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:photo_view/photo_view.dart';
import 'package:prakriti/responsive/responsive.dart';
import 'package:prakriti/screens/community_page.dart'; // Adjust the import path if needed
import 'package:intl/intl.dart';

class PostsListScreen extends StatelessWidget {
  const PostsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Community Posts',
          style: GoogleFonts.amaranth(
            textStyle:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "add_post_btn",
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const CommunityPageScreen()));
        },
        backgroundColor: const Color(0xff399918),
        child: const HugeIcon(
          icon: HugeIcons.strokeRoundedImageAdd01,
          color: Colors.white,
          size: 24.0,
        ),
      ),
      body: ResponsiveWrapper(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('community_posts')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SizedBox(
                  width: 150,
                  child: LinearProgressIndicator(
                    minHeight: 5,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No posts available.'));
            }

            final posts = snapshot.data!.docs;

            return FutureBuilder<List<Map<String, dynamic>>>(
              future: Future.wait([
                ...posts.map((post) async {
                  final postData = post.data() as Map<String, dynamic>;
                  final userId = postData['uid'] as String?;
                  if (userId == null) {
                    return {
                      'post': postData,
                      'user': {},
                    };
                  }
                  final userDoc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .get();
                  final userData = userDoc.data() ?? {};
                  return {
                    'post': postData,
                    'user': userData,
                  };
                })
              ]),
              builder: (context, futureSnapshot) {
                if (futureSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(
                      width: 150,
                      child: LinearProgressIndicator(
                        minHeight: 5,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  );
                }

                if (futureSnapshot.hasError) {
                  return Center(child: Text('Error: ${futureSnapshot.error}'));
                }

                if (!futureSnapshot.hasData || futureSnapshot.data!.isEmpty) {
                  return const Center(child: Text('No posts available.'));
                }
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final data = futureSnapshot.data![index];
                    final post = data['post'] as Map<String, dynamic>;
                    final user = data['user'] as Map<String, dynamic>;

                    final uid = post['uid'] as String;
                    final text = post['text'] as String;
                    final imageUrl = post['imageUrl'] as String;
                    final postId = post['post_id'] as String;
                    // Check if 'timestamp' is null and handle it gracefully
                    final timestamp = post['timestamp'] != null
                        ? post['timestamp'] as Timestamp
                        : Timestamp
                            .now(); // Use the current time if timestamp is null

                    return PostItem(
                      uid: uid,
                      text: text,
                      imageUrl: imageUrl,
                      timestamp: timestamp,
                      post_id: postId,
                      userData: user,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class PostItem extends StatefulWidget {
  final String uid;
  final String text;
  final String imageUrl;
  final Timestamp timestamp;
  final String post_id;
  final Map<String, dynamic> userData;

  const PostItem({
    super.key,
    required this.uid,
    required this.text,
    required this.imageUrl,
    required this.timestamp,
    required this.post_id,
    required this.userData,
  });

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  bool _isLiked = false;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
    _getLikeCount();
  }

  Future<void> _checkIfLiked() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final postDoc = FirebaseFirestore.instance
          .collection('community_posts')
          .doc(widget.post_id);
      final postData = await postDoc.get();
      final data = postData.data() as Map<String, dynamic>;
      final likes = List<String>.from(data['likes'] ?? []);
      if (mounted) {
        setState(() {
          _isLiked = likes.contains(user.uid);
        });
      }
    }
  }

  Future<void> _getLikeCount() async {
    final postDoc = FirebaseFirestore.instance
        .collection('community_posts')
        .doc(widget.post_id);
    final postData = await postDoc.get();
    final data = postData.data() as Map<String, dynamic>;
    final likes = List<String>.from(data['likes'] ?? []);
    if (mounted) {
      setState(() {
        _likeCount = likes.length;
      });
    }
  }

  Future<void> _toggleLike() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final postDoc = FirebaseFirestore.instance
          .collection('community_posts')
          .doc(widget.post_id);

      // Transaction to update likes
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final postData = await transaction.get(postDoc);
        final data = postData.data() as Map<String, dynamic>;
        final likes = List<String>.from(data['likes'] ?? []);

        if (_isLiked) {
          likes.remove(user.uid);
        } else {
          likes.add(user.uid);
        }

        transaction.update(postDoc, {'likes': likes});
      });

      setState(() {
        _isLiked = !_isLiked;
        _likeCount = _isLiked ? _likeCount + 1 : _likeCount - 1;
      });
    }
  }

  Future<void> _deletePost() async {
    try {
      // Retrieve the image path from Firestore
      final docSnapshot = await FirebaseFirestore.instance
          .collection('community_posts')
          .doc(widget.post_id)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final imagePath = data['imagePath'] as String?;

        if (imagePath != null) {
          print('Deleting file at path: $imagePath');

          // Delete the image from Firebase Storage
          final storageRef = FirebaseStorage.instance.ref().child(imagePath);
          await storageRef.delete();
        }
      }

      // Delete the post from Firestore
      await FirebaseFirestore.instance
          .collection('community_posts')
          .doc(widget.post_id)
          .delete();
    } catch (e) {
      print('Error deleting post or image: $e');
    }
  }

  Future<void> _showDeleteConfirmationDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text(
              'Are you sure you want to delete this post? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _deletePost(); // Perform the deletion
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showImageViewer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewScreen(
          imageUrl: widget.imageUrl,
          postId: widget.post_id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!.uid;
    final fullName = widget.userData['fullName'] as String? ?? 'Unknown User';
    final avatarUrl = widget.userData['avatar'] as String? ?? '';

    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : const AssetImage(
                              'https://api.dicebear.com/9.x/dylan/svg')
                          as ImageProvider,
                  radius: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM d, yyyy • h:mm a')
                            .format(widget.timestamp.toDate()),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Show delete button if the current user is the author of the post
                if (currentUser == widget.uid)
                  IconButton(
                    icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedDelete02,
                      color: Colors.red,
                      size: 24.0,
                    ),
                    onPressed: _showDeleteConfirmationDialog,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              widget.text,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            widget.imageUrl.isNotEmpty
                ? GestureDetector(
                    onTap: _showImageViewer,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        widget.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : const SizedBox.shrink(), // Hide if there's no image
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.eco : Icons.eco_outlined,
                    color: _isLiked ? Colors.green : Colors.grey,
                  ),
                  onPressed: _toggleLike,
                ),
                Text('$_likeCount likes'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PhotoViewScreen extends StatelessWidget {
  final String imageUrl;
  final String postId;

  const PhotoViewScreen({
    super.key,
    required this.imageUrl,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // PhotoView for image zooming and panning
          PhotoView(
            imageProvider: NetworkImage(imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          ),

          // Transparent back button
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.keyboard_backspace_outlined,
                  color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),

          // Post details and creator information
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('community_posts')
                  .doc(postId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    color: Colors.black.withOpacity(0.8),
                    padding: const EdgeInsets.all(16),
                    child: const Center(
                      child: LinearProgressIndicator(
                        minHeight: 5,
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    color: Colors.black.withOpacity(0.8),
                    padding: const EdgeInsets.all(16),
                    child: const Center(
                      child: Text(
                        'Error loading post details',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Container(
                    color: Colors.black.withOpacity(0.8),
                    padding: const EdgeInsets.all(16),
                    child: const Center(
                      child: Text(
                        'Post not found',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }

                final postData = snapshot.data!.data() as Map<String, dynamic>;
                final postText = postData['text'] as String? ?? 'No text';
                final postCreatorId = postData['uid'] as String? ?? '';

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(postCreatorId)
                      .get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Container(
                        color: Colors.black.withOpacity(0.8),
                        padding: const EdgeInsets.all(16),
                        child: const Center(
                          child: LinearProgressIndicator(
                            minHeight: 5,
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      );
                    }

                    if (userSnapshot.hasError) {
                      return Container(
                        color: Colors.black.withOpacity(0.8),
                        padding: const EdgeInsets.all(16),
                        child: const Center(
                          child: Text(
                            'Error loading creator details',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }

                    if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                      return Container(
                        color: Colors.black.withOpacity(0.8),
                        padding: const EdgeInsets.all(16),
                        child: const Center(
                          child: Text(
                            'Creator not found',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }

                    final creatorData =
                        userSnapshot.data!.data() as Map<String, dynamic>;
                    final creatorName =
                        creatorData['fullName'] as String? ?? 'Unknown';

                    return Container(
                      padding: const EdgeInsets.only(
                          top: 16, bottom: 30, left: 16, right: 16),
                      color: Colors.black.withOpacity(0.5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            creatorName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            postText,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
