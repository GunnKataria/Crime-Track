import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crime_management_system/providers/auth_provider.dart';
import 'package:crime_management_system/screens/crime_list_screen.dart';
import 'package:crime_management_system/screens/report_crime_screen.dart';
import 'package:crime_management_system/screens/evidence_list_screen.dart';
import 'package:crime_management_system/screens/witness_list_screen.dart';
import 'package:crime_management_system/screens/suspect_list_screen.dart';
import 'package:crime_management_system/screens/crime_map_screen.dart';
import 'package:crime_management_system/screens/analytics_screen.dart';
import 'package:crime_management_system/screens/profile_screen.dart';
import 'package:crime_management_system/theme/theme_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final isOfficer = ref.read(authProvider.notifier).isOfficer;
    final themeMode = ref.watch(themeModeProvider);

    final screens = [
      const CrimeListScreen(),
      if (isOfficer) const EvidenceListScreen(),
      if (isOfficer) const WitnessListScreen(),
      if (isOfficer) const SuspectListScreen(),
      const CrimeMapScreen(),
      if (isOfficer) const AnalyticsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('CrimeTrack'),
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleThemeMode();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.name ?? ''),
              accountEmail: Text(user?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundImage: user?.imagePath != null
                    ? AssetImage(user!.imagePath!)
                    : const AssetImage('assets/images/default_avatar.png'),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Crime Cases'),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            if (isOfficer)
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Evidence'),
                selected: _selectedIndex == 1,
                onTap: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                  Navigator.pop(context);
                },
              ),
            if (isOfficer)
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Witnesses'),
                selected: _selectedIndex == 2,
                onTap: () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                  Navigator.pop(context);
                },
              ),
            if (isOfficer)
              ListTile(
                leading: const Icon(Icons.person_search),
                title: const Text('Suspects'),
                selected: _selectedIndex == 3,
                onTap: () {
                  setState(() {
                    _selectedIndex = 3;
                  });
                  Navigator.pop(context);
                },
              ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Crime Map'),
              selected: _selectedIndex == (isOfficer ? 4 : 1),
              onTap: () {
                setState(() {
                  _selectedIndex = isOfficer ? 4 : 1;
                });
                Navigator.pop(context);
              },
            ),
            if (isOfficer)
              ListTile(
                leading: const Icon(Icons.analytics),
                title: const Text('Analytics'),
                selected: _selectedIndex == 5,
                onTap: () {
                  setState(() {
                    _selectedIndex = 5;
                  });
                  Navigator.pop(context);
                },
              ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              selected: _selectedIndex == (isOfficer ? 6 : 2),
              onTap: () {
                setState(() {
                  _selectedIndex = isOfficer ? 6 : 2;
                });
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to help screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                ref.read(authProvider.notifier).logout();
              },
            ),
          ],
        ),
      ),
      body: screens[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReportCrimeScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
