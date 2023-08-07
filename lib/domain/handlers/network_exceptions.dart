import 'dart:io';

import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_exceptions.freezed.dart';

@freezed
class NetworkExceptions with _$NetworkExceptions {
  const factory NetworkExceptions.requestCancelled() = RequestCancelled;

  const factory NetworkExceptions.unauthorisedRequest() = UnauthorisedRequest;

  const factory NetworkExceptions.badRequest() = BadRequest;

  const factory NetworkExceptions.notFound(String reason) = NotFound;

  const factory NetworkExceptions.methodNotAllowed() = MethodNotAllowed;

  const factory NetworkExceptions.notAcceptable() = NotAcceptable;

  const factory NetworkExceptions.requestTimeout() = RequestTimeout;

  const factory NetworkExceptions.sendTimeout() = SendTimeout;

  const factory NetworkExceptions.conflict() = Conflict;

  const factory NetworkExceptions.internalServerError() = InternalServerError;

  const factory NetworkExceptions.notImplemented() = NotImplemented;

  const factory NetworkExceptions.serviceUnavailable() = ServiceUnavailable;

  const factory NetworkExceptions.noInternetConnection() = NoInternetConnection;

  const factory NetworkExceptions.formatException() = FormatException;

  const factory NetworkExceptions.unableToProcess() = UnableToProcess;

  const factory NetworkExceptions.defaultError(String error) = DefaultError;

  const factory NetworkExceptions.unexpectedError() = UnexpectedError;

  static NetworkExceptions getDioException(error) {
    if (error is Exception) {
      try {
        if (error is DioError) {
          switch (error.type) {
            case DioErrorType.cancel:
              break;
            case DioErrorType.connectionTimeout:
              break;
            case DioErrorType.unknown:
              break;
            case DioErrorType.receiveTimeout:
              break;
            case DioErrorType.badResponse:
              switch (error.response!.statusCode) {
                case 400:
                  break;
                case 401:
                  break;
                case 403:
                  break;
                case 404:
                  break;
                case 409:
                  break;
                case 408:
                  break;
                case 500:
                  break;
                case 503:
                  break;
                default:
              }
              break;
            case DioErrorType.sendTimeout:
              break;
            case DioErrorType.badCertificate:
              // TODO: Handle this case.
              break;
            case DioErrorType.connectionError:
              // TODO: Handle this case.
              break;
          }
        } else if (error is SocketException) {
        } else {
        }
        return const NetworkExceptions.noInternetConnection();
      } on FormatException catch (_) {
        return const NetworkExceptions.formatException();
      } catch (_) {
        return const NetworkExceptions.unexpectedError();
      }
    } else {
      if (error.toString().contains("is not a subtype of")) {
        return const NetworkExceptions.unableToProcess();
      } else {
        return const NetworkExceptions.unexpectedError();
      }
    }
  }

  static int getDioStatus(error) {
    if (error is Exception) {
      try {
        int? status;
        if (error is DioError) {
          switch (error.type) {
            case DioErrorType.cancel:
              status = 500;
              break;
            case DioErrorType.connectionTimeout:
              status = 500;
              break;
            case DioErrorType.unknown:
              status = 500;
              break;
            case DioErrorType.receiveTimeout:
              status = 500;
              break;
            case DioErrorType.badResponse:
              switch (error.response!.statusCode) {
                case 400:
                  status = 400;
                  break;
                case 401:
                  status = 401;
                  break;
                case 403:
                  status = 403;
                  break;
                case 404:
                  status = 404;
                  break;
                case 409:
                  status = 409;
                  break;
                case 422:
                  status = 422;
                  break;
                case 408:
                  status = 408;
                  break;
                case 500:
                  status = 500;
                  break;
                case 503:
                  status = 503;
                  break;
                default:
                  status = 500;
              }
              break;
            case DioErrorType.sendTimeout:
              status = 500;
              break;
            case DioErrorType.badCertificate:
              // TODO: Handle this case.
              break;
            case DioErrorType.connectionError:
              // TODO: Handle this case.
              break;
          }
        } else if (error is SocketException) {
          status = 500;
        } else {
          status = 500;
        }
        return status ?? 500;
      } on FormatException catch (_) {
        return 500;
      } catch (_) {
        return 500;
      }
    } else {
      if (error.toString().contains("is not a subtype of")) {
        return 500;
      } else {
        return 500;
      }
    }
  }

  static String getErrorMessage(NetworkExceptions networkExceptions) {
    var errorMessage = "";
    networkExceptions.when(
      notImplemented: () {
        errorMessage = "Not Implemented";
      },
      requestCancelled: () {
        errorMessage = "Request Cancelled";
      },
      internalServerError: () {
        errorMessage = "Internal Server Error";
      },
      notFound: (String reason) {
        errorMessage = reason;
      },
      serviceUnavailable: () {
        errorMessage = "Service unavailable";
      },
      methodNotAllowed: () {
        errorMessage = "Method Allowed";
      },
      badRequest: () {
        errorMessage = "Bad request";
      },
      unauthorisedRequest: () {
        errorMessage = "Unauthorised request";
      },
      unexpectedError: () {
        errorMessage = "Unexpected error occurred";
      },
      requestTimeout: () {
        errorMessage = "Connection request timeout";
      },
      noInternetConnection: () {
        errorMessage = "No internet connection";
      },
      conflict: () {
        errorMessage = "Error due to a conflict";
      },
      sendTimeout: () {
        errorMessage = "Send timeout in connection with API server";
      },
      unableToProcess: () {
        errorMessage = "Unable to process the data";
      },
      defaultError: (String error) {
        errorMessage = error;
      },
      formatException: () {
        errorMessage = "Unexpected error occurred";
      },
      notAcceptable: () {
        errorMessage = "Not acceptable";
      },
    );
    return errorMessage;
  }
}
