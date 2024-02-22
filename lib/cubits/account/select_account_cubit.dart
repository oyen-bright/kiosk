import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kiosk/models/sales_report.dart';
import 'package:kiosk/models/user.dart';

import '../../repositories/user_repository.dart';

part 'select_account_state.dart';

class SelectAccountCubit extends Cubit<SelectAccountState> {
  final UserRepository userRepository;

  SelectAccountCubit({
    required this.userRepository,
  }) : super(SelectAccountState.intitial());

  Future<void> switchBusinessProfile({required String id}) async {
    try {
      emit(state.copyWith(selectAccountStatus: SelectAccountStatus.loading));

      List<dynamic> data = await userRepository.switchBusinessProfile(id: id);

      emit(state.copyWith(
          selectAccountStatus: SelectAccountStatus.loaded,
          currentUser: data[0],
          usersSalesReport: data[1]));
    } catch (e) {
      emit(state.copyWith(
          selectAccountStatus: SelectAccountStatus.error, error: e.toString()));
      rethrow;
    }
  }
}
