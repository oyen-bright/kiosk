// ignore: file_names
class Sales {
  final Map payment;
  final Map user;
  final String createdDate;
  final String worker;
  final bool isRefunded;

  final String orderNumber;
  final double orderTotal;

  const Sales({
    required this.payment,
    required this.user,
    required this.isRefunded,
    required this.createdDate,
    required this.worker,
    required this.orderNumber,
    required this.orderTotal,
  });

  factory Sales.fromJson(Map<String, dynamic> json) {
    try {
      return Sales(
        isRefunded: json["refund"],
        payment: json["payment"] ?? {},
        user: json['user'] ?? {},
        createdDate: json['created_date'],
        worker: json["worker"] ?? "No Worker",
        orderNumber: json['order_number'],
        orderTotal: double.parse(json['order_total'].toString()),
      );
    } catch (e) {
      return Sales(
        isRefunded: json["refund"],
        payment: json["payment"],
        user: json['user'] ?? {},
        createdDate: json['created_date'],
        worker: json["worker"],
        orderNumber: json['order_number'],
        orderTotal: double.parse(json['order_total']),
      );
    }
  }
  Map<String, dynamic> toJson() => {
        "payment": payment,
        "refund": isRefunded,
        "user": user,
        "created_date": createdDate,
        "worker": worker,
        "order_number": orderNumber,
        "order_total": orderTotal,
      };
}
