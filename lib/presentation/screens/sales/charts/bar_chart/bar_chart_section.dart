import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_dashboard/presentation/controllers/top_dashboard_controller.dart';
import 'bar_chart_widget.dart';

class BarChartSection extends StatefulWidget {
  const BarChartSection({super.key});

  @override
  State<BarChartSection> createState() => _BarChartSectionState();
}

class _BarChartSectionState extends State<BarChartSection> {
  final TopDashboardController topDashboardController =
      Get.find<TopDashboardController>();
  late List<DateTime> visibleDates;
  late DateTime selectedDate;
  late int currentHour;

  @override
  void initState() {
    super.initState();
    _initializeDates();
  }

  void _initializeDates() {
    selectedDate = DateTime.now();
    currentHour = selectedDate.hour;
    _updateVisibleDates();
  }

  void _updateVisibleDates() {
    // Get previous, current, and next hour
    visibleDates = List.generate(3, (index) {
      int hour = (currentHour - 1 + index) % 24;
      return DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        hour,
      );
    });
  }

  List<double> _parseHourlyData(String? barchartData) {
    if (barchartData == null) return List.filled(24, 0.0);
    final values = barchartData.split(',');
    if (values.length < 24) {
      return [
        ...values.map((v) => double.tryParse(v) ?? 0.0),
        ...List.filled(24 - values.length, 0.0),
      ];
    }
    return values.map((v) => double.tryParse(v) ?? 0.0).toList();
  }

  List<double> _getVisibleValues(List<double> allValues) {
    // Get values for previous, current, and next hour
    return List.generate(3, (index) {
      int hour = (currentHour - 1 + index) % 24;
      return allValues[hour];
    });
  }

  void _onSwipeLeft() {
    setState(() {
      currentHour = (currentHour + 1) % 24;
      _updateVisibleDates();
    });
  }

  void _onSwipeRight() {
    setState(() {
      currentHour = (currentHour - 1) % 24;
      if (currentHour < 0) currentHour = 23;
      _updateVisibleDates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TopDashboardController>(
      builder: (controller) {
        final allHourlyValues = _parseHourlyData(controller.barchartPerHour);
        final visibleValues = _getVisibleValues(allHourlyValues);

        return GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! > 0) {
              _onSwipeRight();
            } else if (details.primaryVelocity! < 0) {
              _onSwipeLeft();
            }
          },
          child: SizedBox(
            height: 280,
            child: BarChartWidget(
              dates: visibleDates,
              values: visibleValues,
              selectedDate: selectedDate,
              currentHour: currentHour,
            ),
          ),
        );
      },
    );
  }
}
