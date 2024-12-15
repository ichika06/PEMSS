import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'screens/homepage.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final GlobalKey<FormState> _personalInfoKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _contactInfoKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _credentialsKey = GlobalKey<FormState>();

  Future<void> _signup() async {
    if (!_validateAllPages()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog('Passwords do not match');
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => const Homepage()),
      );
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.message ?? 'Signup failed');
    }
  }

  bool _validateAllPages() {
    if (!_personalInfoKey.currentState!.validate()) {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return false;
    }

    // Check contact info page
    if (!_contactInfoKey.currentState!.validate()) {
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return false;
    }

    // Check credentials page
    if (!_credentialsKey.currentState!.validate()) {
      _pageController.animateToPage(
        2,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return false;
    }

    return true;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  // Method to move to next page
  void _nextPage() {
    switch (_currentPage) {
      case 0:
        if (!_personalInfoKey.currentState!.validate()) return;
        break;
      case 1:
        if (!_contactInfoKey.currentState!.validate()) return;
        break;
      case 2:
        if (!_credentialsKey.currentState!.validate()) return;
        break;
    }

    // Move to next page if validation passes
    if (_currentPage < 3) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Method to move to previous page
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress Indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) => 
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index 
                      ? Theme.of(context).primaryColor 
                      : Colors.grey.shade300,
                  ),
                )
              ),
            ),
          ),
          
          // Page View
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                // Personal Info Page
                _buildPersonalInfoPage(context),
                
                // Contact Info Page
                _buildContactInfoPage(context),
                
                // Account Credentials Page
                _buildCredentialsPage(context),
                
                // Confirmation Page
                _buildConfirmationPage(context),
              ],
            ),
          ),

          // Navigation Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _currentPage > 0 
                  ? TextButton(
                      onPressed: _previousPage,
                      child: const Text('Back'),
                    )
                  : const SizedBox.shrink(),

                ElevatedButton(
                  onPressed: _currentPage < 3 ? _nextPage : _signup,
                  child: Text(_currentPage < 3 ? 'Next' : 'Signup'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Page 1: Personal Information
  Widget _buildPersonalInfoPage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _personalInfoKey,
        child: Column(
          children: [
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                // Optional: Add more sophisticated name validation
                if (value.length < 2) {
                  return 'Name must be at least 2 characters long';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter your full name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Page 2: Contact Information
   Widget _buildContactInfoPage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _contactInfoKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                if (!RegExp(r'^\d{10,11}$').hasMatch(value)) {
                  return 'Please enter a valid 10 or 11-digit phone number';
                }
                return null;
                },
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter your phone number',
                border: const OutlineInputBorder(),
                prefix: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'lib/assets/flags/ph.svg',
                      width: 27,
                      height: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '+63  ',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Page 3: Account Credentials
  Widget _buildCredentialsPage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _credentialsKey,
        child: Column(
          children: [
            Text(
              'Account Credentials',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters long';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Confirm your password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Page 4: Confirmation
  Widget _buildConfirmationPage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).primaryColor,
            size: 100,
          ),
          const SizedBox(height: 20),
          Text(
            'Review Your Information',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          Text('Name: ${_nameController.text}'),
          Text('Phone: ${_phoneController.text}'),
          Text('Email: ${_emailController.text}'),
        ],
      ),
    );
  }
}