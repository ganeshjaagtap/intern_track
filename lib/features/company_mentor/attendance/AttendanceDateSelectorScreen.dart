import 'package:flutter/material.dart';

class AttendanceDateSelectorScreen extends StatefulWidget {

  final DateTime currentDate;

  const AttendanceDateSelectorScreen({
    super.key,
    required this.currentDate,
  });

  @override
  State<AttendanceDateSelectorScreen> createState() =>
      _AttendanceDateSelectorScreenState();
}

class _AttendanceDateSelectorScreenState
    extends State<AttendanceDateSelectorScreen> {

  late int selectedMonth;
  late int selectedYear;

  final List<String> months = const [
    "January","February","March","April","May","June",
    "July","August","September","October","November","December"
  ];

  final List<int> years = [2024, 2025, 2026, 2027];

  @override
  void initState() {
    super.initState();

    selectedMonth = widget.currentDate.month;
    selectedYear = widget.currentDate.year;
  }

  int _daysInMonth(int y, int m) =>
      DateTime(y, m + 1, 0).day;

  int _startOffset(int y, int m) =>
      DateTime(y, m, 1).weekday % 7;

  bool _isFutureDate(int y, int m, int d) {
    DateTime selected = DateTime(y, m, d);
    return selected.isAfter(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {

    final int days = _daysInMonth(selectedYear, selectedMonth);
    final int offset = _startOffset(selectedYear, selectedMonth);

    return Scaffold(

      appBar: AppBar(
        title: const Text("Select Date"),
        backgroundColor: const Color(0xFF6BB6FF),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            /// MONTH + YEAR SELECTOR
            Row(
              children: [

                Expanded(
                  child: DropdownButton<int>(
                    value: selectedMonth,
                    isExpanded: true,

                    items: List.generate(
                      12,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text(months[i]),
                      ),
                    ),

                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          selectedMonth = v;
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: DropdownButton<int>(
                    value: selectedYear,
                    isExpanded: true,

                    items: years.map(
                      (y) => DropdownMenuItem(
                        value: y,
                        child: Text(y.toString()),
                      ),
                    ).toList(),

                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          selectedYear = v;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// WEEKDAY HEADER
            Row(
              children: const [
                "Sun","Mon","Tue","Wed","Thu","Fri","Sat"
              ].map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ).toList(),
            ),

            const SizedBox(height: 10),

            /// CALENDAR GRID
            Expanded(
              child: GridView.builder(

                itemCount: offset + days,

                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),

                itemBuilder: (context, index) {

                  if (index < offset) {
                    return const SizedBox();
                  }

                  final int day = index - offset + 1;

                  bool isFuture =
                      _isFutureDate(selectedYear, selectedMonth, day);

                  return InkWell(

                    onTap: isFuture
                        ? null
                        : () {

                            Navigator.pop(
                              context,
                              DateTime(selectedYear, selectedMonth, day),
                            );

                          },

                    child: Container(

                      decoration: BoxDecoration(
                        color: isFuture
                            ? Colors.grey.shade300
                            : Colors.blue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),

                      child: Center(
                        child: Text(
                          "$day",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isFuture
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}