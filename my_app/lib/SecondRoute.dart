import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  List<String> _searchHistory=['Chico'];

  void _addHistory(String element) async{
    if(_searchHistory.length> 0){
      _searchHistory.add(element);
      await prefs?.setStringList('searchHistory', _searchHistory!);
    }
    setState(() {
    });
  }

  void _getHistory() async {
    prefs = await SharedPreferences.getInstance();
    bool typeing=false;
    List<String>? searchHistoryRecord = prefs?.getStringList('searchHistory');
    setState(() {
      if (searchHistoryRecord == null) {
        _searchHistory = ['Chico'];
      } else {
        _searchHistory = searchHistoryRecord;
      }
    });
  }


  final List<String> _SupportedCity = [
    'Chico',
    'Sacramento',
    'Algeria',
    'Australia',
    'Brazil',
    'German',
    'Madagascar',
    'Mozambique',
    'Portugal',
    'Zambia',
    'Madagascar',
    'Mozambique',
    'Portugal',
    'Zambia',
  ];



  String _searchValue = '';


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getHistory();

  }

  final TextEditingController _textController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Locations',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _textController,
            decoration: InputDecoration(
              hintText: 'Enter Location',
            ),
            onChanged: (value) {
              setState(() {
                _searchValue = value;
              });
            },
            onSubmitted: (value) {
              setState(() {
                _addHistory(value);
              });
              // Handle the submission here, such as performing a search
            },
          ),
          leading: IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // focus the search bar
            },

          ),
          actions: [
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                _textController.clear();
                // clear the search bar and results
              },
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: _searchHistory.length, // number of items in the list
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              leading: CircleAvatar(
                child: Text('${index + 1}'),
              ),
              // display index number in a circle avatar
              title: Text(_searchHistory[index]),
              //subtitle: Text('Description of Item ${index + 1}'),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                // handle onTap event
                print('You tapped on Item ${index + 1}');
              },
            );
          },
        ),
      ),
    );
  }
}
