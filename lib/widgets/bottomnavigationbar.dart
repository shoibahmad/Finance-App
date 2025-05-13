import 'package:flutter/material.dart';
import 'package:managment/screens/add.dart'; // Ensure this path is correct
import 'package:managment/screens/home.dart'; // Ensure this path is correct
import 'package:managment/screens/statistics.dart'; // Ensure this path is correct and Statistics screen exists
import 'package:managment/screens/wallet_screen.dart'; // Ensure this path is correct
import 'package:managment/screens/profile_screen.dart'; // Ensure this path is correct

class Bottom extends StatefulWidget {
  const Bottom({Key? key}) : super(key: key);

  @override
  State<Bottom> createState() => _BottomState();
}

class _BottomState extends State<Bottom> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const Home(),
    const Statistics(), // Make sure this screen is implemented
    const WalletScreen(),
    const ProfileScreen(),
  ];

  final List<String> _screenLabels = [
    'Home',
    'Stats',
    'Wallet',
    'Profile',
  ];

  // Define your icons - use consistent styling (e.g., all outlined or all rounded)
  final List<IconData> _screenIcons = [
    Icons.home_rounded,
    Icons.bar_chart_rounded, // Or Icons.insert_chart_outlined_rounded
    Icons.account_balance_wallet_outlined,
    Icons.person_outline_rounded,
  ];

  // Define selected state icons (can be same as _screenIcons if no distinct selected version)
  final List<IconData> _screenSelectedIcons = [
    Icons.home_rounded, // Or Icons.home_filled if you prefer
    Icons.bar_chart_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final unselectedColor = theme.textTheme.bodySmall?.color?.withOpacity(0.6) ?? Colors.grey.shade500;

    return Scaffold(
      body: IndexedStack( // Use IndexedStack to preserve state of screens
        index: _selectedIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => const Add_Screen()));
        },
        backgroundColor: primaryColor,
        foregroundColor: Colors.white, // Icon color for FAB
        elevation: 4.0, // Standard elevation for FAB
        shape: const CircleBorder(), // Ensures it's perfectly circular
        child: const Icon(Icons.add_rounded, size: 30),
        tooltip: 'Add Transaction',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0, // How much the FAB indents into the BottomAppBar
        elevation: 8.0, // Shadow for the BottomAppBar
        color: theme.bottomAppBarTheme.color ?? theme.canvasColor,
        child: SizedBox(
          height: 65, // Standard height for BottomNavigationBar with labels
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround, // Distribute space
            children: <Widget>[
              _buildNavItem(
                isSelected: _selectedIndex == 0,
                icon: _screenIcons[0],
                selectedIcon: _screenSelectedIcons[0],
                label: _screenLabels[0],
                selectedColor: primaryColor,
                unselectedColor: unselectedColor,
                onTap: () => setState(() => _selectedIndex = 0),
              ),
              _buildNavItem(
                isSelected: _selectedIndex == 1,
                icon: _screenIcons[1],
                selectedIcon: _screenSelectedIcons[1],
                label: _screenLabels[1],
                selectedColor: primaryColor,
                unselectedColor: unselectedColor,
                onTap: () => setState(() => _selectedIndex = 1),
              ),
              const SizedBox(width: 40), // Spacer for the FAB
              _buildNavItem(
                isSelected: _selectedIndex == 2,
                icon: _screenIcons[2],
                selectedIcon: _screenSelectedIcons[2],
                label: _screenLabels[2],
                selectedColor: primaryColor,
                unselectedColor: unselectedColor,
                onTap: () => setState(() => _selectedIndex = 2),
              ),
              _buildNavItem(
                isSelected: _selectedIndex == 3,
                icon: _screenIcons[3],
                selectedIcon: _screenSelectedIcons[3],
                label: _screenLabels[3],
                selectedColor: primaryColor,
                unselectedColor: unselectedColor,
                onTap: () => setState(() => _selectedIndex = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required bool isSelected,
    required IconData icon,
    IconData? selectedIcon,
    required String label,
    required Color selectedColor,
    required Color unselectedColor,
    required VoidCallback onTap,
  }) {
    // Each item should be wrapped in Expanded to take up equal space
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24), // For a circular splash area
        splashColor: selectedColor.withOpacity(0.12),
        highlightColor: selectedColor.withOpacity(0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Important for Column inside Row
          children: [
            Icon(
              isSelected ? (selectedIcon ?? icon) : icon,
              size: isSelected ? 28 : 26, // Slightly larger when selected
              color: isSelected ? selectedColor : unselectedColor,
            ),
            const SizedBox(height: 4), // Space between icon and label
            Text(
              label,
              style: TextStyle(
                fontSize: isSelected ? 12 : 11, // Slightly larger text when selected
                color: isSelected ? selectedColor : unselectedColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis, // Handle long labels
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}