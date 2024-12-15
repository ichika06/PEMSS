import 'package:card_loading/card_loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pemss/screens/navbar/screens/settings_screen/edit_profile/edit_profile.dart';
import '../../../../../../../darkmode.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();

  signout() async {
    await FirebaseAuth.instance.signOut();
  }

  void _showSignOutDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: AlertDialog(
                title: const Text('Confirm Sign Out'),
                content: const Text('Are you sure you want to sign out?'),
                actions: [
                  Center(
                    child: Column(
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            minimumSize: const Size(double.infinity, 36),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                        const Divider(
                          color: Colors.grey,
                          height: 0,
                        ),
                        TextButton(
                          onPressed: () {
                            signout();
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            textStyle: const TextStyle(color: Colors.red),
                            minimumSize: const Size(double.infinity, 36),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
  
  
}

void _showDeleteAccountDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: AlertDialog(
                title: const Text('Confirm Account Deletion'),
                content: const Text('Are you sure you want to delete your account? This action is permanent.'),
                actions: [
                  Center(
                    child: Column(
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            minimumSize: const Size(double.infinity, 36),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                        const Divider(
                          color: Colors.grey,
                          height: 0,
                        ),
                        TextButton(
                          onPressed: () {
                            _deleteAccount(context);
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            textStyle: const TextStyle(color: Colors.red),
                            minimumSize: const Size(double.infinity, 36),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your account has been deleted.')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting account: $e')),
      );
    }
  }

Future<String?> _getUserName() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = userDoc.data();
    return data != null ? '${data['firstName']} ${data['lastName']}' : null;
  }
  return null;
}
Future<String?> _getUserProfile() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = userDoc.data();
    return data != null ? data['profileUrl'] as String? : null;
  }
  return null;
}
Future<String?> _getUserStudentId() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = userDoc.data();
    return data != null ? data['Student_id'] as String? : null;
  }
  return null;
}

class _SettingsPageState extends State<SettingsPage> {
  final themeManager = ThemeManager();
  bool isDarkMode = ThemeManager().isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
        FutureBuilder<List<String?>>(
          future: Future.wait([_getUserName(), _getUserProfile(), _getUserStudentId()]),
          key: UniqueKey(),
          builder: (context, AsyncSnapshot<List<String?>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CardLoading(
              height: 130,
              borderRadius: BorderRadius.all(Radius.circular(23)),
              margin: EdgeInsets.only(bottom: 23),
            ),
          );
            } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
          final userName = snapshot.data![0] ?? 'Unknown User';
          final profileUrl = snapshot.data![1] ?? 'https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/b7489cf6-f701-4e8e-a6e7-08c8924ef45b/df4fq0s-cf1529a2-b189-4129-b135-e53a0bd92961.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcL2I3NDg5Y2Y2LWY3MDEtNGU4ZS1hNmU3LTA4Yzg5MjRlZjQ1YlwvZGY0ZnEwcy1jZjE1MjlhMi1iMTg5LTQxMjktYjEzNS1lNTNhMGJkOTI5NjEucG5nIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.3TlruYum7QR8FgFBQ9mJZBwPppu5nT3Cv84pCaQ3V4k';
          final studentId = snapshot.data![2] ?? 'No ID';
          return SizedBox(
            height: 130,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(23),
              ),
              color: Colors.purple,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      color: const Color.fromARGB(80, 255, 255, 255),
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                      child: Container(
                        width: 90,
                        height: 90,
                        padding: const EdgeInsets.all(10),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(profileUrl),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                     Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Text(
                           userName,
                           style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                           ),
                         ),
                        Text(
                          'Student ID: $studentId',
                           style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                           ),
                         ),
                         GestureDetector(
                          child: const Row(
                            children: [
                              Text(
                                'Edit Profile ',
                                style: TextStyle(
                                  color: Colors.white,
                                    fontSize: 13,
                                ),
                              ),
                              Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 13,
                              ),
                            ],
                           ),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                 builder: (context) =>
                                    const EditProfileScreen(),
                              ),
                            );
                             setState(() {});
                          },
                         ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
            } else {
          return const Text('No user data available.');
            }
          },
        ),
        
        Card(
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(23),
          ),
          elevation: 0,
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Column(
            children: [
          ListTile(
            leading: Icon(LucideIcons.penTool, color: Colors.indigo[400]),
            title: const Text('Appearance'),
            subtitle: const Text("Change the look of the app"),
            onTap: () {},
          ),
          const Divider(
            color: Colors.grey,
            height: 0,
          ),
          SwitchListTile(
            title: const Text('Dark mode'),
            subtitle: const Text("Automatic"),
            value: themeManager.isDarkMode,
            onChanged: (value) {
              setState(() {
            isDarkMode = value;
              });
              themeManager.toggleTheme();
            },
            secondary: const Icon(Icons.dark_mode_rounded, color: Colors.red),
          ),
            ],
          ),
        ),
        Card(
          clipBehavior: Clip.hardEdge,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(23),
          ),
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: ListTile(

            leading: const Icon(Icons.info_rounded, color: Colors.purple),
            title: const Text('About'),
            subtitle: const Text("Learn more about PEMSS"),
            onTap: () async {
                final Uri url = Uri.parse('https://nextgenpemss.me');
                if(await canLaunchUrl(url)){
                  await launchUrl(url);
                }else {
                  throw 'Could not launch $url';
                }
              },
          ),
        ),
        Card(
          clipBehavior: Clip.hardEdge,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(23),
          ),
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Column(
            children: [
              ListTile( 
                leading: const Icon(LucideIcons.logOut),
                title: const Text("Sign Out"),
                onTap: () {
                  widget._showSignOutDialog(context);
                },
              ),
              const Divider(
                color: Colors.grey,
                height: 0,
              ),
              ListTile(
                leading: const Icon(LucideIcons.badgeX, color: Colors.red),
                title: const Text(
                  "Delete account",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  _showDeleteAccountDialog(context);
                },
              ),
            ],
          ),
        ),
          ],
        ),
      ),
    );
  }
}
