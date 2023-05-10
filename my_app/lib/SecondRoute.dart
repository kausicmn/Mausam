// ignore: file_names
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:country_state_city_picker/country_state_city_picker.dart';

void main() {
  runApp(const SecondPage());
}

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  State<SecondPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<SecondPage> {
  String searchValue = '';
  SharedPreferences? prefs;
  List<String> _searchHistory = ['Chico'];
  String countryValue = '';
  String stateValue = '';
  String cityValue = '';

  void _addHistory(String element) async {
    if (_searchHistory.length > 0) {
      _searchHistory.add(element);
      await prefs?.setStringList('searchHistory', _searchHistory!);
    }
    setState(() {});
  }

  void _getHistory() async {
    prefs = await SharedPreferences.getInstance();
    bool typeing = false;
    List<String>? searchHistoryRecord = prefs?.getStringList('searchHistory');
    setState(() {
      if (searchHistoryRecord == null) {
        _searchHistory = ['Chico'];
      } else {
        _searchHistory = searchHistoryRecord;
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getHistory();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Locations',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Select Location'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MyApp(
                            given_city: '',
                          )),
                );
                // focus the search bar
              },
            ),
          ),
          body: Column(
            children: [
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  height: 300,
                  child: Column(
                    children: [
                      SelectState(
                        onCountryChanged: (value) {
                          setState(() {
                            countryValue = value;
                          });
                        },
                        onStateChanged: (value) {
                          setState(() {
                            stateValue = value;
                          });
                        },
                        onCityChanged: (value) {
                          setState(() {
                            cityValue = value;
                          });
                        },
                      ),
                      InkWell(
                          onTap: () {
                            // print('country selected is $countryValue');
                            // print('country selected is $stateValue');
                            // print('country selected is $cityValue');
                          },
                          child: TextButton(
                            style: TextButton.styleFrom(
                              primary: Colors.blue,
                            ),
                            onPressed: () {
                              if (cityValue != '') {
                                _addHistory(cityValue);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          MyApp(given_city: cityValue)),
                                );
                              }
                            },
                            child: const Text('Show Weather'),
                          ))
                    ],
                  )),
              Expanded(
                child: ListView.builder(
                  itemCount:
                      _searchHistory.length, // number of items in the list
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      // display index number in a circle avatar
                      title: Text(_searchHistory[index]),
                      //subtitle: Text('Description of Item ${index + 1}'),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MyApp(given_city: _searchHistory[index])),
                        );
                        // handle onTap event
                        if (kDebugMode) {
                          print('You tapped on Item ${index + 1}');
                        }
                      },
                    );
                  },
                ),
              )
            ],
          )),
    );
  }
}
