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

  @override
  Widget build(BuildContext context) {
    return BarChart(BarChartData(
      minY: 0,
      maxY: 100,
    ));
  }
}
