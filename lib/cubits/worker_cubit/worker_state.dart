// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'worker_cubit.dart';

enum WorkerStatus { loading, loaded, initial, error }

class WorkerState extends Equatable {
  const WorkerState(
      {this.status = WorkerStatus.initial,
      this.workers = const [],
      this.error});

  final WorkerStatus status;
  final List<Worker> workers;
  final String? error;

  @override
  List<Object?> get props => [status, workers, error];

  WorkerState copyWith({
    WorkerStatus? status,
    List<Worker>? workers,
    String? error,
  }) {
    return WorkerState(
        status: status ?? this.status,
        workers: workers ?? this.workers,
        error: error ?? this.error);
  }
}
