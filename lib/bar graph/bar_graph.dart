import 'package:expense_tracker/bar%20graph/individual_bar_graph.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyBarGraph extends StatefulWidget {
  final List<double> monthlySummary; //[25, 500 ,455]
  final int startMonth; // 0 - Jan, 1 - Feb, 2 - Mar

  const MyBarGraph({
    super.key,
    required this.monthlySummary,
    required this.startMonth,
  });

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  //this list will hold the data for the bar graph
  List<IndividualBar> barData = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scrollToEnd();
    });
  }

  //intialize the bar data
  void initializeBarData() {
    barData = List.generate(
      widget.monthlySummary.length,
      (index) {
        return IndividualBar(
          x: index,
          y: widget.monthlySummary[index],
        );
      },
    );
  }

  //calculate max for upper limit ogf graph
  double calculateMax() {
    //initially set to 10000
    double max = 10000;

    //get the month widget with highest amount
    widget.monthlySummary.sort();

    //increase the upeer limit by a bit
    max = widget.monthlySummary.last * 1.05;

    if (max < 500) {
      return 500;
    }
    return max;
  }

  //scroll controller to make sure it scrolls to the end / latest month
  final ScrollController _scrollController = ScrollController();
  void scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    //initialize upon build
    initializeBarData();

    double barWidth = 12;
    double spaceBetweenBars = 10;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: barWidth * barData.length +
                spaceBetweenBars * (barData.length - 1),
            child: BarChart(
              BarChartData(
                  minY: 0,
                  maxY: 10000,
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: getBottomTitles,
                          reservedSize: 30),
                    ),
                  ),
                  barGroups: barData
                      .map(
                        (data) => BarChartGroupData(
                          x: data.x,
                          barRods: [
                            BarChartRodData(
                              toY: data.y,
                              color: Colors.green,
                              width: 12,
                              borderRadius: BorderRadius.circular(10),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: calculateMax(),
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                  alignment: BarChartAlignment.center),
            ),
          ),
        ),
      ),
    );
  }
}

//BOTTOM - TITLES
Widget getBottomTitles(double value, TitleMeta meta) {
  const textstyle = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  String text;
  switch (value.toInt() % 12) {
    case 0:
      text = 'J';
      break;
    case 1:
      text = 'F';
      break;
    case 2:
      text = 'M';
      break;
    case 3:
      text = 'A';
      break;
    case 4:
      text = 'M';
      break;
    case 5:
      text = 'J';
      break;
    case 6:
      text = 'J';
      break;
    case 7:
      text = 'A';
      break;
    case 8:
      text = 'S';
      break;
    case 9:
      text = 'O';
      break;
    case 10:
      text = 'N';
      break;
    case 11:
      text = 'D';
      break;
    default:
      text = '';
      break;
  }

  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: Text(
      text,
      style: textstyle,
    ),
  );
}
