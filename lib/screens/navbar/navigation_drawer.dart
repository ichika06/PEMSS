import 'package:card_loading/card_loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pemss/screens/homepage.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pemss/screens/navbar/screens/event_manage/events_screen.dart';
import 'screens/nfcpage.dart';
import 'screens/settings_screen/settings_screen.dart';

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({super.key});


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


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  child: FutureBuilder<List<String?>>(
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
                            clipBehavior: Clip.hardEdge,
                            color: Colors.purple,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Card(
                                    clipBehavior: Clip.hardEdge,
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
                                  const SizedBox(width: 3),
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
                ),
                ListTile(
                  leading: const Icon(
                    LucideIcons.home,
                    color: Colors.grey,
                  ),
                  title: const Text('Home'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const Homepage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.nfc_outlined,
                    color: Colors.grey,
                  ),
                  title: const Text('Go to NFC Page'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NFCPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    LucideIcons.calendarHeart,
                    color: Colors.grey,
                  ),
                  title: const Text('Events'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const EventsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const Divider(
            color: Colors.grey,
            height: 0,
          ),
          ListTile(
            leading: const Icon(
              LucideIcons.userCog,
              color: Colors.grey,
            ),
            title: const Text('Settings'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
            textColor: Colors.deepOrangeAccent[400],
          ),
        ],
      ),
    );
  }
}
