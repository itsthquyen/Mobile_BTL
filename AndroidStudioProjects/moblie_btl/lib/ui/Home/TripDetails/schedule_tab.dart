
import 'package:flutter/material.dart';

import 'add_schedule.dart';

class ScheduleTabContent extends StatelessWidget {
  const ScheduleTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Icon(
            Icons.manage_search_rounded,
            size: 80,
            color: accentGoldColor.withOpacity(0.8),
          ),
          const SizedBox(height: 16),
          const Text(
            "No Schedule Yet",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Add a schedule by tapping on the "+" to start tracking and splitting your schedules',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
