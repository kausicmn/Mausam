import 'package:flutter/material.dart';

class EmptyMapPage extends StatelessWidget {
  const EmptyMapPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: const Center(
        child: Text(
          'Map functionality not implemented yet.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
