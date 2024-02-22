// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiosk/cubits/login/user_login_cubit.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/login/support/login_support.dart';
import 'package:kiosk/widgets/loader/loading_widget.dart';

import 'login/login_login.dart';

class LogIn extends StatefulWidget {
  const LogIn({Key? key}) : super(key: key);

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    const LoginLogin(),
    const LoginSupport(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.lock),
              label: LocaleKeys.login.tr(),
            ),
            BottomNavigationBarItem(
                icon: const Icon(Icons.support_agent),
                label: LocaleKeys.support.tr()),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
      BlocBuilder<UserLoginCubit, UsersState>(
        builder: (context, state) {
          if (state.status == UserLoginStateStatus.loading) {
            return const LoadingWidget();
          }
          return const SizedBox();
        },
      )
    ]);
  }
}
