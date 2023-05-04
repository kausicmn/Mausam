import 'package:flutter/material.dart';

class EmptySearchPage extends StatelessWidget {
  const EmptySearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: const Center(
        child: Text(
          'Search functionality not implemented yet.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
