// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'internet_cubit.dart';

enum InternetStatus { initial, noInternet, connected }

class InternetState extends Equatable {
  final InternetStatus status;
  const InternetState({this.status = InternetStatus.initial});

  @override
  List<Object> get props => [status];

  InternetState copyWith({
    InternetStatus? status,
  }) {
    return InternetState(
      status: status ?? this.status,
    );
  }
}
