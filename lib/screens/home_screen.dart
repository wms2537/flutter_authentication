import 'package:flutter/material.dart';
import 'package:flutter_authentication/widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
      ),
      drawer: AppDrawer(),
      body: Center(child: Text('Hello World')),
    );
  }
}
