import 'package:first_project/costume_widgets/number_selector.dart';
import 'package:first_project/models/custom_day_week.dart';
import 'package:first_project/models/recurrence_rule.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RepetitionDialog extends StatefulWidget {
  final DateTime selectedStartDate;
  final DateTime selectedEndDate;
  final RecurrenceRule? initialRecurrenceRule;

  RepetitionDialog({
    required this.selectedStartDate,
    this.initialRecurrenceRule,
    required this.selectedEndDate, // Initialize it in the constructor
  });
  @override
  _RepetitionDialogState createState() => _RepetitionDialogState();
}

class _RepetitionDialogState extends State<RepetitionDialog> {
  // Local state variables to store user input
  String selectedFrequency = 'Daily'; // Default to Daily
  int? repeatInterval = 0;
  int? dayOfMonth;
  int? selectedMonth;
  bool isForever = false; // Variable to track whether the recurrence is forever
  DateTime? untilDate;
  Set<CustomDayOfWeek> selectedDays = Set<CustomDayOfWeek>();
  String previousFrequency = 'Daily';
  late DateTime _selectedStartDate;
  late DateTime _selectedEndDate;
  List<CustomDayOfWeek> localCustomDaysOfWeek =
      customDaysOfWeek; // Initialize with customDaysOfWeek
  bool isRepeated = false;
  var validationError;

  String getWeekdayName(DateTime date) {
    final weekdayName = DateFormat('EEEE').format(date);
    return weekdayName;
  }

  @override
  void initState() {
    super.initState();
    _selectedStartDate = widget.selectedStartDate; // Initialize with the provided value
    _selectedEndDate = widget.selectedEndDate;
    // After the dialog is shown, you can print the routes
    // Fill up variables if initialRecurrenceRule is not null
    fillVariablesFromInitialRecurrenceRule(widget.initialRecurrenceRule);
  }

  // Method to fill up variables when initialRecurrenceRule is not null
  void fillVariablesFromInitialRecurrenceRule(RecurrenceRule? rule) {
    setState(() {
      if (rule != null) {
        selectedFrequency = rule.name;
        repeatInterval = rule.repeatInterval;
        dayOfMonth = rule.dayOfMonth;
        selectedMonth = rule.month;
        untilDate = rule.untilDate;
        isForever = rule.untilDate == null;
        selectedDays = Set<CustomDayOfWeek>.from(rule.daysOfWeek ?? []);
      }
    });
  }

