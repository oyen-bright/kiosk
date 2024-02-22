// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'loading_cubit.dart';

class LoadingState extends Equatable {
  final Status status;
  final String msg;
  const LoadingState({
    this.status = Status.initial,
    this.msg = "",
  });

  @override
  List<Object> get props => [status, msg];

  LoadingState copyWith({
    Status? status,
    String? msg,
  }) {
    return LoadingState(
      status: status ?? this.status,
      msg: msg ?? this.msg,
    );
  }

  @override
  bool get stringify => true;
}

enum Status { initial, loading, loaded, error }
