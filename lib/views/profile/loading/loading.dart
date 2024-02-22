import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiosk/blocs/cart/cart_bloc.dart';
import 'package:kiosk/blocs/register_products/register_products_bloc.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/.repositories.dart';
import 'package:kiosk/service/local_storage/local_storage.dart';
import 'package:kiosk/views/login/login.dart';
import 'package:kiosk/widgets/.widgets.dart';

class ProfileLoadingScreen extends StatefulWidget {
  final bool isDeleteAccount;
  const ProfileLoadingScreen({Key? key, this.isDeleteAccount = false})
      : super(key: key);

  @override
  State<ProfileLoadingScreen> createState() => _ProfileLoadingScreenState();
}

class _ProfileLoadingScreenState extends State<ProfileLoadingScreen> {
  Future loading() async {
    if (widget.isDeleteAccount) {
      try {
        await context.read<UserRepository>().deleteAccount();
        context.read<UserRepository>().userLogout();
        await context.read<LocalStorage>().deleteAccount();
        context.pushView(const LogIn(), clearStack: true);
      } catch (e) {
        context.snackBar(e.toString());
        context.popView();
      }
    } else {
      context.read<ProductsCubit>().clear();
      context.read<CartBloc>().add(ClearCartEvent());
      context.read<RegisterProductsBloc>().add(IntialProductEvent());
      context.read<UserRepository>().userLogout();
      await context.read<LocalStorage>().userLogout();
      context.pushView(const LogIn(), clearStack: true);
    }
  }

  @override
  void initState() {
    loading();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: context.theme.canvasColor,
        child: const LoadingWidget(title: ""));
  }
}
