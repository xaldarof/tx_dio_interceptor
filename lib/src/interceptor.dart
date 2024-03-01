import 'package:dio/dio.dart';

class TXRefreshTokenInterceptor extends InterceptorsWrapper {
  final Dio dio;
  final Future<bool> Function() onRefreshToken;
  final RequestOptions Function(RequestOptions options, RequestInterceptorHandler handler)?
  onRequestCallBack;
  final bool Function(Response response) shouldRefreshToken;
  final Function(Response response) onRefreshTokenFailed;

  TXRefreshTokenInterceptor({
    required this.dio,
    required this.onRefreshToken,
    this.onRequestCallBack,
    required this.shouldRefreshToken,
    required this.onRefreshTokenFailed,
  });

  bool _isRefreshing = false;

  final _requestsNeedRetry = <_Request>[];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (onRequestCallBack != null) options = onRequestCallBack!(options, handler);

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (shouldRefreshToken(response)) {
      if (!_isRefreshing) {
        _isRefreshing = true;

        _requestsNeedRetry.add(_Request(options: response.requestOptions, handler: handler));

        final isRefreshSuccess = await onRefreshToken();

        _isRefreshing = false;

        if (isRefreshSuccess) {
          for (var requestNeedRetry in _requestsNeedRetry) {
            final retry = await dio.fetch(requestNeedRetry.options);
            requestNeedRetry.handler.resolve(retry);
          }
          _requestsNeedRetry.clear();
        } else {
          onRefreshTokenFailed.call(response);
          _requestsNeedRetry.clear();
        }
      } else {
        _requestsNeedRetry.add(_Request(options: response.requestOptions, handler: handler));
      }
    } else {
      return handler.next(response);
    }
  }
}

class _Request {
  final RequestOptions options;
  final ResponseInterceptorHandler handler;

  const _Request({
    required this.options,
    required this.handler,
  });
}
