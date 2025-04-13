import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class DatePickersWidget extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback onStartDateTap;
  final VoidCallback onEndDateTap;

  const DatePickersWidget({
    required this.startDate,
    required this.endDate,
    required this.onStartDateTap,
    required this.onEndDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return _buildDatePickers(context);
  }

  Widget _buildDatePickers(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 1,
            child: _buildDatePicker(context, true, startDate, onStartDateTap),
          ),
          SizedBox(width: 10),
          Flexible(
            flex: 1,
            child: _buildDatePicker(context, false, endDate, onEndDateTap),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, bool isStartDate,
      DateTime selectedDate, VoidCallback onTap) {
    String dateTitle = isStartDate
        ? AppLocalizations.of(context)!.startDate
        : AppLocalizations.of(context)!.endDate;
    Color backgroundColor = isStartDate
        ? Color.fromARGB(255, 92, 206, 134)
        : Color.fromARGB(255, 223, 106, 106);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Text(
            dateTitle,
            style: TextStyle(fontSize: 15, color: Colors.black),
          ),
        ),
        SizedBox(height: 8.0),
        InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                DateFormat('yyyy-MM-dd').format(selectedDate),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white),
              ),
              Text(
                DateFormat('hh:mm a').format(selectedDate),
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 28, 58, 82)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
