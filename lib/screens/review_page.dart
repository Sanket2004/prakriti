import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prakriti/components/button.dart';
import 'package:prakriti/responsive/responsive.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final TextEditingController _reviewController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _existingReview;
  double? _existingRating;
  double _newRating = 3.0; // Default rating
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchExistingReview();
  }

  // Fetch the user's existing review and rating from Firestore
  Future<void> _fetchExistingReview() async {
    String uid = _auth.currentUser!.uid;
    DocumentSnapshot userReview =
        await _firestore.collection('reviews').doc(uid).get();

    if (userReview.exists) {
      setState(() {
        _existingReview = userReview['review'];
        _existingRating = userReview['rating'];
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  // Submit the review and rating to Firestore
  Future<void> _submitReview() async {
    setState(() {
      _isLoading = true;
    });
    String uid = _auth.currentUser!.uid;
    String review = _reviewController.text;

    await _firestore.collection('reviews').doc(uid).set({
      'uid': uid,
      'review': review,
      'rating': _newRating,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _existingReview = review;
      _existingRating = _newRating;
      _isLoading = false;
    });
  }

  // Delete the existing review
  Future<void> _deleteReview() async {
    String uid = _auth.currentUser!.uid;

    await _firestore.collection('reviews').doc(uid).delete();

    setState(() {
      _existingReview = null;
      _existingRating = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Submit Your Review',
          style: GoogleFonts.amaranth(
            textStyle:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveWrapper(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_existingReview != null && _existingRating != null)
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              const Center(
                                child: Text(
                                  'Thank you !',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Center(
                                child: Text(
                                  'Your feedback is valuable in helping us better understand your needs and tailor our service accordingly.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  _getEmojiForRating(_existingRating!),
                                  key: ValueKey(_existingRating),
                                  style: const TextStyle(fontSize: 50),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Center(
                                child: RatingBarIndicator(
                                  rating: _existingRating!,
                                  itemBuilder: (context, index) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  itemCount: 5,
                                  itemSize: 50.0,
                                  direction: Axis.horizontal,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _existingReview!,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Button(
                                  onPressed: _deleteReview,
                                  child: const Text('Delete Review'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(
                        height: 30,
                      ),
                      if (_existingReview == null && _existingRating == null)
                        Column(
                          children: [
                            const Center(
                              child: Text(
                                'How are you feeling ?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Center(
                              child: Text(
                                'Your input is valuable in helping us better understand your needs and tailor our service accordingly.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Center(
                              child: RatingBar.builder(
                                initialRating: _newRating,
                                minRating: 1,
                                glow: false,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemSize: 40, // Larger stars
                                itemPadding:
                                    const EdgeInsets.symmetric(horizontal: 6.0),
                                itemBuilder: (context, index) => Icon(
                                  Icons.star,
                                  color: _newRating >= (index + 1)
                                      ? Colors.green
                                      : Colors
                                          .grey, // Dynamic color based on rating
                                ),
                                onRatingUpdate: (rating) {
                                  setState(() {
                                    _newRating = rating;
                                  });
                                },
                                unratedColor: Colors.grey[300],
                                updateOnDrag: true,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (Widget child,
                                    Animation<double> animation) {
                                  return ScaleTransition(
                                      scale: animation, child: child);
                                },
                                child: Text(
                                  _getEmojiForRating(_newRating),
                                  key: ValueKey(_newRating),
                                  style: const TextStyle(fontSize: 50),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _reviewController,
                              maxLines: 4,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(20),
                                labelText: 'Enter your review here...',
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
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Button(
                                onPressed: _submitReview,
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Submit Review'),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // Helper function to display emojis based on the rating
  String _getEmojiForRating(double rating) {
    if (rating >= 4.5) {
      return '😄'; // Very happy
    } else if (rating >= 3.5) {
      return '😊'; // Happy
    } else if (rating >= 2.5) {
      return '😐'; // Neutral
    } else if (rating >= 1.5) {
      return '😕'; // Slightly unhappy
    } else {
      return '😢'; // Sad
    }
  }
}
