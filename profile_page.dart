// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'buttons.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User user;
  late String username;
  late String role;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    fetchUserData();
  }

  void fetchUserData() async {
    DocumentSnapshot userData = await FirebaseFirestore.instance
        .collection('credentials')
        .doc(user.uid)
        .get();

    setState(() {
      username = userData['userId'];
      role = userData['role'];
    });
  }

  void handleUpdateUsername() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newUsername = username;

        return AlertDialog(
          title: const Text('Update Username'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'New Username'),
            onChanged: (value) {
              newUsername = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('credentials')
                    .doc(user.uid)
                    .update({'userId': newUsername});

                setState(() {
                  username = newUsername;
                });

                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void handleUpdateRole() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newRole = role;

        return AlertDialog(
          title: const Text('Update Role'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'New Role'),
            onChanged: (value) {
              newRole = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('credentials')
                    .doc(user.uid)
                    .update({'role': newRole});

                setState(() {
                  role = newRole;
                });

                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: const Color(0xffe46498),
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xffe46498),
              child: Icon(
                Icons.person,
                size: 50,
                color: Color(0xfff8e5aa),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Hello $username!",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            MyButton(
              onTap: handleUpdateUsername,
              text: 'Update Username',
            ),
            const SizedBox(height: 20),
            MyButton(
              onTap: handleUpdateRole,
              text: 'Change Role',
            ),
          ],
        ),
      ),
    );
  }
}
