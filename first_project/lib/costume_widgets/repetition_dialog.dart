import 'package:first_project/costume_widgets/number_selector.dart';
import 'package:first_project/enums/days_week.dart';
import 'package:first_project/models/recurrence_rule.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RepetitionDialog extends StatefulWidget {
  final DateTime selectedStartDate;

  RepetitionDialog({required this.selectedStartDate});
  @override
  _RepetitionDialogState createState() => _RepetitionDialogState();
}

class _RepetitionDialogState extends State<RepetitionDialog> {
  // Local state variables to store user input
  String selectedFrequency = 'Daily'; // Default to Daily
  int? repeatInterval;
  int? dayOfMonth;
  int? selectedMonth;
  bool isForever = false; // Variable to track whether the recurrence is forever
  DateTime? untilDate;
  Set<DayOfWeek> selectedDays = Set<DayOfWeek>();


  String previousFrequency = 'Daily';

  late DateTime _selectedStartDate;

  @override
  void initState() {
    super.initState();
    _selectedStartDate =
        widget.selectedStartDate; // Initialize with the provided value
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRepetitionDialog(context);
    });
  }

  void _showRepetitionDialog(BuildContext context) {
    // Local state variables to store user input
    String selectedFrequency = 'Daily'; // Default to Daily
    int? repeatInterval = 0;
    int? dayOfMonth;
    int? selectedMonth;
    bool isForever =
        false; // Variable to track whether the recurrence is forever
    DateTime? untilDate;
    Set<DayOfWeek> selectedDays = Set<DayOfWeek>();

    String previousFrequency = selectedFrequency;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // Function to get the maximum repeat value based on the selected frequency
            int getMaxRepeatValue(String frequency) {
              switch (frequency) {
                case 'Daily':
                  return 500;
                case 'Weekly':
                  return 18;
                case 'Monthly':
                  return 18;
                case 'Yearly':
                  return 10;
                default:
                  return 0;
              }
            }

           // Define a function to build the "Repeat Every" row
Widget buildRepeatEveryRow() {
  String repeatMessage;
  
  // Check if the previous and selected frequencies are different
  if (previousFrequency != selectedFrequency) {
    repeatInterval = 0; // Reset to 0 when changing between daily and other options
  }
  
  switch (selectedFrequency) {
    case 'Daily':
      repeatMessage = 'This event will repeat every $repeatInterval day';
      break;
    case 'Weekly':
      repeatMessage = 'This event will repeat every $repeatInterval week(s) (on days of the week)';
      break;
    case 'Monthly':
      repeatMessage = 'This event will repeat on the $dayOfMonth day every $repeatInterval month(s)';
      break;
    case 'Yearly':
      repeatMessage = 'This event will repeat every $repeatInterval year(s) on $_selectedStartDate day';
      break;
    default:
      repeatMessage = '';
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 8.0), // Add space above the title
      Text(
        'Repetition Details:',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(
          height: 8.0), // Add space above the informative message
      Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0), // Add padding
        child: Text(
          repeatMessage,
          style: TextStyle(
            fontSize: 14,
          ),
        ),
      ),
      Row(
        children: [
          Text(
            'Every: ',
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          // Recreate the NumberSelector widget with a new key
          NumberSelector(
            key: Key(selectedFrequency), // Use the selectedFrequency as the key
            value: repeatInterval,
            minValue: 0,
            maxValue: getMaxRepeatValue(selectedFrequency),
            onChanged: (value) {
              setState(() {
                repeatInterval = value;
              });
            },
          ),
          Text(
            ' ${selectedFrequency.toLowerCase()}(s)',
            style: TextStyle(
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    ],
  );
}

            return AlertDialog(
              title: Text('Select Repetition'),
              content: SingleChildScrollView(
                // Add SingleChildScrollView here
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Text('Select Frequency:',
                          style: TextStyle(fontSize: 14)),
                    ),
                    SizedBox(height: 8), // Add some spacing
                    Wrap(
                      children: ['Daily', 'Weekly', 'Monthly', 'Yearly']
                          .map((frequency) {
                        final isSelected = frequency == selectedFrequency;

                        // Reset the NumberSelector value when frequency changes
                        if (previousFrequency != selectedFrequency) {
                          repeatInterval =
                              0; // You may need to adjust this value based on your requirements
                          selectedMonth =
                              null; // Reset selectedMonth when frequency changes
                        }

                        previousFrequency = selectedFrequency;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedFrequency =
                                  frequency; // Update the selected frequency
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            margin: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: isSelected
                                  ? Colors.blue
                                  : Color.fromARGB(255, 212, 234, 248),
                            ),
                            child: Text(
                              frequency,
                              style: TextStyle(
                                fontSize: 13, // Adjust the font size here
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    // Add the day selection row if selectedFrequency is 'Weekly'
                    if (selectedFrequency == 'Weekly') buildRepeatEveryRow(),
                    // Add the day selection row if selectedFrequency is not Daily, Monthly, or Yearly
                    if (selectedFrequency != 'Daily' &&
                        selectedFrequency != 'Monthly' &&
                        selectedFrequency != 'Yearly')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Center(
                            child: Text('Select Day:',
                                style: TextStyle(fontSize: 14)),
                          ),
                          SizedBox(height: 8), // Add some spacing
                          Wrap(
                            children: DayOfWeek.values.map((day) {
                              final isSelected = selectedDays.contains(
                                  day); // Check if the day is selected

                              // Define the tap handler to toggle day selection
                              void toggleDaySelection() {
                                setState(() {
                                  if (isSelected) {
                                    selectedDays.remove(day);
                                  } else {
                                    selectedDays.add(day);
                                  }
                                });
                              }

                              return GestureDetector(
                                onTap:
                                    toggleDaySelection, // Use the defined tap handler
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  margin: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? Colors.blue
                                        : const Color.fromARGB(
                                            255, 240, 239, 239),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    day.displayName.substring(0, 3),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    // Optional input for day of month (for Daily)
                    if (selectedFrequency == 'Daily') buildRepeatEveryRow(),
                    // Optional input for day of month (for Monthly and Yearly)
                    // buildSelectedDayRow(),
                    // Add the 'Repeat Every' row if selectedFrequency is 'Monthly'
                    if (selectedFrequency == 'Monthly') buildRepeatEveryRow(),
                    // buildMonthlyRepeatEveryRow() ,
                    // Add the 'Repeat Every' row if selectedFrequency is 'Yearly'
                    if (selectedFrequency == 'Yearly') buildRepeatEveryRow(),
                    // buildYearlyRepeatEveryRow(),
                    // Row for "Repeats Forever" checkbox
                    Row(
                      children: <Widget>[
                        Checkbox(
                          value: isForever,
                          onChanged: (bool? newValue) {
                            setState(() {
                              isForever = newValue ?? false;
                              if (isForever) {
                                untilDate =
                                    null; // If forever is selected, clear the until date
                              }
                            });
                          },
                        ),
                        Text('Repeats Forever', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    // Row for "Repeats Until" and date picker
                    Row(children: [
                      Checkbox(
                        value: !isForever,
                        onChanged: (bool? newValue) {
                          setState(() {
                            isForever = !(newValue ?? false);
                          });
                        },
                      ),
                      Text('Repeats Until: ', style: TextStyle(fontSize: 14)),
                      if (!isForever)
                        InkWell(
                          onTap: () async {
                            final selectedDate = await showDatePicker(
                              context: context,
                              initialDate: untilDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(DateTime.now().year +
                                  10), // Adjust the date range as needed
                            );

                            if (selectedDate != null) {
                              setState(() {
                                untilDate = selectedDate;
                              });
                            }
                          },
                          child: Text(
                            'Select Date',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue, // Change the text color here
                              decoration: TextDecoration
                                  .underline, // Add underlining for a clickable look
                            ),
                          ),
                        ),
                    ]),
                    // Display the selected "Until Date"
                    if (!isForever)
                      Text(
                        untilDate == null
                            ? 'Until Date: Not Selected'
                            : 'Until Date: ${DateFormat('yyyy-MM-dd').format(untilDate!)}', // Format the date
                        style: TextStyle(fontSize: 14),
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Create a RecurrenceRule based on user input
                    RecurrenceRule recurrenceRule;

                    switch (selectedFrequency) {
                      case 'Daily':
                        recurrenceRule = RecurrenceRule.daily(
                          repeatInterval: repeatInterval,
                          untilDate: isForever
                              ? null
                              : untilDate, // Check if "Forever" is selected
                        );
                        break;
                      case 'Weekly':
                        recurrenceRule = RecurrenceRule.weekly(
                          null, // You can add logic here to select a day of the week
                          repeatInterval: repeatInterval,
                          untilDate: isForever
                              ? null
                              : untilDate, // Check if "Forever" is selected
                        );
                        break;
                      case 'Monthly':
                        recurrenceRule = RecurrenceRule.monthly(
                          dayOfMonth: dayOfMonth,
                          repeatInterval: repeatInterval,
                          untilDate: isForever
                              ? null
                              : untilDate, // Check if "Forever" is selected
                        );
                        break;
                      case 'Yearly':
                        recurrenceRule = RecurrenceRule.yearly(
                          month:
                              selectedMonth, // Provide the selected month here
                          dayOfMonth: dayOfMonth,
                          repeatInterval: repeatInterval,
                          untilDate: isForever
                              ? null
                              : untilDate, // Check if "Forever" is selected
                        );
                        break;
                      default:
                        recurrenceRule =
                            RecurrenceRule.daily(); // Default to Daily
                    }

                    // Now you can use recurrenceRule as needed (e.g., store it or apply it to an Event object)

                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Optional: You can also add some logic here if needed
      },
    );
  }
}
