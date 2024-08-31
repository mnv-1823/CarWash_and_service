import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carwash_and_service/screens/otp_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? phoneNumber;
  const LoginScreen({super.key, this.phoneNumber});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

final List<String> imagePath = [
  "lib/images/onboarding1.png",
  "lib/images/onboarding2.png",
  "lib/images/onboarding3.png"
];

final List<String> imageTexts = [
  "Dedicated Service Team",
  "Seamless User Experience",
  "Fast and Reliable Delivery"
];

class _LoginScreenState extends State<LoginScreen> {
  final PageController _pageController = PageController();
  late TextEditingController _phoneController;
  int _currentPage = 0;
  Timer? _timer;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    _phoneController = TextEditingController(
        text: widget.phoneNumber ??
            ""); // Initialize with the passed phone number
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      if (_currentPage < imagePath.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0; // Loop back to the first page
      }

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
      );
    });
  }

  void _showErrorSnackbar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _validateAndProceed() async {
    String phoneNumber = _phoneController.text.trim();
    if (phoneNumber.length != 10 ||
        !RegExp(r'^[0-9]+$').hasMatch(phoneNumber)) {
      _showErrorSnackbar("Please enter a valid 10-digit phone number.");
      return;
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: '+91$phoneNumber',
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval or instant verification completed
        await _auth.signInWithCredential(credential);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              phoneNumber: phoneNumber,
              verificationId: credential.verificationId!,
            ),
          ),
        );
      },
      verificationFailed: (FirebaseAuthException e) {
        _showErrorSnackbar("Verification failed: ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              phoneNumber: phoneNumber,
              verificationId: verificationId,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Auto-retrieval timeout
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _phoneController.dispose();
    _timer?.cancel(); // Cancel the timer when the screen is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 250, // Adjust the height as needed
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: imagePath.length,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        imagePath[index],
                        fit: BoxFit.cover,
                        height: 200,
                      ),
                      const SizedBox(height: 4.0), // Reduced space
                      Text(
                        imageTexts[
                            index], // Display text based on the current index
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8.0), // Reduced space
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                imagePath.length,
                (index) => buildDot(index, context),
              ),
            ),
            const SizedBox(
                height: 16.0), // Adjusted space between dots and login text
            const Text(
              "Login via",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                          width: 4), // Space between the flag and the text
                      const Text(
                        "+91",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      labelText: 'Phone Number',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              height: 50.0,
              child: ElevatedButton(
                onPressed: _validateAndProceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text(
                  "Get OTP",
                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }

  Widget buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: 10,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index ? Colors.purple : Colors.grey,
      ),
    );
  }
}
