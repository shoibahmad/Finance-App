import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_currentUser == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(_currentUser!.uid).get();
      if (mounted) {
        setState(() {
          _userData = doc.exists ? doc.data() as Map<String, dynamic>? : null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading profile: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _logout() async {
    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      await _auth.signOut();
      // Assuming AuthWrapper handles navigation to LoginScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile',
            style: TextStyle(
                color: theme.appBarTheme.foregroundColor ??
                    (ThemeData.estimateBrightnessForColor(primaryColor) == Brightness.dark
                        ? Colors.white
                        : Colors.black))),
        backgroundColor: primaryColor,
        elevation: 0.5,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
              ? Center(
                  child: Text(
                  'User not logged in.',
                  style: textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                ))
              : _userData == null && _currentUser != null
                ? Center( // Case where user is logged in but data fetch failed/no data in Firestore
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.grey.shade400, size: 60),
                          const SizedBox(height: 16),
                          Text(
                            'Could not load profile data.\nPlease try again.',
                            textAlign: TextAlign.center,
                            style: textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh, color: Colors.white),
                            label: const Text('Retry Load', style: TextStyle(color: Colors.white)),
                            onPressed: _loadUserData,
                            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                          )
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 40.0), // Added bottom padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor.withOpacity(0.8), primaryColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.white.withOpacity(0.9),
                              child: Icon(
                                Icons.person_rounded,
                                size: 60,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _userData?['name'] ?? 'Anonymous User',
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _currentUser?.email ?? 'No Email Available',
                              style: textTheme.titleSmall?.copyWith(
                                color: Colors.white.withOpacity(0.85),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 35),
                      Text(
                        'Account Information',
                        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: textTheme.bodyLarge?.color?.withOpacity(0.8)),
                      ),
                      const SizedBox(height: 15),
                      _buildProfileItem(Icons.perm_identity_outlined, 'User ID', _currentUser!.uid, theme),
                      _buildProfileItem(Icons.alternate_email_outlined, 'Email', _currentUser?.email ?? 'N/A', theme),
                      _buildProfileItem(Icons.badge_outlined, 'Name', _userData?['name'] ?? 'Not Set', theme),
                      _buildProfileItem(Icons.phone_android_outlined, 'Phone', _userData?['phoneNumber'] ?? 'Not Provided', theme),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.logout_rounded, color: Colors.white),
                        label: const Text('Logout', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent.shade400,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          minimumSize: const Size(180, 50),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 1.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        // side: BorderSide(color: theme.dividerColor.withOpacity(0.3))
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
        child: Row(
          children: [
            Icon(icon, color: theme.primaryColor, size: 24),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: theme.textTheme.titleSmall?.copyWith(
                       fontWeight: FontWeight.w600,
                       color: theme.textTheme.bodyLarge?.color?.withOpacity(0.9)
                    ),
                    maxLines: 3, // Allow more lines for long UIDs
                    overflow: TextOverflow.ellipsis,
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