import 'package:easy_localization/easy_localization.dart';

String reFormateData(String data) {
  List<String> initailData = data.split("/");
  return initailData[2] + "-" + initailData[1] + "-" + initailData[0];
}

String formatDateString(String inputDate) {
  DateTime now = DateTime.now();
  String currentYear = DateFormat('yyyy').format(now);

  DateTime date = DateFormat('dd MMM yyyy').parse(inputDate + ' $currentYear');

  String formattedDate = DateFormat('EEEE d MMMM yyyy').format(date);
  return formattedDate;
}
