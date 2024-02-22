import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/constants/constant_color.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/.models.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AppColors {
  static const Color primary = contentColorCyan;
  static const Color menuBackground = Color(0xFF090912);
  static const Color itemsBackground = Color(0xFF1B2339);
  static const Color pageBackground = Color(0xFF282E45);
  static const Color mainTextColor1 = Colors.white;
  static const Color mainTextColor2 = Colors.white70;
  static const Color mainTextColor3 = Colors.white38;
  static const Color mainGridLineColor = Colors.white10;
  static const Color borderColor = Colors.white54;
  static const Color gridLinesColor = Color(0x11FFFFFF);

  static const Color contentColorBlack = Colors.black;
  static const Color contentColorWhite = Colors.white;
  static const Color contentColorBlue = Color(0xFF2196F3);
  static const Color contentColorYellow = Color(0xFFFFC300);
  static const Color contentColorOrange = Color(0xFFFF683B);
  static const Color contentColorGreen = Color(0xFF3BFF49);
  static const Color contentColorPurple = Color(0xFF6E1BFF);
  static const Color contentColorPink = Color(0xFFFF3AF2);
  static const Color contentColorRed = Color(0xFFE80054);
  static const Color contentColorCyan = Color(0xFF50E4FF);
}

class SyncfusionLineChartData {
  final DateTime date;
  final int amount;

  const SyncfusionLineChartData({
    required this.date,
    required this.amount,
  });
}

class DailySalesBarChart extends StatefulWidget {
  const DailySalesBarChart(
      {Key? key,
      required this.title,
      required this.subtitle,
      required this.barBackgroundColor,
      required this.barColor,
      required this.data,
      required this.days,
      required this.touchedBarColor})
      : super(key: key);
  final Color barBackgroundColor;
  final Color barColor;
  final List<String> days;
  final List<int> data;
  final String title;
  final String subtitle;
  final Color touchedBarColor;
  @override
  State<StatefulWidget> createState() => DailySalesBarChartState();
}

class DailySalesBarChartState extends State<DailySalesBarChart> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.23,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ContainerHeader(title: widget.title, subTitle: widget.subtitle),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: _chart(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chart(BuildContext context) {
    final dailyData = convertData(widget.days, widget.data);

    return SizedBox(
        width: double.infinity,
        child: SfCartesianChart(
          primaryXAxis: DateTimeAxis(intervalType: DateTimeIntervalType.days),
          primaryYAxis: NumericAxis(title: AxisTitle(text: "Sale Count")),
          // zoomPanBehavior: _zoomPanBehavior,

          onTrackballPositionChanging: (TrackballArgs args) {
            args.chartPointInfo.label =
                '${args.chartPointInfo.header!} : ${args.chartPointInfo.label!} Sale';
          },
          series: <ChartSeries>[
            LineSeries<SyncfusionLineChartData, DateTime>(
              color: context.theme.colorScheme.primary,
              markerSettings: const MarkerSettings(
                isVisible: true,
              ),
              enableTooltip: true,
              dataSource: dailyData,
              xValueMapper: (SyncfusionLineChartData sales, _) => sales.date,
              yValueMapper: (SyncfusionLineChartData sales, _) => sales.amount,
            ),
          ],
        ));
  }

  List<SyncfusionLineChartData> convertData(
      List<String> days, List<int> amounts) {
    if (amounts.isEmpty) {
      return [];
    }
    DateTime convertDateStringToDateTime(String dateString) {
      try {
        final DateFormat dailyFormat = DateFormat(
          'dd MMM',
        );
        final DateTime date = dailyFormat.parse(dateString);
        return date;
      } on FormatException {
        final DateFormat monthlyFormat = DateFormat(
          'yyyy/MM',
        );
        final DateTime date = monthlyFormat.parse(dateString);

        return date;
      } catch (e) {
        return DateTime.now();
      }
    }

    final List<SyncfusionLineChartData> convertedData = [];

    for (int i = 0; i < days.length; i++) {
      final DateTime date = convertDateStringToDateTime(days[i]);
      final int amount = amounts[i];
      convertedData.add(SyncfusionLineChartData(date: date, amount: amount));
    }

    return convertedData;
  }
}

class PaymentLineChart extends StatefulWidget {
  const PaymentLineChart({Key? key, required this.months, required this.sales})
      : super(key: key);

  final List<String> months;
  final List<List<int>> sales;

  @override
  State<StatefulWidget> createState() => PaymentLineChartState();
}

class PaymentLineChartState extends State<PaymentLineChart> {
  late bool isShowingMainData;

