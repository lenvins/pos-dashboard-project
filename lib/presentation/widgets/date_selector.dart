import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_dashboard/core/utils/dimensions.dart';

class DateSelector extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  _DateSelectorState createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
  }

  void _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: Color(0xFF00308F)),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
      widget.onDateChanged(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_left, size: Dimensions.iconSize20),
          onPressed: () {
            setState(() {
              selectedDate = selectedDate.subtract(const Duration(days: 1));
            });
            widget.onDateChanged(selectedDate);
          },
        ),
        SizedBox(width: Dimensions.width20),
        Expanded(
          child: GestureDetector(
            onTap: () => _selectDate(context),
            child: Text(
              DateFormat.yMMMMd().format(selectedDate),
              style: TextStyle(
                fontSize: Dimensions.font18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center, // Center the text within the expanded space
            ),
          ),
        ),
        SizedBox(width: 20),
        IconButton(
          icon: Icon(Icons.arrow_right, size: Dimensions.iconSize20),
          onPressed: () {
            setState(() {
              selectedDate = selectedDate.add(const Duration(days: 1));
            });
            widget.onDateChanged(selectedDate);
          },
        ),
      ],
    );
  }
}

