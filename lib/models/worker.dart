class Worker {
  String name;
  String email;
  String contactNumber;
  String? dateOfBirth;
  String gender;
  String joinDate;
  CountryOfResidence countryOfResidence;
  List<dynamic> address;

  Worker({
    required this.name,
    required this.email,
    required this.joinDate,
    required this.contactNumber,
    required this.gender,
    required this.countryOfResidence,
    required this.address,
    this.dateOfBirth,
  });

  String get abbrevation {
    return '${name[0]}${name.split(' ').last[0]}'.toUpperCase();
  }

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      joinDate: json['created_date'].toString(),
      name: json['name'],
      email: json['email'],
      contactNumber: json['contact_number'],
      dateOfBirth: json['date_of_birth'],
      gender: json['gender'],
      countryOfResidence:
          CountryOfResidence.fromJson(json['country_of_residence']),
      address: json['address'],
    );
  }
}

class CountryOfResidence {
  String name;
  String iso2;
  String native;

  CountryOfResidence({
    required this.name,
    required this.iso2,
    required this.native,
  });

  factory CountryOfResidence.fromJson(Map<String, dynamic> json) {
    return CountryOfResidence(
      name: json['name'],
      iso2: json['iso2'],
      native: json['native'],
    );
  }
}
