// ignore_for_file: public_member_api_docs, sort_constructors_first

part of 'payment_method_cubit.dart';

class PaymentMethodState extends Equatable {
  const PaymentMethodState({this.paymentMethods = const []});

  final List<PaymentMethod> paymentMethods;

  @override
  List<Object> get props => [paymentMethods];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'paymentMethods': paymentMethods.map((x) => x.toMap()).toList(),
    };
  }

  factory PaymentMethodState.fromMap(Map<String, dynamic> map) {
    return PaymentMethodState(
      paymentMethods: List<PaymentMethod>.from(
        List.castFrom(map['paymentMethods']).map<PaymentMethod>(
          (x) => PaymentMethod.fromMap(Map<String, dynamic>.from(x)),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory PaymentMethodState.fromJson(String source) =>
      PaymentMethodState.fromMap(json.decode(source) as Map<String, dynamic>);

  PaymentMethodState copyWith({
    List<PaymentMethod>? paymentMethods,
  }) {
    return PaymentMethodState(
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }
}

class PaymentMethod {
  final String name;
  final String description;
  final bool isEnabled;

  const PaymentMethod({
    required this.name,
    required this.description,
    this.isEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'description': description,
      'isEnabled': isEnabled,
    };
  }

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      name: map['name'] as String,
      description: map['description'] as String,
      isEnabled: map['isEnabled'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory PaymentMethod.fromJson(String source) =>
      PaymentMethod.fromMap(json.decode(source) as Map<String, dynamic>);

  PaymentMethod copyWith({
    String? name,
    String? description,
    bool? isEnabled,
  }) {
    return PaymentMethod(
      name: name ?? this.name,
      description: description ?? this.description,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
