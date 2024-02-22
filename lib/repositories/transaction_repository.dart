import 'package:kiosk/service/user_services.dart';

class TransactionRepository {
  final UserServices userServices;
  TransactionRepository({
    required this.userServices,
  });
  Future<Map<String, dynamic>> generateFastCheckOut(
      {required String amount}) async {
    try {
      final data = await userServices.generateFastCheckOut(amount);
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
