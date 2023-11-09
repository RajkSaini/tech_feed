import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/services.dart';

import '../constant/constants.dart';
import '../services/api_service.dart';
import '../theme/colors.dart';
import 'feed_detail_page.dart';

class FeedPage extends StatefulWidget {
  String category;
  FeedPage({required Key key, required this.category}) : super(key: key);

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late ScrollController _scrollController;
  List<Map<String, dynamic>> feedList = [];
  String selectedCategory = 'All';
  List<Map<String, String>> categories = [];
  bool categoriesLoaded = false;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.category;
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _loadInitialData();
    _loadCategories();
    // SystemChrome.setSystemUIOverlayStyle(
    //   SystemUiOverlayStyle(
    //     statusBarColor: Colors.white, // Change this to your desired background color
    //     statusBarIconBrightness: Brightness.dark, // Use Brightness.light for light icons
    //   ),
    // );
  }

  Future<void> _loadCategories() async {
    final data = await ApiService().getCategories();
    setState(() {
      categories = data ?? [];
      categories.insert(0, {'name': 'All', 'categoryId': '1'});
      categoriesLoaded = true; // Mark categories data as loaded
    });
  }

  // Load the initial batch of data
  Future<void> _loadInitialData() async {
    currentPage=0;
    final data = await ApiService().getFeeds(selectedCategory,currentPage);
    setState(() {
      feedList = data ?? [];
    });
  }

  // Load more data when the user reaches the end of the list
  Future<void> _loadMoreData() async {
    currentPage++;
    final newData = await ApiService().getFeeds(selectedCategory,currentPage);
    setState(() {
      feedList.addAll(newData ?? []);
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      // User has reached the end of the list, load more data
      _loadMoreData();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  width: size.width,
                  decoration: BoxDecoration(color: textFieldColor),
                  child: Padding(
                    padding: EdgeInsets.only(top: 0, bottom: 10),
                    child: Container(
                      decoration: BoxDecoration(color: white),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 5,
                          bottom: 10,
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            margin: EdgeInsets.only(left: 30),
                            child: Row(
                              children: List.generate(categories.length, (index) {
                                final category = categories[index]['name'];
                                final isSelected = category == selectedCategory;

                                return Padding(
                                  padding: const EdgeInsets.only(right: 35),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedCategory = category!;
                                      });
                                      _loadInitialData();
                                    },
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          'assets/images/${category ?? ""}.png',
                                          width: 24,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          category!,
                                          style: isSelected
                                              ? TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold, // Apply a different style for the selected category
                                          )
                                              : TextStyle(fontSize: 12),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // ...

                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: feedList.isEmpty ? 0 : feedList.length * 2 - 1, // Double the itemCount to account for the dividers
                    itemBuilder: (context, index) {
                      if (index.isOdd) {
                        // Add spacing above and below the divider
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0), // Adjust the vertical spacing as needed
                          child: Divider(
                            color: Colors.grey, // Customize the color of the divider
                            thickness: 1, // Customize the thickness of the divider
                            height: 0, // Adjust the height of the divider as needed
                          ),
                        );
                      }
                      final feedIndex = index ~/ 2;
                      if (feedIndex < feedList.length) {
                        final feed = feedList[feedIndex];
                        return YourFeedItemWidget(feed: feed);
                      } else {
                        // Display a loading indicator while more data is loading
                        return CustomLoader();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class YourFeedItemWidget extends StatelessWidget {
  final Map<String, dynamic> feed;

  YourFeedItemWidget({required this.feed});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Build and return your feed item widget here
    // You can use the 'feed' data to display your feed item
    return  Container(
      width: size.width,
      child: Padding(
        padding:
        const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                FeedDetailPage(
                                    feed: feed,
                                    key: new Key(""))));
                  },
                  child: CachedNetworkImage(
                    imageUrl: ApiConstants.baseUrl + "/feed/images/" + feed['feedId'],
                    imageBuilder: (context, imageProvider) => Container(
                      height: 180,
                      margin: const EdgeInsets.only(top: 8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: imageProvider,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), // Add padding
                          child: Container(
                            width: double.infinity,
                            height: 200, // Adjust the image height
                            color: Colors.white, // Customize the skeleton item's appearance
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),

                ),
                // Positioned(
                //   bottom: 15,
                //   right: 15,
                //   child: SvgPicture.asset(
                //     firstMenu[0]['is_liked']
                //         ? "assets/images/loved_icon.svg"
                //         : "assets/images/love_icon.svg",
                //     width: 20,
                //     color: Colors.white,
                //   ),
                // )
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              feed['title'],
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 20, // Adjust the width as needed
        height: 20, // Adjust the height as needed
        child: CircularProgressIndicator(
          strokeWidth: 2, // Adjust the strokeWidth as needed
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Change the color to your desired color
        ),
      ),
    );
  }
}
