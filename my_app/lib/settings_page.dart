import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key, required this.onTemperatureUnitChanged, required this.isFahrt}) : super(key: key);
  final Function(bool) onTemperatureUnitChanged;
  final bool isFahrt;
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _isCelsius;

  @override
  void initState() {
    super.initState();
    _loadTemperatureUnit();
  }

  Future<void> _loadTemperatureUnit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isCelsius = prefs.getBool('isCelsius') ?? true;
    });
  }

  void _saveTemperatureUnit(bool isCelsius) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isCelsius', isCelsius);
    widget.onTemperatureUnitChanged(!isCelsius);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Temperature Unit',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: const Text('Celsius'),
              leading: Radio<bool>(
                value: true,
                groupValue: _isCelsius,
                onChanged: (bool? value) {
                  setState(() {
                    _isCelsius = value ?? true;
                  });
                  _saveTemperatureUnit(true);
                },
              ),
            ),
            ListTile(
              title: const Text('Fahrenheit'),
              leading: Radio<bool>(
                value: false,
                groupValue: _isCelsius,
                onChanged: (bool? value) {
                  setState(() {
                    _isCelsius = value ?? true;
                  });
                  _saveTemperatureUnit(false);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}