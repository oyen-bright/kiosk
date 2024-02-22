import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kiosk/models/.models.dart';
import 'package:kiosk/repositories/user_repository.dart';

part 'worker_state.dart';

class WorkerCubit extends Cubit<WorkerState> {
  /// Creates a WorkerCubit instance.
  ///
  /// The [userRepository] is required for fetching worker data.
  WorkerCubit({required this.userRepository}) : super(const WorkerState()) {
    // When the WorkerCubit is created, fetch the list of workers.
    getWorkers();
  }

  final UserRepository userRepository;

  /// Fetches the list of workers from the repository.
  Future<void> getWorkers() async {
    try {
      // Emit a loading state to indicate that data is being fetched.
      emit(state.copyWith(status: WorkerStatus.loading));

      // Retrieve the list of workers from the repository.
      final listWorker = await userRepository.getWorkerList();

      // Emit a loaded state with the fetched worker data.
      emit(state.copyWith(status: WorkerStatus.loaded, workers: listWorker));
    } catch (e) {
      // If an error occurs during the fetch operation, emit an error state.
      emit(state.copyWith(status: WorkerStatus.error, error: e.toString()));

      // Rethrow the error to allow handling it at a higher level if needed.
      rethrow;
    }
  }
}
