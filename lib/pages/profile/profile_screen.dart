import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../../viewmodels/auth_viewmodel.dart'; // Import AuthViewModel

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Method to show the logout confirmation dialog
  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('End Session'), // Title matching design
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Are you sure you want to log out?',
                ), // Message matching design
              ],
            ),
          ),
          actions: <Widget>[
            // Cancel button matching design
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            // Yes, End Session button matching design
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3ACBAB), // Button color
                foregroundColor: Colors.white, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ), // Rounded corners
              ),
              child: const Text('Yes, End Session'),
              onPressed: () async {
                Navigator.of(context).pop(); // Dismiss the dialog first
                // Perform logout
                await context.read<AuthViewModel>().signOut();
                // Navigation after logout will be handled by AuthGate
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Placeholder user data (replace with actual user data later)
    const String userName = 'John Smith';
    const String userId = 'ID: 25030024';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'), // Updated AppBar title
        backgroundColor: const Color(0xFF3ACBAB), // Consistent AppBar color
        automaticallyImplyLeading: false, // Hide back button on main screens
      ),
      body: ListView(
        padding: const EdgeInsets.all(16), // Consistent padding
        children: <Widget>[
          // User Info Section
          Card(
            elevation: 4, // Subtle shadow
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ), // Rounded corners
            child: Padding(
              padding: const EdgeInsets.all(16), // Padding inside card
              child: Row(
                children: [
                  // User icon and text
                  CircleAvatar(
                    radius: 30, // Adjust size
                    backgroundColor: const Color(
                      0xFF3ACBAB,
                    ), // Icon background color
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ), // User icon
                  ),
                  const SizedBox(width: 16), // Spacing
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User name and ID
                      Text(
                        userName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4), // Spacing
                      Text(
                        userId,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24), // Spacing
          // Profile Options List
          Card(
            elevation: 4, // Subtle shadow
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ), // Rounded corners
            child: Column(
              children: [
                // List of options
                ListTile(
                  leading: Icon(
                    Icons.edit,
                    color: const Color(0xFF3ACBAB),
                  ), // Icon
                  title: const Text('Edit Profile'), // Label
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ), // Arrow icon
                  onTap: () {
                    // TODO: Navigate to Edit Profile Screen
                  },
                ),
                const Divider(indent: 16, endIndent: 16), // Divider
                ListTile(
                  leading: Icon(
                    Icons.settings,
                    color: const Color(0xFF3ACBAB),
                  ), // Icon
                  title: const Text('Setting'), // Label
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ), // Arrow icon
                  onTap: () {
                    // TODO: Navigate to Setting Screen
                  },
                ),
                const Divider(indent: 16, endIndent: 16), // Divider
                ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: Colors.redAccent,
                  ), // Logout icon color
                  title: const Text('Logout'), // Label
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ), // Arrow icon
                  onTap: () {
                    _showLogoutConfirmationDialog(
                      context,
                    ); // Show logout confirmation
                  },
                ),
                const Divider(indent: 16, endIndent: 16), // Divider
                ListTile(
                  leading: Icon(
                    Icons.help_outline,
                    color: const Color(0xFF3ACBAB),
                  ), // Icon
                  title: const Text('Help'), // Label
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ), // Arrow icon
                  onTap: () {
                    // TODO: Navigate to Help Screen or show help info
                  },
                ),
              ],
            ),
          ),
          // TODO: Add more sections like app version, etc. if needed
        ],
      ),
    );
  }
}
