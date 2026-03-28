import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_dashboard/core/utils/dimensions.dart';

enum DatePeriod {
  today,
  thisWeek,
  thisMonth,
  thisYear,
  custom,
}

class PeriodSelector extends StatefulWidget {
  final DateTimeRange initialRange;
  final DatePeriod initialPeriod;
  final Function(DateTimeRange, DatePeriod) onRangeChanged;

  const PeriodSelector({
    super.key,
    required this.initialRange,
    required this.initialPeriod,
    required this.onRangeChanged,
  });

  @override
  State<PeriodSelector> createState() => _PeriodSelectorState();
}

class _PeriodSelectorState extends State<PeriodSelector> {
  late DateTimeRange _currentRange;
  late DatePeriod _currentPeriod;

  @override
  void initState() {
    super.initState();
    _currentRange = widget.initialRange;
    _currentPeriod = widget.initialPeriod;
  }

  DateTimeRange _getRangeForPeriod(DatePeriod period) {
    final now = DateTime.now();
    switch (period) {
      case DatePeriod.today:
        return DateTimeRange(start: now, end: now);
      case DatePeriod.thisWeek:
        // Monday to Sunday
        final daysFromMonday = now.weekday - DateTime.monday;
        final monday = now.subtract(Duration(days: daysFromMonday));
        final sunday = monday.add(const Duration(days: 6));
        return DateTimeRange(start: monday, end: sunday);
      case DatePeriod.thisMonth:
        final monthStart = DateTime(now.year, now.month, 1);
        return DateTimeRange(start: monthStart, end: now);
      case DatePeriod.thisYear:
        final yearStart = DateTime(now.year, 1, 1);
        return DateTimeRange(start: yearStart, end: now);
      case DatePeriod.custom:
        return _currentRange;
    }
  }

  String _getDisplayPeriodName(DatePeriod period) {
    switch (period) {
      case DatePeriod.today:
        return 'Today';
      case DatePeriod.thisWeek:
        return 'This Week';
      case DatePeriod.thisMonth:
        return 'This Month';
      case DatePeriod.thisYear:
        return 'This Year';
      case DatePeriod.custom:
        return 'Custom';
    }
  }

  String _getDisplayText(DateTimeRange range, DatePeriod period) {
    switch (period) {
      case DatePeriod.today:
        return DateFormat.yMMMMd().format(range.start);
      case DatePeriod.thisWeek:
        final weekStart = DateFormat('MMM d').format(range.start);
        final weekEnd = DateFormat('MMM d').format(range.end);
        return '$weekStart - $weekEnd';
      case DatePeriod.thisMonth:
        return DateFormat.yMMMM().format(range.start);
      case DatePeriod.thisYear:
        return DateFormat.y().format(range.start);
      case DatePeriod.custom:
        return '${DateFormat.yMMMMd().format(range.start)} - ${DateFormat.yMMMMd().format(range.end)}';
    }
  }

  Future<void> _selectCustomRange() async {
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _currentRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF00308F)),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null && mounted) {
      setState(() {
        _currentRange = pickedRange;
        _currentPeriod = DatePeriod.custom;
      });
      widget.onRangeChanged(_currentRange, _currentPeriod);
    }
  }

  Future<void> _selectSingleDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _currentRange.start,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF00308F)),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      setState(() {
        _currentRange = DateTimeRange(start: pickedDate, end: pickedDate);
        _currentPeriod = DatePeriod.today;
      });
      widget.onRangeChanged(_currentRange, _currentPeriod);
    }
  }

  void _selectPeriod(DatePeriod period) {
    if (!mounted) return;
    final newRange = _getRangeForPeriod(period);
    setState(() {
      _currentRange = newRange;
      _currentPeriod = period;
    });
    widget.onRangeChanged(_currentRange, _currentPeriod);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date display with custom range picker
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width20,
            vertical: Dimensions.height15,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(Dimensions.radius15),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: GestureDetector(
            onTap: () {
              if (_currentPeriod == DatePeriod.custom) {
                _selectCustomRange();
              } else {
                _selectSingleDate();
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: Dimensions.height10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(Dimensions.radius15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today,
                      color: Theme.of(context).primaryColor),
                  SizedBox(width: Dimensions.width10),
                  Expanded(
                    child: Text(
                      _getDisplayText(_currentRange, _currentPeriod),
                      style: TextStyle(
                        fontSize: Dimensions.font16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: Dimensions.height15),
        // Period selection chips
        SizedBox(
          height: Dimensions.height45,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              DatePeriod.today,
              DatePeriod.thisWeek,
              DatePeriod.thisMonth,
              DatePeriod.thisYear,
              DatePeriod.custom
            ]
                .map((period) {
                  final isSelected = _currentPeriod == period;
                  return Padding(
                    padding: EdgeInsets.only(right: Dimensions.width10),
                    child: ChoiceChip(
                      label: Text(
                        _getDisplayPeriodName(period),
                        style: TextStyle(fontSize: Dimensions.font14),
                      ),
                      selected: isSelected,
                      onSelected: (_) {
                        if (period == DatePeriod.custom) {
                          _selectCustomRange();
                        } else {
                          _selectPeriod(period);
                        }
                      },
                      selectedColor:
                          Theme.of(context).primaryColor.withOpacity(0.2),
                    ),
                  );
                })
                .toList(),
          ),
        ),
      ],
    );
  }
}

