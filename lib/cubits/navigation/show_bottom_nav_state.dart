// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'show_bottom_nav_cubit.dart';

class ShowBottomNavState extends Equatable {
  final bool showNav;
  const ShowBottomNavState({this.showNav = true});

  @override
  List<Object> get props => [showNav];

  ShowBottomNavState copyWith({
    bool? showNav,
  }) {
    return ShowBottomNavState(
      showNav: showNav ?? this.showNav,
    );
  }
}
