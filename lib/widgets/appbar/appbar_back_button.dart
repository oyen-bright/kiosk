part of 'custom_appbar.dart';

class AppBarBackButton extends StatelessWidget {
  const AppBarBackButton({Key? key, this.onTap}) : super(key: key);
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? (() => context.popView()),
      child: Padding(
        padding: const EdgeInsets.only(top: 15, bottom: 15),
        child: Image.asset(
          "assets/images/Icons - Icons Pack - Back.png",
          color: context.theme.colorScheme.primary,
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }
}
