import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'buttons.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late User user;
  late String username;
  late String firstName;
  late String lastName;
  late DateTime dob;

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
      firstName = userData['firstName'];
      lastName = userData['lastName'];
      dob = userData['dob'].toDate();
    });
  }

  void handleLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  void handleChangeLoginInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String currentPassword = '';
        String newPassword = '';

        return AlertDialog(
          title: const Text('Change Login Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration:
                    const InputDecoration(labelText: 'Current Password'),
                obscureText: true,
                onChanged: (value) {
                  currentPassword = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true,
                onChanged: (value) {
                  newPassword = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  AuthCredential credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: currentPassword,
                  );
                  await user.reauthenticateWithCredential(credential);
                  await user.updatePassword(newPassword);
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                } catch (e) {
                  if (kDebugMode) {
                    print(e.toString());
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void handleUpdatePersonalInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Personal Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'New First Name'),
                onChanged: (value) {
                  setState(() {
                    firstName = value;
                  });
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'New Last Name'),
                onChanged: (value) {
                  setState(() {
                    lastName = value;
                  });
                },
              ),
              TextField(
                decoration: const InputDecoration(
                    labelText: 'New Date of Birth (YYYY-MM-DD)'),
                onChanged: (value) {
                  setState(() {
                    dob = DateTime.tryParse(value) ?? dob;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('credentials')
                    .doc(user.uid)
                    .update({
                  'firstName': firstName,
                  'lastName': lastName,
                  'dob': dob,
                });
                // ignore: use_build_context_synchronously
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => handleLogout(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xffe46498),
              child: Icon(
                Icons.settings,
                size: 50,
                color: Color(0xfff8e5aa),
              ),
            ),
            const SizedBox(height: 20),
            MyButton(
              onTap: handleChangeLoginInfo,
              text: 'Change Password',
            ),
            const SizedBox(height: 10),
            MyButton(
              onTap: handleUpdatePersonalInfo,
              text: 'Update Personal Info',
            ),
          ],
        ),
      ),
    );
  }
}
