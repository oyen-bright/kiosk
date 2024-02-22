import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'show_bottom_nav_state.dart';

/// Cubit for managing the visibility of the bottom navigation bar.
class ShowBottomNavCubit extends Cubit<ShowBottomNavState> {
  ShowBottomNavCubit() : super(const ShowBottomNavState());

  /// Toggle the visibility of the bottom navigation bar.
  ///
  /// [showNav] determines whether to show or hide the bottom navigation bar.
  ///
  /// [fromm] is a string indicating where the request to toggle comes from.
  void toggleShowBottomNav({required bool showNav, required String fromm}) {
    emit(ShowBottomNavState(showNav: showNav));
  }
}
