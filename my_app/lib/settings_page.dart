import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final bool isFahrenheit;
  final void Function(bool) onTemperatureUnitChanged;

  const SettingsPage({
    Key? key,
    required this.isFahrenheit,
    required this.onTemperatureUnitChanged,
  }) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isFahrenheit = false;

  @override
  void initState() {
    super.initState();
    _isFahrenheit = widget.isFahrenheit;
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
            const Text(
              'Temperature Unit',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                ListTile(
                  leading: Radio(
                    value:
                        false, // This represents the value of the Radio button itself
                    groupValue:
                        _isFahrenheit, // This represents the currently selected value in the group
                    onChanged: (bool? value) {
                      setState(() {
                        _isFahrenheit = value!;
                      });
                      widget.onTemperatureUnitChanged(_isFahrenheit);
                      Navigator.pop(context, _isFahrenheit);
                    },
                  ),
                  title: Text('Celsius'),
                ),
                ListTile(
                  leading: Radio(
                    value: true,
                    groupValue: _isFahrenheit,
                    onChanged: (bool? value) {
                      setState(() {
                        _isFahrenheit = value!;
                      });
                      widget.onTemperatureUnitChanged(_isFahrenheit);
                      Navigator.pop(context, _isFahrenheit);
                    },
                  ),
                  title: const Text('Fahrenheit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
