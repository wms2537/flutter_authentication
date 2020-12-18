import 'package:flutter/material.dart';
import 'package:flutter_authentication/screens/home_screen.dart';
import 'package:flutter_authentication/screens/signup_screen.dart';
import 'package:provider/provider.dart';

import './screens/splash_screen.dart';
import './providers/products.dart';
import './providers/auth.dart';
import './screens/auth_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (_) => Products(),
          update: (ctx, auth, previousProducts) {
            previousProducts.setCredentials(
              auth.token,
              auth.userId,
            );
            return previousProducts;
          },
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Flutter Auth',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            accentColor: Colors.blueAccent,
            fontFamily: 'Lato',
          ),
          home: auth.isAuth
              ? HomeScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            HomeScreen.routeName : (ctx) => HomeScreen(),
            AuthScreen.routeName: (ctx) => AuthScreen(),
            SignUpScreen.routeName: (ctx) => SignUpScreen()
          },
        ),
      ),
    );
  }
}
