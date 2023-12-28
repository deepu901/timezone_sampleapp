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
  _MyHomePageState createState() => _MyHomePageState();
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
            const Text(
              'Currently Selected Time Zone:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
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
              child: FutureBuilder<String>(
                future: _getCurrentTime(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Text(
                      '$selectedRegion\n$selectedTimeZone\n${snapshot.data}',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    );
                  }
                },
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

  // Function to get the current time in the selected time zone
  Future<String> _getCurrentTime() async {
    final location = tz.getLocation(selectedTimeZone);
    final now = tz.TZDateTime.now(location);
    final formatter = DateFormat.yMd().add_Hms();
    final formattedTime = formatter.format(now);
    return 'Current Date and Time:\n$formattedTime';
  }
}

class TimeZoneSelectionScreen extends StatefulWidget {
  final String initialRegion;
  final String initialTimeZone;

  TimeZoneSelectionScreen(this.initialRegion, this.initialTimeZone);

  @override
  _TimeZoneSelectionScreenState createState() =>
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
            // Add widgets for selecting region and time zone
            // For simplicity, you can use DropdownButton or other widgets
            const Text('Select Region:'),
            // Add widgets for region selection
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
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            const Text('Select Time Zone:'),
            // Add widgets for time zone selection
            DropdownButton<String>(
              value: selectedTimeZone,
              onChanged: (value) {
                setState(() {
                  selectedTimeZone = value!;
                });
              },
              items: _getTimeZonesForRegion(selectedRegion)
                  .map<DropdownMenuItem<String>>((String value) {
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
        'Australia/Adelaide'
      ];
    }
    // Add other regions and their time zones as needed
    return [];
  }
}
