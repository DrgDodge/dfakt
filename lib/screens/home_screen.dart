import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'reminders_screen.dart';
import 'fitness_screen.dart';
import 'statistics_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<Widget> _pages = <Widget>[
    DashboardScreen(),
    RemindersScreen(),
    FitnessScreen(),
    StatisticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 640) {
          // Mobile Layout
          return Scaffold(
            body: IndexedStack(
              index: provider.activeTab,
              children: _pages,
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.list_alt_rounded),
                  label: 'Calendar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.fitness_center_rounded),
                  label: 'Fitness',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart_rounded),
                  label: 'Stats',
                ),
              ],
              currentIndex: provider.activeTab,
              selectedItemColor: const Color(0xFF80CBC4),
              onTap: (index) => provider.setActiveTab(index),
            ),
          );
        } else {
          // Desktop / Tablet Layout
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  extended: constraints.maxWidth >= 900,
                  backgroundColor: const Color(0xFF1E1E1E),
                  selectedIndex: provider.activeTab,
                  onDestinationSelected: (index) => provider.setActiveTab(index),
                  selectedIconTheme: const IconThemeData(color: Color(0xFF80CBC4)),
                  unselectedIconTheme: const IconThemeData(color: Colors.grey),
                  selectedLabelTextStyle: const TextStyle(color: Color(0xFF80CBC4)),
                  unselectedLabelTextStyle: const TextStyle(color: Colors.grey),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_rounded),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.list_alt_rounded),
                      label: Text('Calendar'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.fitness_center_rounded),
                      label: Text('Fitness'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.bar_chart_rounded),
                      label: Text('Stats'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1, color: Colors.grey),
                Expanded(
                  child: IndexedStack(
                    index: provider.activeTab,
                    children: _pages,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