  void _goBackToParentView(
    RecurrenceRule? recurrenceRule,
    bool? isRepetitiveUpdated,
  ) {
    setState(() {
      isRepeated = isRepetitiveUpdated!;
    });

    // Pop the dialog to return to the previous screen
    // Navigator.of(context).pop([recurrenceRule, isRepeated]);
    Navigator.of(context).pop([recurrenceRule, isRepeated]);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: () async {
      // await showDialog(
      //   context: context,
      //   builder: (BuildContext context) {
      //     return RepetitionDialog(
      //       selectedStartDate: _selectedStartDate,
      //     );
      //   },
      // );
    }, child: StatefulBuilder(
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

        // Function to validate user input
        String? validateInput() {
          switch (selectedFrequency) {
            case 'Daily':
              break;
            case 'Monthly':
              break;
            case 'Weekly':
              if (selectedDays.isEmpty) {
                return 'Please select at least one day of the week.';
              }
              final eventDayAbbreviation = CustomDayOfWeek.getPattern(
                  DateFormat('EEEE', 'en_US').format(_selectedStartDate));
              if (!selectedDays
                  .contains(CustomDayOfWeek.fromString(eventDayAbbreviation))) {
                final _selectedStartDate =
                    DateTime.now(); // Replace this with your date
                final weekdayName = getWeekdayName(_selectedStartDate);
                print('Weekday name: $weekdayName');
                return 'The day of the event is  ${weekdayName} should coincide with one of the selected days.';
              }
              break;
            case 'Yearly':
              break;
          }

          if (repeatInterval == 0) {
            return 'Please specify the repeat interval.';
          }
          if (_selectedStartDate.day != _selectedEndDate.day) {
            return 'Start and end dates must be the same day for the event to repeat';
          }
          if (untilDate == null) {
            return 'Please specify the until date.';
          }

          return null; // Input is valid
        }

        validationError = validateInput();

        // Reset the NumberSelector value when frequency changes based on the rules
        if (previousFrequency != selectedFrequency) {
          final maxRepeatValue = getMaxRepeatValue(selectedFrequency);

          if (repeatInterval! > maxRepeatValue) {
            repeatInterval = maxRepeatValue;
          }
          selectedMonth = null; // Reset selectedMonth when frequency changes
        }
        previousFrequency = selectedFrequency;

        // Define a function to build the "Repeat Every" row
        Widget buildRepeatEveryRow() {
          String repeatMessage;

          final formattedDate =
              DateFormat('d of MMMM').format(_selectedStartDate);

          // Sort the selected day names based on the custom order
          // Create a list of day names based on the selected days of the week
          final selectedDayNames = selectedDays
              .map((day) => day.toString().split('.').last)
              .toList();

          // Sort the selected day names based on the custom order
          selectedDayNames.sort((a, b) {
            final orderA = localCustomDaysOfWeek
                .firstWhere((customDay) => customDay.name == a)
                .order;
            final orderB = localCustomDaysOfWeek
                .firstWhere((customDay) => customDay.name == b)
                .order;
            return orderA.compareTo(orderB);
          });

          switch (selectedFrequency) {
            case 'Daily':
              repeatMessage =
                  'This event will repeat every $repeatInterval day';
              break;
            case 'Weekly':
              if (selectedDayNames.length > 1) {
                final lastDay = selectedDayNames.removeLast();
                final customDaysOfWeekString = selectedDayNames.join(', ');
                repeatMessage =
                    'This event will repeat every $repeatInterval week(s) on $customDaysOfWeekString, and $lastDay';
              } else if (selectedDayNames.length == 1) {
                repeatMessage =
                    'This event will repeat every $repeatInterval week(s) on ${selectedDayNames.first}';
              } else {
                repeatMessage = 'No days selected';
              }
              break;
            case 'Monthly':
              repeatMessage =
                  'This event will repeat on the $formattedDate day every $repeatInterval month(s)';
              break;
            case 'Yearly':
              repeatMessage =
                  'This event will repeat every $repeatInterval year(s) on $formattedDate day';
              break;
            default:
              repeatMessage = '';
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15.0),
              Center(
                child: Text('REPETITION DETAILS',
                    style: TextStyle(
                      fontSize: 14,
                    )),
              ), // Add space above the title
              SizedBox(height: 8.0), // Add space above the informative message
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
                    key: Key(
                        selectedFrequency), // Use the selectedFrequency as the key
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
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return AlertDialog(
          title: Center(
            child: Text('SELECT REPETITION', style: TextStyle(fontSize: 18)),
          ),
          content: SingleChildScrollView(
            // Add SingleChildScrollView here
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  children:
                      ['Daily', 'Weekly', 'Monthly', 'Yearly'].map((frequency) {
                    final isSelected = frequency == selectedFrequency;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFrequency =
                              frequency; // Update the selected frequency
                        });
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                        child:
                            Text('Select Day:', style: TextStyle(fontSize: 14)),
                      ),
                      SizedBox(height: 8), // Add some spacing
                      Wrap(
                        children: customDaysOfWeek.map<Widget>((day) {
                          final isSelected = selectedDays
                              .contains(day); // Check if the day is selected

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
                                    : const Color.fromARGB(255, 240, 239, 239),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                day.name.substring(
                                    0, 3), // Use day.name to get the day's name
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                // Optional input for day of month (for Daily)
                if (selectedFrequency == 'Daily') buildRepeatEveryRow(),
                if (selectedFrequency == 'Monthly') buildRepeatEveryRow(),
                if (selectedFrequency == 'Yearly') buildRepeatEveryRow(),
                // Row(
                //   children: <Widget>[
                //     Checkbox(
                //       value: isForever,
                //       onChanged: (bool? newValue) {
                //         setState(() {
                //           isForever = newValue ?? false;
                //           if (isForever) {
                //             untilDate =
                //                 null; // If forever is selected, clear the until date
                //           }
                //         });
                //       },
                //     ),
                //     Text('Repeats Forever', style: TextStyle(fontSize: 14)),
                //   ],
                // ),
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

                SizedBox(height: 10),

                // Display validation error message if applicable
                if (validationError != null)
                  Text(
                    validationError,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 15, // Display error message in red
                    ),
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                _goBackToParentView(null, false);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
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
                      selectedDays
                          .toList(), // Pass the selected days of the week here
                      repeatInterval: repeatInterval,
                      untilDate: isForever ? null : untilDate,
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
                      month: selectedMonth, // Provide the selected month here
                      dayOfMonth: dayOfMonth,
                      repeatInterval: repeatInterval,
                      untilDate: isForever
                          ? null
                          : untilDate, // Check if "Forever" is selected
                    );
                    break;
                  default:
                    recurrenceRule = RecurrenceRule.daily(); // Default to Daily
                }

                // Now you can use recurrenceRule as needed (e.g., store it or apply it to an Event object)
                // Now you have the recurrenceRule instance based on user input
                print('Recurrence Rule: ${recurrenceRule}');
                print('Recurrence Rule: ${recurrenceRule.name}');
                print('Repeat Interval: ${recurrenceRule.repeatInterval}');
                print('Until Date: ${recurrenceRule.untilDate}');

                //If it's null, it means the input is valid
                if (validationError == null) {
                  _goBackToParentView(recurrenceRule, true);
                }
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    ));
  }
}
