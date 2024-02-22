// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'kiosk_version_cubit.dart';

enum KioskVersionStatus { initial, loading, loaded, error }

class KioskVersionState extends Equatable {
  final KioskVersionStatus status;
  final String errorMessage;
  final bool updateAvailable;
  const KioskVersionState({
    this.errorMessage = "",
    required this.status,
    required this.updateAvailable,
  });

  @override
  List<Object> get props => [status, updateAvailable, errorMessage];

  factory KioskVersionState.initial() {
    return const KioskVersionState(
        status: KioskVersionStatus.initial, updateAvailable: false);
  }

  @override
  bool get stringify => true;

  KioskVersionState copyWith({
    KioskVersionStatus? status,
    String? errorMessage,
    bool? updateAvailable,
  }) {
    return KioskVersionState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      updateAvailable: updateAvailable ?? this.updateAvailable,
    );
  }
}
