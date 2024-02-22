// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/theme_extention.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/amount_formatter.dart';
import 'package:kiosk/utils/get_currency.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class CreateLineChart extends StatefulWidget {
  const CreateLineChart({
    Key? key,
    required this.months,
    required this.sales,
  }) : super(key: key);

  final List<String> months;
  final List<dynamic> sales;

  @override
  State<CreateLineChart> createState() => _CreateLineChartState();
}

class _CreateLineChartState extends State<CreateLineChart> {
  @override
  Widget build(BuildContext context) {
    return LineChart(
      sampleData2,
      swapAnimationDuration: const Duration(milliseconds: 250),
    );
  }

  List<double> getMaxY() {
    List<int> smax =
        List.from(widget.sales.map((e) => e["total_sales_count"]).toList());

    if (smax.length == 1) {
      return [smax[0].toDouble()];
    }
    int min = smax.reduce((a, b) => a < b ? a : b);
    int max = smax.reduce((a, b) => a > b ? a : b);
    final mul = widget.sales.length < 6 ? widget.sales.length.toDouble() : 6;

    int numOfValues = mul.toInt();
    double increment = (max - min) / (numOfValues - 1);
    List<double> numbers = [];

    for (int i = 0; i < numOfValues; i++) {
      double value = min + (i * increment);
      numbers.add(value);
    }
    return numbers;
  }

  double scaleDown(int originalValue) {
    List<int> smax =
        List.from(widget.sales.map((e) => e["total_sales_count"]).toList());

    int max = smax.reduce((a, b) => a > b ? a : b);
    final mul = widget.sales.length < 6 ? widget.sales.length.toDouble() : 6;
    final y = (originalValue / max) * mul;
    String roundedNum = y.toStringAsFixed(1);

    return double.parse(roundedNum);
  }

  int scaleUp(double originalValue) {
    List<int> smax =
        List.from(widget.sales.map((e) => e["total_sales_count"]).toList());

    int max = smax.reduce((a, b) => a > b ? a : b);
    final mul = widget.sales.length < 6 ? widget.sales.length.toDouble() : 6;

    final y = (originalValue / mul) * max;
    String roundedNum = y.toStringAsFixed(1);

    return double.parse(roundedNum).round();
  }

  List<FlSpot> getSpot() {
    List<FlSpot> spots = [];
    List<int> smax =
        List.from(widget.sales.map((e) => e["total_sales_count"]).toList());

    for (int i = 0; i < smax.length; i++) {
      spots.add(FlSpot(i.toDouble(), scaleDown(smax[i])));
    }
    return spots;
  }

  LineChartData get sampleData2 => LineChartData(
        backgroundColor: context.theme.colorScheme.primary.withOpacity(0.01),
        lineTouchData: lineTouchData2,
        gridData: gridData,
        titlesData: titlesData2,
        borderData: borderData,
        lineBarsData: lineBarsData2,
        minX: 0,
        maxX: widget.months.length.toDouble() - 1,
        maxY: widget.sales.isNotEmpty
            ? widget.sales.length < 6
                ? widget.sales.length.toDouble()
                : 6
            : 0,
        minY: 0,
      );

  LineTouchData get lineTouchData2 => LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((spot) {
              final flSpot = getSpot()[spot.x.toInt()];
              return LineTooltipItem(
                '${widget.months[flSpot.x.toInt()]} \n${scaleUp(flSpot.y)} Sales \n${amountFormatter(widget.sales[flSpot.x.toInt()]["total_sales_amount"], getCurrency(context) + " ")}',
                const TextStyle(color: Colors.white),
              );
            }).toList();
          },
        ),
      );

  FlTitlesData get titlesData2 => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles(),
        ),
      );

  List<LineChartBarData> get lineBarsData2 => [
        lineChartBarData2_3,
      ];

  Widget leftTitleWidgets(
    double value,
    TitleMeta meta,
  ) {
    final style = context.theme.textTheme.titleSmall!
        .copyWith(fontWeight: FontWeight.bold);

    if (widget.sales.isNotEmpty) {
      List<int> smax =
          List.from(widget.sales.map((e) => e["total_sales_count"]).toList());

      int max = smax.reduce((a, b) => a > b ? a : b);
      int min = 0;

      int numOfValues = 2;
      double increment = (max - min) / (numOfValues - 1);
      List<double> numbers = [];

      for (int i = 0; i < numOfValues; i++) {
        double value = min + (i * increment);
        numbers.add(value);
      }

      String text;
      switch (value.toInt()) {
        case 0:
          text = 0.toString();
          break;
        case 1:
          text = getMaxY()[0].toInt().toString();
          break;
        case 2:
          text = getMaxY()[1].toInt().toString();
          break;
        case 3:
          text = getMaxY()[2].toInt().toString();
          break;
        case 4:
          text = getMaxY()[3].toInt().toString();
          break;
        case 5:
          text = getMaxY()[4].toInt().toString();
          break;
        case 6:
          text = getMaxY()[5].toInt().toString();
          break;
        default:
          return Container();
      }

      return Text(text, style: style, textAlign: TextAlign.center);
    }
    return Container();
  }

  SideTitles leftTitles() => SideTitles(
        getTitlesWidget: leftTitleWidgets,
        showTitles: true,
        interval: 1,
        reservedSize: 40,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    Widget text = Text(
      widget.months[value.toInt()],
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 15,
      angle: 0.5,
      fitInside: const SideTitleFitInsideData(
          enabled: true,
          distanceFromEdge: -50,
          parentAxisSize: 0,
          axisPosition: 4),
      child: text,
    );
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  FlGridData get gridData => FlGridData(show: false);

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(
              color: context.theme.colorScheme.primary.withOpacity(0.2),
              width: 4),
          left: const BorderSide(color: Colors.transparent),
          right: const BorderSide(color: Colors.transparent),
          top: const BorderSide(color: Colors.transparent),
        ),
      );

  LineChartBarData get lineChartBarData2_3 => LineChartBarData(
        isCurved: true,
        curveSmoothness: 0,
        color: context.theme.colorScheme.primary.withOpacity(0.9),
        barWidth: 2,
        isStrokeCapRound: true,
        lineChartStepData: LineChartStepData(),
        dotData: FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
        spots: getSpot(),
      );
}

class SalesLineChart extends StatefulWidget {
  const SalesLineChart({Key? key, required this.months, required this.sales})
      : super(key: key);

  final List<String> months;
  final List<dynamic> sales;

  @override
  State<StatefulWidget> createState() => SalesLineChartState();
}

class SalesLineChartState extends State<SalesLineChart> {
  late bool isShowingMainData;

  @override
  void initState() {
    super.initState();
    isShowingMainData = true;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.23,
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 20.w),
                child: ContainerHeader(
                    title: LocaleKeys.weeklySales.tr(),
                    subTitle: LocaleKeys
                        .thisChartDisplaysEachSaleMadeByAWorkerAsADotOnTheCorrespondingDayThisAllowsYouToEasilyTrackTheirSalesPerformanceOverTimeAndIdentifyAnyTrendsOrPatterns
                        .tr()),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, left: 6),
                  child: CreateLineChart(
                    months: widget.months,
                    sales: widget.sales,
                  ),
                ),
              ),
              10.h.height,
            ],
          ),
        ],
      ),
    );
  }
}
