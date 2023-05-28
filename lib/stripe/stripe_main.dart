import 'package:flutter/material.dart';
import 'package:flutter_restaurant/stripe/pages/cards.dart';
import 'package:flutter_restaurant/stripe/pages/home.dart';

// void main() => runApp(StripePayment());

class StripePayment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => HomePage(),
        '/existing-cards': (context) => ExistingCardsPage()
      },
    );
  }
}
