import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/ThemeNotifier.dart';
import '../services/api_service.dart';
import 'categorySelector.dart';
import 'login.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String emailId = "";
  String userName = "";
  List<Map<String, String>>? apiResponse = [];

  @override
  void initState() {
    _loadData();
    _loadCategoriesData();
    super.initState();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    emailId = prefs.getString('emailId')!;
    userName = prefs.getString("userName")!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _buildPageIfUserLoggedIn(emailId),
      ),
    );
  }

  Future<void> _loadCategoriesData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String emailId1 = prefs.getString('emailId')!;
    final data = await ApiService().getCategories(emailId1);
    setState(() {
      apiResponse = data ?? [];
    });
  }

  void _handleLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear(); // Clear all stored data, replace this with your actual logout logic

    // Navigate to the login or authentication screen
    Navigator.push(context, MaterialPageRoute(builder: (_) => Login()));
  }

  Widget _buildPageIfUserLoggedIn(emailId) {
    if (emailId != null && !emailId.isEmpty) {
      return Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: ListView(
          children: [
            _SingleSection(
              title: "General",
              children: [
                _CustomListTile(
                  title: userName,
                  icon: CupertinoIcons.person_alt_circle,
                ),
                _CustomListTile(
                  title: emailId,
                  icon: CupertinoIcons.envelope,
                ),
                _CustomListTile(
                  title: "Dark Mode",
                  icon: CupertinoIcons.moon,
                  trailing: CupertinoSwitch(
                    value: Provider.of<ThemeNotifier>(context).currentTheme.brightness == Brightness.dark,
                    onChanged: (value) {
                      Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
                    },
                  ),
                ),
              ],
            ),
            _SingleSection(
              title: "Interests",
              onEdit: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TechNewsCategorySelector()),
                );
              },
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildCategoryButtons(),
                ),
              ],
            ),
            _SingleSection(
              title: "Logout",
              children: [
                _CustomListTile(
                  title: "Logout",
                  icon: CupertinoIcons.square_arrow_left,
                  onTap: () {
                    _handleLogout();
                  },
                ),
              ],
            ),
          ],
        ),
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Sign In for personalized feed",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Login()),
              );
            },
            child: Text("Login"),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButtons() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: apiResponse!.map((category) {
        final categoryId = category["categoryId"];
        final categoryName = category["name"];
        final isSelected = false;

        return InkWell(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/${categoryName ?? ""}.png',
                  width: 24.0,
                  height: 24.0,
                ),
                SizedBox(width: 8.0),
                Text(
                  categoryName ?? "",
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CustomListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _CustomListTile({
    Key? key,
    required this.title,
    required this.icon,
    this.trailing,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      trailing: (title == "Logout" || title == "Dark Mode")
          ? trailing ?? const Icon(CupertinoIcons.forward, size: 18)
          : null,
      onTap: onTap,
    );
  }
}

class _SingleSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback? onEdit;

  const _SingleSection({
    Key? key,
    required this.title,
    required this.children,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 16),
              ),
              if (onEdit != null)
                InkWell(
                  onTap: onEdit,
                  child: Icon(
                    Icons.edit,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}
