import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'activity_list_screen.dart';
import 'registration_status_screen.dart';
import 'submit_report_screen.dart';
import 'profile_screen.dart';

class VolunteerMainScreen extends StatefulWidget {
  const VolunteerMainScreen({super.key});

  @override
  State<VolunteerMainScreen> createState() => _VolunteerMainScreenState();
}

class _VolunteerMainScreenState extends State<VolunteerMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ActivityListScreen(),
    RegistrationStatusScreen(),
    SubmitReportScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.primaryGreenLight,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.volunteer_activism_outlined),
            selectedIcon: Icon(Icons.volunteer_activism, color: AppTheme.primaryGreenDark),
            label: 'Hoạt động',
          ),
          NavigationDestination(
            icon: Icon(Icons.how_to_reg_outlined),
            selectedIcon: Icon(Icons.how_to_reg, color: AppTheme.primaryGreenDark),
            label: 'Đơn của tôi',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_turned_in_outlined),
            selectedIcon: Icon(Icons.assignment_turned_in, color: AppTheme.primaryGreenDark),
            label: 'Báo cáo',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppTheme.primaryGreenDark),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}
