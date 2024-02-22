// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'offline_cubit.dart';

enum OfflineStatus {
  isSyncing,
  isSynced,
  error,
  connected,
  offlineMode,
  initial
}

class OfflineState extends Equatable {
  final OfflineStatus offlineStatus;
  final String errorMessage;
  const OfflineState(
      {this.offlineStatus = OfflineStatus.initial, this.errorMessage = ""});

  @override
  List<Object> get props => [offlineStatus, errorMessage];

  OfflineState copyWith({
    OfflineStatus? offlineStatus,
    String? errorMessage,
  }) {
    return OfflineState(
      offlineStatus: offlineStatus ?? this.offlineStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
