import 'package:easy_localization/easy_localization.dart';

class NewsFeed {
  final String id;
  final String createdDate;
  final String title;
  final String image;
  final String content;

  const NewsFeed(
      {required this.content,
      required this.createdDate,
      required this.id,
      required this.image,
      required this.title});

  factory NewsFeed.fromJson(Map<dynamic, dynamic> json) {
    final title = json['title'].toString().replaceAll("â", "'");
    return NewsFeed(
      id: json["id"] ?? "",
      content: json["content"].toString().replaceAll("â", "'"),
      createdDate: json["created_date"] ?? "",
      image: json["image"],
      title: toBeginningOfSentenceCase(title) ?? title,
    );
  }
}
