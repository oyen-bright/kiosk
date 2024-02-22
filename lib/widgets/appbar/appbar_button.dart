part of 'custom_appbar.dart';

class AppbarButton extends StatelessWidget {
  final VoidCallback callback;
  final bool showBadge;
  final int? badgeCount;
  final dynamic child;

  const AppbarButton({
    Key? key,
    required this.callback,
    required this.child,
    this.showBadge = false,
    this.badgeCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final badgeContent = badgeCount != null
        ? Text(
            badgeCount.toString(),
            style: const TextStyle(fontSize: 10, color: Colors.white),
          )
        : null;

    final childContent = child is Image
        ? Padding(padding: EdgeInsets.all(5.r), child: child)
        : (context.locale.toString()) != "en"
            ? Icon(
                Icons.newspaper,
                color: kioskBlue,
              )
            : AutoSizeText(
                child.toString(),
                minFontSize: 4,
                maxLines: 3,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(0, 0, 188, 1),
                ),
              );

    return GestureDetector(
      onTap: callback,
      child: bg.Badge(
        showBadge: showBadge,
        toAnimate: false,
        position: bg.BadgePosition.topEnd(top: -1, end: 2),
        badgeColor: Colors.red,
        badgeContent: badgeContent,
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(bottom: 15.h, top: 0),
          padding: EdgeInsets.all(5.r),
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(217, 217, 240, 0.5),
                blurRadius: 2,
                spreadRadius: 0,
                offset: Offset(0, 3),
              ),
            ],
            borderRadius: BorderRadius.circular(11),
            color: const Color.fromRGBO(217, 217, 240, 1),
          ),
          child: childContent,
        ),
      ),
    );
  }
}
