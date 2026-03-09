import 'package:flutter/material.dart';

class CalendarDayTile extends StatelessWidget {
  final int day;
  final bool hasEvent;
  final Color? eventColor;   // ✅ NEW
  final VoidCallback onTap;

  const CalendarDayTile({
    super.key,
    required this.day,
    required this.hasEvent,
    required this.onTap,
    this.eventColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: hasEvent
              ? eventColor!.withOpacity(0.2)   // 🔥 dynamic light color
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: hasEvent
                    ? eventColor
                    : Colors.black,
              ),
            ),
            if (hasEvent)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: eventColor,
                  shape: BoxShape.circle,
                ),
              )
          ],
        ),
      ),
    );
  }
}