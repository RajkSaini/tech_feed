import 'dart:convert';

List<Feed> feedModelFromJson(String str) =>
    List<Feed>.from(json.decode(str).map((x) => Feed.fromJson(x)));


class Feed {
  Feed({
   required this.feedId,
   required this.title,
   required this.detail,
   required this.views,
   required this.tags,
  });

  String? feedId;
  String title;
  String? detail;
  String? views;
  List<String>? tags;

  factory Feed.fromJson(Map<String, dynamic> json) => Feed(
    feedId: json["feedId"] as String?,
    title: json["title"] as String,
    detail: json["detail"] as String?,
    views: json["views"] as String?,
    tags: json["tags"],
  );

}