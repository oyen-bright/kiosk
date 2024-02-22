class Ads {
  final String adName;
  final String adImage;
  final String adUrl;

  const Ads({
    required this.adName,
    required this.adImage,
    required this.adUrl,
  });

  factory Ads.fromJson(Map<String, dynamic> json) {
    try {
      return Ads(
        adImage: json['ad_image'],
        adName: json['ad_name'],
        adUrl: json['ad_url'].toString(),
      );
    } catch (e) {
      return Ads(
        adImage: json['ad_image'],
        adName: json['ad_name'],
        adUrl: json['ad_url'].toString(),
      );
    }
  }
}
