import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  // Initialize the time zone database
  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Zone App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  String selectedRegion = "Australia";
  String selectedTimeZone = "Australia/Adelaide";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Zone App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder<Map<String, String>>(
              future: _getCurrentTime(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Column(
                    children: [
                      Text(
                        '${snapshot.data!['selectedTimeZoneTime']}',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${snapshot.data!['gmtTime']}',
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                // Navigate to sub-view to set region and time zone
                final result = await _navigateToTimeZoneSelection(context);
                // Update the selected region and time zone when the sub-view is closed
                if (result != null &&
                    result.containsKey('region') &&
                    result.containsKey('timeZone')) {
                  setState(() {
                    selectedRegion = result['region']!;
                    selectedTimeZone = result['timeZone']!;
                  });
                }
              },
              child: const Text(
                'Change Time Zone',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to navigate to the sub-view
  Future<Map<String, String>?> _navigateToTimeZoneSelection(
      BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              TimeZoneSelectionScreen(selectedRegion, selectedTimeZone)),
    );
  }

  // Function to get the current time in the selected time zone and GMT
  Future<Map<String, String>> _getCurrentTime() async {
    final location = tz.getLocation(selectedTimeZone);
    final now = tz.TZDateTime.now(location);
    final gmtNow = tz.TZDateTime.now(tz.UTC);

    // Get the time zone offset
    final timeZoneOffset = now.timeZoneOffset;
    final gmtOffset = gmtNow.timeZoneOffset;

    // Format the offset as "GMT+HH:mm"
    final timeZoneOffsetString =
        '${timeZoneOffset.isNegative ? 'GMT' : 'GMT+'}${timeZoneOffset.inHours}:${(timeZoneOffset.inMinutes % 60).abs().toString().padLeft(2, '0')}';

    final formatter = DateFormat.yMd().add_Hms();

    final formattedTimeZoneTime =
        '${formatter.format(now)} $timeZoneOffsetString ${location.name}';
    final formattedGMTTime =
        '${formatter.format(gmtNow)} GMT${gmtOffset.isNegative ? '-' : '+'}${gmtOffset.inHours.abs().toString().padLeft(2, '0')}:${(gmtOffset.inMinutes % 60).abs().toString().padLeft(2, '0')}';

    return {
      'selectedTimeZoneTime': 'Current Date and Time:\n$formattedTimeZoneTime',
      'gmtTime': 'GMT Time:\n$formattedGMTTime',
    };
  }
}

class TimeZoneSelectionScreen extends StatefulWidget {
  final String initialRegion;
  final String initialTimeZone;

  TimeZoneSelectionScreen(this.initialRegion, this.initialTimeZone);

  @override
  State<TimeZoneSelectionScreen> createState() =>
      _TimeZoneSelectionScreenState();
}

class _TimeZoneSelectionScreenState extends State<TimeZoneSelectionScreen> {
  late String selectedRegion;
  late String selectedTimeZone;

  @override
  void initState() {
    super.initState();
    selectedRegion = widget.initialRegion;
    selectedTimeZone = widget.initialTimeZone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Time Zone'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Select Region:'),
            DropdownButton<String>(
              value: selectedRegion,
              onChanged: (value) {
                setState(() {
                  selectedRegion = value!;
                });
              },
              items: [
                'Australia',
                // Add other regions as needed
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('Select Time Zone:'),
            DropdownButton<String>(
              value: selectedTimeZone,
              onChanged: (value) {
                setState(() {
                  selectedTimeZone = value!;
                });
              },
              items: _getTimeZonesForRegion(selectedRegion).map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Pass selected region and time zone back to the main screen
                Navigator.pop(context,
                    {'region': selectedRegion, 'timeZone': selectedTimeZone});
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getTimeZonesForRegion(String region) {
    // Add logic to fetch time zones based on the selected region
    // For simplicity, return a predefined list
    if (region == 'Australia') {
      return [
        'Australia/Sydney',
        'Australia/Melbourne',
        'Australia/Brisbane',
        'Australia/Adelaide',
        'Australia/Darwin'
      ];
    }
    // Add other regions and their time zones as needed
    return [];
  }
}
