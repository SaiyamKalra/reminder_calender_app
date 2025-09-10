import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:reminder_calender_app/config.dart';
import 'package:reminder_calender_app/settings/presentation/subpages/change_password_page.dart';
import 'package:reminder_calender_app/settings/presentation/subpages/change_username_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? username;
  String? email;
  File? selectedImage;
  String? avatarUrl; // 👈 Corrected: Declare avatarUrl here

  @override
  void initState() {
    super.initState();
    getUserNameAndSignIn();
  }

  Future<void> galleryImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (image != null) {
      final fileExtension = image.path.split('.').last.toLowerCase();
      if (fileExtension == 'jpg' ||
          fileExtension == 'jpeg' ||
          fileExtension == 'png') {
        setState(() {
          selectedImage = File(image.path);
        });
        // Corrected: await the upload process
        await avatarUrlEnter();
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: Unsupported file type. Please select a JPG or PNG image.',
            ),
          ),
        );
      }
    }
  }

  Future<void> cameraImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );
    if (image != null) {
      final fileExtension = image.path.split('.').last.toLowerCase();
      if (fileExtension == 'jpg' ||
          fileExtension == 'jpeg' ||
          fileExtension == 'png') {
        setState(() {
          selectedImage = File(image.path);
        });
        await avatarUrlEnter();
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: Unsupported file type. Please take a JPG or PNG image.',
            ),
          ),
        );
      }
    }
  }

  Future<void> avatarUrlEnter() async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected, please select one')),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email');
      final url = Uri.parse('$avatarUrlUpdate/$email');
      final request = http.MultipartRequest('PATCH', url);

      request.files.add(
        await http.MultipartFile.fromPath('avatar', selectedImage!.path),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        if (kDebugMode) {
          print("Avatar updated successfully");
        }
        setState(() {
          avatarUrl =
              data['user']['avatarUrl']; // 👈 Corrected: Update avatarUrl
        });
        // Re-fetch user data to ensure everything is in sync
        getUserNameAndSignIn();
      } else {
        if (kDebugMode) {
          print(
            "Server returned an error with status code: ${response.statusCode}",
          );
          print("Response body: $responseBody");
        }
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Avatar update failed. Please try again.')),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Network or other error occurred: $e');
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'An error occurred. Please check your network connection.',
          ),
        ),
      );
    }
  }

  Future<void> getUserNameAndSignIn() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null) {
      final url = Uri.parse('$getData/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (kDebugMode) {
          print('User data response: $data');
        }

        if (data["status"] == true) {
          final user = data["user"];
          await prefs.setString("userId", user["id"]);
          await prefs.setString("username", user["username"]);
          await prefs.setString("email", user["email"]);

          setState(() {
            username = user["username"];
            email = user["email"];
            avatarUrl =
                user["avatarUrl"]; // 👈 Corrected: Get avatarUrl from the server
          });

          if (kDebugMode) {
            print("Saved user: ${user["username"]} (${user["id"]})");
          }
        } else {
          if (kDebugMode) {
            print("Fetch failed: ${data["message"]}");
          }
        }
      } else {
        if (kDebugMode) {
          print("Server error: ${response.statusCode}");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 51, 51, 51),
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('Settings Page'),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 60),
            GestureDetector(
              onTap: () {
                modalBottomSheet(context);
              },
              child: CircleAvatar(
                radius: 90,
                // 👈 Corrected: Conditional display logic
                child: (avatarUrl != null && avatarUrl!.isNotEmpty)
                    ? ClipOval(
                        child: Image.network(
                          avatarUrl!,
                          fit: BoxFit.cover,
                          width: 180,
                          height: 180,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.person, size: 100);
                          },
                        ),
                      )
                    : (selectedImage != null)
                    ? ClipOval(
                        child: Image.file(
                          selectedImage!,
                          fit: BoxFit.cover,
                          width: 180,
                          height: 180,
                        ),
                      )
                    : Icon(Icons.person, size: 100),
              ),
            ),
            SizedBox(height: 20),
            Text(
              '$username',
              style: TextStyle(
                color: Colors.green[300],
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 0),
            Text(
              '$email',
              style: TextStyle(
                color: Colors.green[300],
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 35),
            settingsOptionsContainer('Change Username', Colors.white70, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChangeUsernamePage()),
              );
            }),
            settingsOptionsContainer('About the Developer', Colors.white70, () {
              aboutTheDeveloperPage(context);
            }),
            settingsOptionsContainer('Change Password', Colors.white70, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChangePasswordPage()),
              );
            }),
            settingsOptionsContainer('LogOut', Colors.red, () {
              logout(context);
            }),
          ],
        ),
      ),
    );
  }

  Future<void> modalBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      backgroundColor: Colors.grey[850],
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          height: 300,
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                textAlign: TextAlign.center,
                'Would you like to change your Profile Picture',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      cameraImage();
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 100,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.camera_alt),
                    ),
                  ),
                  SizedBox(width: 30),
                  GestureDetector(
                    onTap: () {
                      galleryImage();
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 100,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.browse_gallery),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> aboutTheDeveloperPage(BuildContext context) {
    return showModalBottomSheet(
      backgroundColor: Colors.grey[850],
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          height: 400,
          child: Column(
            children: [
              SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      'https://media.licdn.com/dms/image/v2/D4E03AQHFK2kLYhLxcA/profile-displayphoto-shrink_800_800/profile-displayphoto-shrink_800_800/0/1730543950779?e=1759363200&v=beta&t=vdAGLCoXu7iOg6gNGkXb2OQTnAn-E_DWPxarOGzZAZc',
                    ),
                  ),
                  SizedBox(width: 30),
                  Text(
                    'Saiyam Kalra',
                    style: TextStyle(color: Colors.white70, fontSize: 20),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () async {
                      final Uri linkedInUrl = Uri.parse(
                        'https://www.linkedin.com/in/saiyam-kalra-25a53432a/',
                      );
                      try {
                        await launchUrl(
                          linkedInUrl,
                          mode: LaunchMode.externalApplication,
                        );
                      } catch (e) {
                        if (kDebugMode) {
                          print('Could not launch $linkedInUrl: $e');
                        }
                      }
                    },
                    child: Container(
                      height: 50,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Color(0xFF0A66C2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.link),
                    ),
                  ),
                  SizedBox(width: 15),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'B.Tech student at VIT Vellore with a strong interest in technology, app development, and problem-solving. I specialize in building cross-platform mobile apps using Flutter and React Native (Expo), with hands-on experience in:',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    '1) RESTful API integration',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '2) State management (like BLoC)',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '3) Backend services using Supabase and Firebase',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '4) Real-time data visualization & charts',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget settingsOptionsContainer(
    String text,
    Color color,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 3),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(text, style: TextStyle(color: color, fontSize: 18)),
          ),
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    return;
  }
}
