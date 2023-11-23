import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tech_feed/pages/root_app.dart';

import '../services/api_service.dart';
import 'home_page.dart';

void main() {
  runApp(TechNewsCategorySelector());
}

class TechNewsCategorySelector extends StatefulWidget {
  @override
  _TechNewsCategorySelectorState createState() =>
      _TechNewsCategorySelectorState();
}

class _TechNewsCategorySelectorState extends State<TechNewsCategorySelector> {
  List<String> selectedCategories = [];
  List<CategoryItem> techCategories = [];

  List<Map<String, String>>? apiResponse = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _handleCategorySelection(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
    });
  }
  Future<void> _loadInitialData() async {
    final data = await ApiService().getCategories("");
    setState(() {
      apiResponse = data ?? [];
      _loadCategoriesByEmail();
    });

  }

  Widget _buildCategoryButtons() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
        children: apiResponse!.map((category) {
          final categoryId = category["categoryId"];
          final categoryName = category["name"];
          final isSelected = selectedCategories.contains(categoryId);

          return InkWell(
            onTap: () {
              if (categoryId != null && categoryName != null) {
                _handleCategorySelection(categoryId);
              }
            },
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
        child: Center(
            child: Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Scaffold(
                      body: Column(
                        children: [
                          SizedBox(
                            height: size.height * 0.03,
                          ),
                          Text(
                            "Select Tech Categories",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: size.height * 0.03,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: _buildCategoryButtons(),
                          ),
                          GestureDetector(
                              onTap: () {
                               startNow();
                              },
                          child: startButton(size)),

                        ],
                      ),
                    )))));
  }
   startNow() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? emailId=prefs.getString("emailId");
      print("emailId :"+emailId!);
      await ApiService().updateUserCategories(emailId, selectedCategories);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => RootApp()));
  }
  Future<void> _loadCategoriesByEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String emailId= prefs.getString('emailId')!;
    final categories = await ApiService().getCategories(emailId);

    if (categories != null) {
      final selectedCategoryIds = categories.map((category) => category['categoryId']).toList();

      setState(() {
        selectedCategories = selectedCategoryIds.cast<String>();
      });
    }
  }
}

class CategoryItem {
  final String name;
  final String imagePath;

  CategoryItem(this.name, this.imagePath);
}

Widget startButton(Size size) {
  return
    Container(
    alignment: Alignment.center,
    height: size.height / 15,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(50.0),
      color: const Color(0xFF21899C),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF4C2E84).withOpacity(0.2),
          offset: const Offset(0, 15.0),
          blurRadius: 60.0,
        ),
      ],
    ),
    child: Text(
      'Let\'s Start !',
      style: GoogleFonts.inter(
        fontSize: 14.0,
        color: Colors.white,
        fontWeight: FontWeight.w600,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    ),
  );
}

