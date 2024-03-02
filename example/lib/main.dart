import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tx_dio_interceptor/tx_dio_interceptor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dio = Dio();

  bool _refreshToken() {
    return true;
  }

  void _configureDio() {
    final refreshTokenInterceptor = TXRefreshTokenInterceptor(
        dio: dio,
        onRefreshToken: () async {
          return _refreshToken();
        },
        shouldRefreshToken: (response) {
          return response.statusCode == 401;
        },
        onRefreshTokenFailed: (response) async {
          //refresh token failed
        });

    //Add interceptor
    dio.interceptors.add(refreshTokenInterceptor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Tap Button to test',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _configureDio,
        tooltip: 'Test button',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
