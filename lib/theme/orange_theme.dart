import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as date_picker_pro;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_button/group_button.dart';
import 'package:kiosk/constants/.constants.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:nice_intro/nice_intro.dart';

ThemeData orangeTheme(BuildContext context, {bool isDarkMode = false}) {
  if (!isDarkMode) {
    return ThemeData.light().copyWith(
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.white,
        ),
        listTileTheme: const ListTileThemeData(enableFeedback: true),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white.darken(5),
          foregroundColor: kioskBlue,
          systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark),
        ),
        // textTheme: GoogleFonts.poppinsTextTheme(),
        textTheme: ['yo', 'ig', 'ha'].contains(context.locale.toString())
            ? GoogleFonts.robotoTextTheme()
            : GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: const Color.fromRGBO(255, 252, 234, 1),
        shadowColor: shadowColor,
        cardTheme: CardTheme(shadowColor: shadowColor),
        primaryColorLight: const Color.fromRGBO(217, 217, 240, 1),
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
        cupertinoOverrideTheme: NoDefaultCupertinoThemeData(
          primaryColor: kioskBlue,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.black, foregroundColor: Colors.white),
        listTileTheme: const ListTileThemeData(enableFeedback: true),
        bottomNavigationBarTheme:
            BottomNavigationBarThemeData(selectedItemColor: kioskYellow),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromRGBO(28, 28, 30, 1).lighten(),
          systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light),
        ),
        radioTheme: RadioThemeData(
          fillColor: MaterialStateColor.resolveWith((states) => kioskYellow),
        ),
        textTheme: ['yo', 'ig', 'ha'].contains(context.locale.toString())
            ? GoogleFonts.robotoTextTheme(const TextTheme())
            : GoogleFonts.poppinsTextTheme(const TextTheme()),
        expansionTileTheme: expansionTileThemeData(true),
        scaffoldBackgroundColor: Colors.black,
        // scaffoldBackgroundColor:
        //     const Color.fromRGBO(255, 252, 234, 1).darken(90),
        cardTheme: CardTheme(shadowColor: shadowColor.darken(30)),
        primaryColorLight: const Color.fromRGBO(217, 217, 240, 1).darken(80),
        shadowColor: Colors.black.lighten(10),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.all<Color>(kioskYellow),
        ),
        canvasColor: const Color.fromRGBO(28, 28, 30, 1),
        // canvasColor: const Color.fromRGBO(255, 252, 234, 1).darken(100),
        // canvasColor: const Color.fromRGBO(51, 51, 56, 1),
        // canvasColor: Colors.black,
        inputDecorationTheme: inputDecorationThemeDark(),
        elevatedButtonTheme: elevatedButtonThemeData(darkTheme: true),
        colorScheme: darkColorScheme);
  }
}

final lightColorScheme = ColorScheme.light(
  primary: kioskBlue,
);
final darkColorScheme = ColorScheme.dark(primary: kioskYellow
//  kioskBlue.lighten(50)

    );

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
      helperMaxLines: 2,

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
      helperMaxLines: 2,

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

ElevatedButtonThemeData elevatedButtonThemeData({bool darkTheme = false}) =>
    ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
      fixedSize: Size.fromHeight(45.h),
      backgroundColor: darkTheme ? kioskYellow : kioskBlue,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10.r),
          topLeft: Radius.circular(10.r),
          bottomLeft: Radius.circular(10.r),
          bottomRight: Radius.circular(10.r),
        ),
      ),
      foregroundColor: darkTheme ? Colors.white : Colors.white,
    ));
date_picker_pro.DatePickerTheme datePickerTheme(BuildContext context) {
  final canvsColor = context.theme.canvasColor;
  final isDarkMode = context.theme.brightness != Brightness.light;
  return date_picker_pro.DatePickerTheme(
      cancelStyle: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black54, fontSize: 16),
      doneStyle: TextStyle(color: kioskBlue, fontSize: 16),
      itemStyle: TextStyle(
          color: isDarkMode ? Colors.white : const Color(0xFF000046),
          fontSize: 18),
      backgroundColor: canvsColor,
      headerColor: canvsColor.darken(5));
}

GroupButtonOptions groupButtonOption(BuildContext context,
        {BorderRadius? borderRadius,
        GroupingType groupingType = GroupingType.wrap,
        double? spacing}) =>
    context.theme.brightness == Brightness.light
        ? GroupButtonOptions(
            spacing: spacing ?? 10,
            borderRadius: borderRadius,
            groupingType: groupingType,
            selectedColor: kioskBlue,
          )
        : GroupButtonOptions(
            spacing: spacing ?? 10,
            borderRadius: borderRadius,
            groupingType: groupingType,
            selectedColor: kioskYellow,
            unselectedColor: Colors.grey[300]);

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
