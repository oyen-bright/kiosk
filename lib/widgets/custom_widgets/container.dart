import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/theme_extention.dart';

class CustomContainer extends StatelessWidget {
  const CustomContainer({
    Key? key,
    required this.child,
    this.color,
    this.image,
    this.border,
    this.borderRadius,
    this.boxShadow,
    this.gradient,
    this.backgroundBlendMode,
    this.shape = BoxShape.rectangle,
    this.alignment,
    this.padding,
    this.decoration,
    this.foregroundDecoration,
    this.width,
    this.height,
    this.constraints,
    this.margin,
    this.transform,
    this.transformAlignment,
  }) : super(key: key);
  final Widget child;
  final Color? color;
  final DecorationImage? image;
  final BoxBorder? border;
  final BorderRadiusGeometry? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final BlendMode? backgroundBlendMode;
  final BoxShape shape;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final Decoration? decoration;
  final Decoration? foregroundDecoration;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? margin;
  final Matrix4? transform;
  final AlignmentGeometry? transformAlignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      foregroundDecoration: foregroundDecoration,
      height: height,
      width: width,
      constraints: constraints,
      transform: transform,
      transformAlignment: transformAlignment,
      margin: margin,
      padding:
          padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: decoration ??
          BoxDecoration(
              color: color ?? context.theme.canvasColor,
              image: image,
              border: border,
              borderRadius: borderRadius ?? BorderRadius.circular(16.r),
              boxShadow: boxShadow ??
                  [
                    BoxShadow(
                      color: context.theme.shadowColor,
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]),
      child: child,
    );
  }
}

// BoxDecoration boxDecoration(BuildContext context,
//         {Color? color, double? dy, bool showShadow = true}) =>
//     BoxDecoration(
//       borderRadius: BorderRadius.circular(16.r),
//       color: color ?? context.theme.colorScheme.background,
//       boxShadow: !showShadow
//           ? null
//           : [
//               BoxShadow(
//                 color: context.theme.brightness == Brightness.dark
//                     ? const Color.fromARGB(51, 233, 183, 183)
//                     : const Color.fromRGBO(218, 229, 240, 1),
//                 blurRadius: 20,
//                 spreadRadius: 0,
//                 offset: Offset(
//                   0,
//                   dy ?? 5,
//                 ),
//               )
//             ],
//     );
