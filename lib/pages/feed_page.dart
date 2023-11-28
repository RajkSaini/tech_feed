import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  List<NativeAd?> nativeAds = [];
  List<bool> isNativeAdLoadedList = [];
  late ScrollController _scrollController;
  List<Map<String, dynamic>> feedList = [];
  String selectedCategory = 'All';
  List<Map<String, String>> categories = [];
  bool categoriesLoaded = false;
  int currentPage = 0;
  int adIndex=0;
  @override
  void initState() {
    super.initState();
    selectedCategory = widget.category;
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    loadMoreAds();
    _loadCategories();

  }


  Future<void> _loadCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? emailId= prefs.getString('emailId');
    if(emailId==null){
      emailId="";
    }
    final data = await ApiService().getCategories(emailId);
    setState(() {
      categories = data ?? [];
      categories.insert(0, {'name': 'All', 'categoryId': '1'});
      categoriesLoaded = true; // Mark categories data as loaded
      _loadInitialData();
    });
  }

  // Load the initial batch of data
  Future<void> _loadInitialData() async {
    currentPage=0;
    List<String?> categoryIds = categories.map((category) => category["categoryId"]).toList();
    if(selectedCategory =='All'){
      final data = await ApiService().getFeeds(categoryIds,currentPage);
      setState(() {
        feedList = data ?? [];
      });
    }else{
      List<String?> categoryIds = [getCategoryByName(selectedCategory)];
      final data = await ApiService().getFeeds(categoryIds,currentPage);
      setState(() {
        feedList = data ?? [];
      });
    }

  }
  String? getCategoryByName(String categoryName) {
    for (Map<String, String> category in categories) {
      if (category["name"] == categoryName) {
        return category["categoryId"];
      }
    }
    return null; // Return null if the category with the given name is not found
  }
  // Load more data when the user reaches the end of the list
  Future<void> _loadMoreData() async {
    currentPage++;
    List<String?> categoryIds = categories.map((category) => category["categoryId"]).toList();

    if (selectedCategory == 'All') {
      final newData = await ApiService().getFeeds(categoryIds, currentPage);
      if (newData!.isNotEmpty) {
        if(!kIsWeb){
          setState(() {
            feedList.add({'ad': true}); // Add a placeholder for the new ad instance
          });
        }
      }
      setState(() {
        feedList.addAll(newData ?? []);
      });
    } else {
      List<String?> categoryIds = [getCategoryByName(selectedCategory)];
      final data = await ApiService().getFeeds(categoryIds, currentPage);
      if (data!.isNotEmpty) {
        if (!kIsWeb) {
          setState(() {
            feedList.add(
                {'ad': true}); // Add a placeholder for the new ad instance
          });
        }
        setState(() {
          feedList.addAll(data ?? []);
        });
      }
    }
  }
  void loadNativeAd() {
    NativeAd nativeAd = NativeAd(
      adUnitId: ApiConstants.nativeAdID,
      factoryId: "listTileMedium",
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            nativeAds.add(ad as NativeAd?);
            isNativeAdLoadedList.add(true);
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose(); // Dispose of the ad if loading fails
        },
      ),
      request: const AdRequest(),
    );
    nativeAd.load();
  }

  loadMoreAds(){
    for (int i = adIndex; i < adIndex+3; i++) {
      loadNativeAd();
    }
  }
  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent-500) {
      // User has reached the end of the list, load more data
      _loadMoreData();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
    // Dispose of all loaded ads when the widget is disposed
    for (NativeAd? ad in nativeAds) {
      ad?.dispose();
    }
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
                      decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.light
                              ? Colors.white  // Use the light theme background color
                              : Colors.black45,  // Use the dark theme background color
                      ),
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
                                      nativeAds.clear();
                                      loadMoreAds();
                                      _loadInitialData();
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            //color: isSelected ? Colors.blue : Colors.transparent, // Adjust the color for the selected category
                                            borderRadius: BorderRadius.circular(12.0),
                                            border: isSelected
                                                ? Border.all(
                                              color: Colors.blue,
                                              width: 2.0,
                                            )
                                                : null,
                                          ),
                                          child: Image.asset(
                                            'assets/images/${category ?? ""}.png',
                                            width: 24,
                                          ),
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
              child: feedList.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/moon.png', // Replace with the path to your no feed image
                      width: 200, // Adjust the width as needed
                      height: 200, // Adjust the height as needed
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'No feeds available', // Add your custom text
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
                  : SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: List.generate(
                    feedList.isEmpty ? 0 : feedList.length * 2 - 1,
                        (index) {
                      if (index.isOdd) {
                        // Add spacing above and below the divider
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Divider(
                            color: Colors.grey,
                            thickness: 1,
                            height: 0,
                          ),
                        );
                      }
                      final feedIndex = index ~/ 2;
                      if (feedIndex < feedList.length) {
                        final feed = feedList[feedIndex];
                        if (feed.containsKey('ad')) {
                          if (!kIsWeb && nativeAds.isNotEmpty) {
                            int index = adIndex % nativeAds.length;
                            adIndex++;
                            if(adIndex==nativeAds.length-1){
                              for (int i = adIndex+1; i < adIndex+3; i++) {
                                loadNativeAd();
                              }
                            }
                            return Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              height: 315,
                              child: AdWidget(
                                ad: nativeAds[index]!,
                              ),
                            );
                          }
                        } else {
                          return YourFeedItemWidget(feed: feed);
                        }
                      } else {
                        // Add your existing loader widget
                        return CustomLoader();
                      }
                      return Container();
                    },
                  ),
                ),
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


