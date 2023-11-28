import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share/share.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../constant/constants.dart';
import '../services/api_service.dart';
import '../theme/colors.dart';
import 'home_page.dart';

class FeedDetailByIdPage extends StatefulWidget {
  final String? feedId;

  const FeedDetailByIdPage({required this.feedId});

  @override
  _FeedDetailByIdPageState createState() => _FeedDetailByIdPageState();
}

class _FeedDetailByIdPageState extends State<FeedDetailByIdPage> {
  late Map<String, dynamic>? feed = {};
  NativeAd? nativeAd;
  bool isNativeAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadFeedData();
    loadNativeAd();
  }

  Future<void> _loadFeedData() async {
    final data = await ApiService().findByFeedId(widget.feedId);
    setState(() {
      feed = data;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Scaffold(
          body: getBody(),
        ),
      ),
    );
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    if (feed!.isEmpty) {
      // Handle the case when feed data is not yet loaded
      return Center(child: CircularProgressIndicator());
    }
    List<String> detailPoints = feed?['detail'].split("\n");

    List<Widget> formattedDetailPoints = [];

    for (var point in detailPoints) {
      final List<TextSpan> spans = [];
      final RegExp boldExp = RegExp(r'<b>(.*?)<\/b>');

      final RegExp imgExp = RegExp(r'<img>([^<]+)<\/img>');
      bool isBold = false;
      bool isImg = false;
      for (var match in imgExp.allMatches(point)) {
        final imageId = match.group(1);
        print(imageId);
        formattedDetailPoints.add(
          getImage(imageId!),
        );
        isImg = true;
      }

      for (var match in boldExp.allMatches(point)) {
        final text = match.group(1);
        if(isImg){
          point=point.split("</img>")[1];
        }
        spans.add(TextSpan(
          text: text,
          style: TextStyle(fontWeight: FontWeight.bold),
        ));
        isBold = true;
      }





      if (spans.isNotEmpty) {
        formattedDetailPoints.add(
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: RichText(
              text: TextSpan(
                children: spans,
              ),
            ),
          ),
        );
      } else if (!isBold) {
        if(isImg){
          point=point.split("</img>")[1];
        }
        formattedDetailPoints.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.circle,
                  size: 8,
                ),
                title: Text(point),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        );
      }
    }


    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: Column(
          children: [
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: ApiConstants.baseUrl + "/feed/images/" + feed?['feedId'],
                  imageBuilder: (context, imageProvider) => Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        fit: BoxFit.cover, // Use BoxFit.cover to fit the image properly
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
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                Positioned(
                  top: 12,
                  left: 10,
                  child: SafeArea(
                    child: IconButton(
                      icon: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.arrow_back,
                            size: 18,
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                            context, MaterialPageRoute(builder: (context) => HomePage()));
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 10,
                  child: SafeArea(
                    child: kIsWeb
                        ? SizedBox.shrink()
                        : IconButton(
                      icon: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.share,
                            size: 18,
                          ),
                        ),
                      ),
                      onPressed: () {
                        Share.share("https://www.techfeed.app/feed/feedDetail/"+feed?['id']);
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feed?['title'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ...formattedDetailPoints,
                ],
              ),
            ),
            Visibility(
              visible: !kIsWeb && isNativeAdLoaded, // Show the AdWidget only if not running on web
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                height: 315,
                child: AdWidget(
                  ad: nativeAd!,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  void loadNativeAd() {
    nativeAd = NativeAd(
      adUnitId: ApiConstants.nativeAdID,
      factoryId: "listTileMedium",
      listener: NativeAdListener(onAdLoaded: (ad) {
        setState(() {
          isNativeAdLoaded = true;
        });
      }, onAdFailedToLoad: (ad, error) {
        nativeAd!.dispose();
      }),
      request: const AdRequest(),
    );
    nativeAd!.load();
  }
  Widget getImage(String imageId) {
    return CachedNetworkImage(
      imageUrl: ApiConstants.baseUrl + "/feed/images/" + imageId,
      imageBuilder: (context, imageProvider) => Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          image: DecorationImage(
            fit: BoxFit.cover, // Use BoxFit.cover to fit the image properly
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
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Container(
              width: double.infinity,
              height: 200,
              color: Colors.white,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
  @override
  void dispose() {
    nativeAd?.dispose();
    super.dispose();
  }
}
