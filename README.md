```dart
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

```

