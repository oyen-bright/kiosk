import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'loading_state.dart';

/// Cubit for managing loading state.
class LoadingCubit extends Cubit<LoadingState> {
  LoadingCubit() : super(const LoadingState());

  /// Set the initial loading state.
  ///
  /// This method sets the state to the initial loading state.
  void initialState() {
    emit(const LoadingState());
  }

  /// Update the state to indicate loading.
  ///
  /// This method updates the state to indicate that a loading operation is in progress.
  ///
  /// [message] is an optional message to provide additional context for the loading operation.
  void loading({String message = ""}) {
    emit(state.copyWith(status: Status.loading, msg: message));
  }

  /// Update the state to indicate loading has completed successfully.
  ///
  /// This method updates the state to indicate that a loading operation has completed successfully.
  ///
  /// [message] is an optional message to provide additional context for the loaded state.
  void loaded({String message = ""}) {
    emit(state.copyWith(status: Status.loaded, msg: message));
  }

  /// Update the state to indicate an error.
  ///
  /// This method updates the state to indicate that an error has occurred during a loading operation.
  ///
  /// [message] is an optional message to provide additional context for the error state.
  void error({String message = ""}) {
    emit(state.copyWith(status: Status.error, msg: message));
  }
}
