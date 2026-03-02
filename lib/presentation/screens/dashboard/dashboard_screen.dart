import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:pos_dashboard/presentation/controllers/theme_controller.dart';
import 'package:pos_dashboard/presentation/screens/settings/settings_screen.dart';
import '../sales/main_sales_page.dart';
import '../items/items_list.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Map<String, String>> _itemsListOptions = [
    {'title': 'Inventory', 'value': 'inventory'},
    {'title': 'Critical Level', 'value': 'critical_level'},
    {'title': 'Out of Stock', 'value': 'out_of_stock'},
  ];

  String _currentListOption = 'Inventory';
  int _selectedIndex = 0;
  Widget _appBarTitle = const Text(
    'Sales',
    style: TextStyle(color: Colors.white),
  );

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _appBarTitle = const Text(
          'Sales',
          style: TextStyle(color: Colors.white),
        );
      } else if (_selectedIndex == 1) {
        _appBarTitle = const Text(
          'Items',
          style: TextStyle(color: Colors.white),
        );
      } else {
        _appBarTitle = const Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        );
      }
    });
  }

  void _showItemsListOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Option'),
          content: SizedBox(
            width: double.minPositive,
            child: ListView(
              shrinkWrap: true,
              children:
                  _itemsListOptions.map((option) {
                    return ListTile(
                      title: Text(option['title']!),
                      onTap: () {
                        setState(() {
                          _currentListOption = option['title']!;
                          _appBarTitle = Text(
                            'Items List',
                            style: TextStyle(color: Colors.white),
                          );
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();
    return GetBuilder<DashboardController>(
      builder: (controller) {
        print("Dashboard_Screen.dart loaded.");
        return Scaffold(
          body:
              controller.isInitialized
                  ? _buildDashboard()
                  : const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildDashboard() {
    Widget bodyContent;

    if (_selectedIndex == 0) {
      bodyContent = const MainSalesPage();
    } else if (_selectedIndex == 1) {
      bodyContent = ItemsList(
        listType: _currentListOption.toLowerCase().replaceAll(' ', '_'),
      );
    } else {
      bodyContent = const SettingsScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title:
            _selectedIndex == 1
                ? Center(
                  child: GestureDetector(
                    onTap: () {
                      _showItemsListOptions(context);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentListOption,
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            color:
                                Theme.of(context).appBarTheme.foregroundColor,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Theme.of(context).appBarTheme.foregroundColor,
                        ),
                      ],
                    ),
                  ),
                )
                : Center(child: _appBarTitle),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: bodyContent,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Sales',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Items',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        backgroundColor: Theme.of(context).cardColor,
        unselectedItemColor: Theme.of(context).unselectedWidgetColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
