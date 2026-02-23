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

  bool _isRailExtended = true;

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
                _CustomSidebar(
                  selectedIndex: provider.activeTab,
                  isExtended: _isRailExtended,
                  onDestinationSelected: (index) => provider.setActiveTab(index),
                  onToggle: () => setState(() => _isRailExtended = !_isRailExtended),
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

class _CustomSidebar extends StatelessWidget {
  final int selectedIndex;
  final bool isExtended;
  final Function(int) onDestinationSelected;
  final VoidCallback onToggle;

  const _CustomSidebar({
    required this.selectedIndex,
    required this.isExtended,
    required this.onDestinationSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isExtended ? 250 : 72,
      color: const Color(0xFF1E1E1E),
      child: Stack(
        children: [
          Column(
            children: [
              _buildMenuItem(0, Icons.home_rounded, 'Home'),
              _buildMenuItem(1, Icons.list_alt_rounded, 'Calendar'),
              _buildMenuItem(2, Icons.fitness_center_rounded, 'Fitness'),
              _buildMenuItem(3, Icons.bar_chart_rounded, 'Stats'),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 24,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: Icon(
                    isExtended ? Icons.chevron_left : Icons.chevron_right,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String label) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: Material(
        color: isSelected ? const Color(0xFF80CBC4).withOpacity(0.1) : Colors.transparent,
        child: InkWell(
          onTap: () => onDestinationSelected(index),
          child: isExtended 
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: isSelected ? const Color(0xFF80CBC4) : Colors.grey, size: 28),
                  const SizedBox(width: 16),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF80CBC4) : Colors.grey,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 18,
                    ),
                  )
                ],
              )
            : Center(
                child: Icon(icon, color: isSelected ? const Color(0xFF80CBC4) : Colors.grey, size: 28),
              ),
        ),
      ),
    );
  }
}