  @override
  void initState() {
    super.initState();

    isShowingMainData = true;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.53,
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 20.w),
                child: ContainerHeader(
                  title: LocaleKeys.dailySalesPayment.tr(),
                  subTitle: LocaleKeys
                      .ourDailySalesPaymentChartProvidesAVisualRepresentationOfYourSalesDataBrokenDownByPaymentMethodThisAllowsYouToQuicklySeeTheBreakdownOfKroonCashCardAndMobileMoneySalesForEachDayProvidingInsightsIntoYourCustomersPaymentPreferencesAndTrendsOverTime
                      .tr(),
                ),
              ),
              Expanded(
                child: _chart(context),
              ),
              10.h.height,
            ],
          ),
        ],
      ),
    );
  }

  Widget _chart(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SfCartesianChart(
        primaryXAxis: DateTimeAxis(intervalType: DateTimeIntervalType.days),
        legend: const Legend(
            isVisible: true, overflowMode: LegendItemOverflowMode.scroll),
        primaryYAxis: NumericAxis(title: AxisTitle(text: "Sale Count")),
        onTrackballPositionChanging: (TrackballArgs args) {
          args.chartPointInfo.label =
              '${args.chartPointInfo.series!.name!} ${args.chartPointInfo.header!} : ${args.chartPointInfo.label!} Sale';
        },
        series: <ChartSeries>[
          LineSeries<SyncfusionLineChartData, DateTime>(
            color: Colors.purple,
            name: "Cash Payment",
            enableTooltip: true,
            markerSettings: const MarkerSettings(
                isVisible: true, shape: DataMarkerType.diamond),
            dataLabelSettings: DataLabelSettings(
              builder: getLabelDesign,
              isVisible: false,
            ),
            dataSource: convertData(widget.months, widget.sales[1]),
            xValueMapper: (SyncfusionLineChartData sales, _) => sales.date,
            yValueMapper: (SyncfusionLineChartData sales, _) => sales.amount,
          ),
          LineSeries<SyncfusionLineChartData, DateTime>(
            color: context.theme.colorScheme.primary,
            name: "Card Payment",
            enableTooltip: true,
            markerSettings: const MarkerSettings(
                isVisible: true, shape: DataMarkerType.pentagon),
            dataLabelSettings: DataLabelSettings(
              isVisible: false,
              builder: getLabelDesign,
            ),
            dataSource: convertData(widget.months, widget.sales[0]),
            xValueMapper: (SyncfusionLineChartData sales, _) => sales.date,
            yValueMapper: (SyncfusionLineChartData sales, _) => sales.amount,
          ),
          LineSeries<SyncfusionLineChartData, DateTime>(
            color: kioskYellow,
            name: "Mobile Payment",
            enableTooltip: true,
            markerSettings: const MarkerSettings(
                isVisible: true, shape: DataMarkerType.triangle),
            dataLabelSettings: DataLabelSettings(
              isVisible: false,
              builder: getLabelDesign,
            ),
            dataSource: convertData(widget.months, widget.sales[3]),
            xValueMapper: (SyncfusionLineChartData sales, _) => sales.date,
            yValueMapper: (SyncfusionLineChartData sales, _) => sales.amount,
          ),
          LineSeries<SyncfusionLineChartData, DateTime>(
            name: "Kroon Payment",
            color: kioskGreen,
            enableTooltip: true,

            // color: context.theme.colorScheme.primary,
            markerSettings: const MarkerSettings(
                isVisible: true, shape: DataMarkerType.circle),

            dataSource: convertData(widget.months, widget.sales[2]),
            xValueMapper: (SyncfusionLineChartData sales, _) => sales.date,
            yValueMapper: (SyncfusionLineChartData sales, _) => sales.amount,
          ),
        ],
      ),
    );
  }

  Widget getLabelDesign(data, point, series, pointIndex, seriesIndex) {
    return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: (series as LineSeries).color,
            borderRadius: BorderRadius.circular(5)),
        child: Text(
          data.amount.toString(),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, color: Colors.white),
        ));
  }

  List<SyncfusionLineChartData> convertData(
      List<String> days, List<int> amounts) {
    DateTime convertDateStringToDateTime(String dateString) {
      final DateFormat format = DateFormat(
        'dd MMM',
      );
      final DateTime date = format.parse(dateString);
      return date;
    }

    final List<SyncfusionLineChartData> convertedData = [];

    if (amounts.isEmpty) {
      return [];
    }

    for (int i = 0; i < days.length; i++) {
      final DateTime date = convertDateStringToDateTime(days[i]);
      final int amount = amounts[i];
      convertedData.add(SyncfusionLineChartData(date: date, amount: amount));
    }

    return convertedData;
  }
}

class MerchantRevenuePieChart extends StatefulWidget {
  const MerchantRevenuePieChart({Key? key, required this.merchantRevenue})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => PieChart2State();
  final List<MerchantRevenue> merchantRevenue;
}

class PieChart2State extends State<MerchantRevenuePieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Column(
        children: [
          ContainerHeader(
              title: LocaleKeys.commonlyUsedPaymenyMethod.tr(),
              subTitle: LocaleKeys
                  .understandingTheMostCommonlyUsedPaymentMethodsForYourBusinessIsCrucialToEnsuringSmoothAndEfficientTransactionsByAnalyzingYourSalesDataYouCanIdentifyThePaymentMethodsThatAreMostPopularAmongYourCustomersAndOptimizeYourOperationsAccordingly
                  .tr()),
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        sectionsSpace: 10,
                        centerSpaceRadius: 40,
                        sections: showingSections(widget.merchantRevenue),
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (var i in widget.merchantRevenue)
                      Indicator(
                        color: i.color,
                        text: i.paymentMethod.replaceAll("_", " "),
                        isSquare: true,
                      ),
                    const SizedBox(
                      height: 4,
                    ),
                  ],
                ),
                const SizedBox(
                  width: 28,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections(List<MerchantRevenue> mr) {
    List<double> percentages = [];

    if (mr.isNotEmpty) {
      double totalRevenue = 0;

      // Calculate total revenue
      for (final item in mr) {
        totalRevenue += item.totalRevenue;
      }

      // Calculate percentage of each payment method over total revenue
      for (final item in mr) {
        final double percentage = (item.totalRevenue / totalRevenue) * 100;
        percentages.add(double.parse(percentage.toStringAsFixed(2)));
      }
    }
    return List.generate(mr.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      return PieChartSectionData(
        color: mr[i].color,
        value: percentages[i],
        title: percentages[i].toString() + '%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: AppColors.mainTextColor1,
          shadows: shadows,
        ),
      );
    });
  }
}

class Indicator extends StatelessWidget {
  const Indicator({
    Key? key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 10,
    this.textColor,
  }) : super(key: key);
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: context.theme.textTheme.labelSmall,
        )
      ],
    );
  }
}
