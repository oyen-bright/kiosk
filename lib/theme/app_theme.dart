import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as date_picker_pro;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_button/group_button.dart';
import 'package:kiosk/constants/.constants.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:nice_intro/nice_intro.dart';

ThemeData appThemes({bool isDarkMode = false}) {
  if (!isDarkMode) {
    return ThemeData.light().copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.all<Color>(kioskBlue),
        ),
        chipTheme: ChipThemeData(
            backgroundColor: kioskBlue,
            deleteIconColor: Colors.white,
            labelStyle: const TextStyle(color: Colors.white)),
        canvasColor: Colors.white,
        expansionTileTheme: expansionTileThemeData(),
        inputDecorationTheme: inputDecorationTheme(),
        elevatedButtonTheme: elevatedButtonThemeData(),
        colorScheme: lightColorScheme.copyWith(secondary: kioskBlue));
  } else {
    return ThemeData.dark().copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.all<Color>(kioskBlue),
        ),
        canvasColor: Colors.black,
        expansionTileTheme: expansionTileThemeData(true),
        inputDecorationTheme: inputDecorationThemeDark(),
        elevatedButtonTheme: elevatedButtonThemeData(),
        colorScheme: darkColorScheme);
  }
}

final lightColorScheme = ColorScheme.light(primary: kioskBlue);
final darkColorScheme = ColorScheme.dark(primary: kioskBlue);

Color kioskGrayBGColor(BuildContext context) {
  return context.theme.brightness == Brightness.light
      ? kioskGrayBG
      : kioskGrayBG.darken(90);
}

ExpansionTileThemeData expansionTileThemeData([bool isdark = false]) =>
    ExpansionTileThemeData(
      // textColor: Color(0xFF0000BC),
      // iconColor: Colors.black,
      // collapsedIconColor: Color(0xFF0000BC),
      collapsedBackgroundColor: isdark
          ? const Color.fromRGBO(217, 217, 240, 1).darken()
          : const Color.fromRGBO(217, 217, 240, 1),
    );

InputDecorationTheme inputDecorationTheme() => InputDecorationTheme(
      errorMaxLines: 2,

      contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      focusedBorder: const OutlineInputBorder(
          // borderSide: BorderSide(color: Colors.black, width: 1.0),
          ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 1.0),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 1.0),
      ),
      enabledBorder: const OutlineInputBorder(
          // borderSide: BorderSide(color: Colors.grey, width: 1.0),
          ),
      // suffixIconColor: Colors.grey
    );
InputDecorationTheme inputDecorationThemeDark() => InputDecorationTheme(
      errorMaxLines: 2,

      contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white, width: 1.0),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 1.0),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 1.0),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white, width: 1.0),
      ),
      // suffixIconColor: Colors.grey
    );

ElevatedButtonThemeData elevatedButtonThemeData() => ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
      minimumSize: Size.fromHeight(45.h),
      backgroundColor: kioskBlue,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10.r),
          topLeft: Radius.circular(10.r),
          bottomLeft: Radius.circular(10.r),
          bottomRight: Radius.circular(10.r),
        ),
      ),
      foregroundColor: Colors.white,
    ));
date_picker_pro.DatePickerTheme datePickerTheme(BuildContext context) {
  final canvsColor = context.theme.canvasColor;
  final isDarkMode = context.theme.brightness != Brightness.light;
  return date_picker_pro.DatePickerTheme(
      cancelStyle: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black54, fontSize: 16),
      doneStyle:
          TextStyle(color: isDarkMode ? kioskYellow : kioskBlue, fontSize: 16),
      itemStyle: TextStyle(
          color: isDarkMode ? Colors.white : const Color(0xFF000046),
          fontSize: 18),
      backgroundColor: canvsColor,
      headerColor: canvsColor.darken(5));
}

extension GroupButtonOptionsExtension on GroupButtonOptions {
  GroupButtonOptions copyWith({
    Color? selectedColor,
    Color? unselectedColor,
  }) {
    return GroupButtonOptions(
      selectedColor: selectedColor ?? this.selectedColor,
      unselectedColor: unselectedColor ?? this.unselectedColor,
    );
  }
}

GroupButtonOptions groupButtonOption(BuildContext context,
        {GroupingType groupingType = GroupingType.wrap, double? buttonWidth}) =>
    context.theme.brightness == Brightness.light
        ? GroupButtonOptions(
            buttonWidth: buttonWidth,
            selectedColor: kioskBlue,
            groupingType: groupingType)
        : GroupButtonOptions(
            buttonWidth: buttonWidth,
            groupingType: groupingType,
            selectedColor: kioskBlue,
            unselectedColor: Colors.grey[500]);

IntroScreens introScreens(BuildContext context, Function onDone,
        {required String skipText, required List<IntroScreen> slides}) =>
    IntroScreens(
      onDone: () => onDone(),
      onSkip: () => onDone(),
      containerBg: context.theme.colorScheme.background,
      footerBgColor: context.theme.scaffoldBackgroundColor,
      activeDotColor: kioskBlue,
      inactiveDotColor: Colors.white,
      textColor: context.theme.brightness == Brightness.light
          ? kioskBlue
          : Colors.white,
      footerRadius: 18.0,
      skipText: skipText,
      indicatorType: IndicatorType.LINE,
      slides: slides,
    );
GroupButtonOptions groupButtonOptions(BuildContext context) =>
    GroupButtonOptions(
      selectedColor: context.theme.colorScheme.primary,
    );

//canvas color -- Material widgets backgroud
//cursor color -- colorScheme primary color
