class Countries {
  final int? id;
  final String? name;
  final String? phoneCode;
  final String? currency;
  final String? iso2;

  const Countries(
      {this.id, this.name, this.phoneCode, this.currency, this.iso2});

  factory Countries.fromJson(Map<String, dynamic> json) {
    try {
      return Countries(
        id: json['id'] != null ? json['id'] as int : null,
        name: json['name'] != null ? json['name'] as String : null,
        phoneCode:
            json['phone_code'] != null ? json['phone_code'] as String : null,
        currency: json['currency'] != null ? json['currency'] as String : null,
        iso2: json['iso2'] != null ? json['iso2'] as String : null,
      );
    } catch (e) {
      rethrow;
    }
  }
}
