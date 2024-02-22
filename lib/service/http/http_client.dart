import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:kiosk/service/api/urls.dart';
import 'package:kiosk/service/app_exceptions/app_exceptions.dart';
import 'package:kiosk/utils/utils.dart';
import 'package:logger/logger.dart';

/*

This Dart file containing the implementation of a base HTTP client for sending requests to our RESTful API.
The class provides methods for sending GET, PATCH, PUT, POST, and DELETE requests.
It uses the http package to make requests and throws custom exceptions if any errors occur.
The class also supports token-based authentication, and tokens are stored using the GetStorage package.
The getRequest, patchRequest, putRequest, postRequest, and deleteRequest methods all take an http.Client object as a parameter, which can be reused to make multiple requests.
The endpoint parameter is required for all methods and specifies the URL to send the request to.
The payload parameter is required for the patchRequest, putRequest, and postRequest methods and contains the data to be sent in the request body.
The token parameter is optional and can be used to pass in a token for authentication, but if a token is stored in GetStorage, it will be used automatically.
The class also supports refreshing access tokens if a 401 Unauthorized response is received.
The class logs the request URL, response status code, and response body to the console for debugging purposes.

*/

class BaseClient {
  static const int timeOutDuration = 35;
  final box = GetStorage();
  final EndPoints endPoints = EndPoints();

  final exceptionHandler = ExceptionHandlers();
  var logger = Logger(
    printer: PrettyPrinter(
        methodCount: 2, // number of method calls to be displayed
        errorMethodCount: 8, // number of method calls if stacktrace is provided
        lineLength: 120, // width of the output
        colors: true, // Colorful log messages
        printEmojis: true, // Print an emoji for each log message
        printTime: false // Should each log print contain a timestamp
        ),
  );

  /// Makes a GET request to the specified endpoint using the provided http client.
  ///
  /// The [httpClient] parameter is the instance of [http.Client] to use for making the request.
  ///
  /// The [endpoint] parameter is the URL of the endpoint to send the GET request to.
  ///
  /// This function first reads the authentication token from local storage, and sets it as the Bearer token in the request headers, if available.
  /// It then sends the GET request to the specified [endpoint] with the [header] as the request headers, and waits for a response.
  /// If the response is a 401 Unauthorized error, it attempts to refresh the access token and retries the request.
  /// If any errors occur during the request, it is caught and re-thrown as a string error message using [ExceptionHandlers].
  ///
  /// Returns a [Future] object representing the response of the GET request.

  Future<dynamic> getRequest(http.Client httpClient,
      {required String endpoint, Map<String, dynamic>? queryParameters}) async {
// Get the authentication token from local storage
    final token = box.read('Token');
// Set the request headers
    final Map<String, String> header = EndPoints().header;

// Parse the endpoint URL
    var uri = Uri.parse(endpoint).replace(queryParameters: queryParameters);

// Add the Bearer token to the headers if it exists
    if (token != null) {
      header.addAll({'Authorization': "Bearer ${token['access']}"});
    }

    try {
      // Send the GET request to the endpoint with the headers, and wait for a response
      final http.Response response = await httpClient
          .get(uri, headers: header)
          .timeout(const Duration(seconds: timeOutDuration));

      // Log the response endpoint and status code
      log("GET REQUEST $endpoint ", name: response.statusCode.toString());

      // If a token exists and the response is a 401 Unauthorized error, attempt to refresh the access token and retry the request
      if (token != null) {
        if (response.statusCode == 403) {
          await refreshAccessToken(httpClient);
          return getRequest(httpClient, endpoint: endpoint);
        }
      }

      // Process the response using the private _processResponse() function
      return _processResponse(response);
    } catch (e) {
      // If any errors occur, log the error and throw a string error message using ExceptionHandlers()
      logger.e("GET REQUEST ", e.toString());

      // log(e.toString(), name: "ERROR GET REQUEST " + uri.toString());
      throw exceptionHandler.getExceptionString(e);
    }
  }

/*
This function sends a PATCH request to the specified endpoint with the provided payload.
@param httpClient - an instance of the http.Client class
@param endpoint - the API endpoint to send the request to
@param payload - a Map object containing the data to be sent in the request body
@returns a Future<dynamic> object representing the response from the API
*/
  Future<dynamic> patchRequest(
    http.Client httpClient, {
    required String endpoint,
    required Map<String, dynamic> payload,
  }) async {
// Read the access token from the box
    final token = box.read('Token');

// Get the headers required for API calls
    final Map<String, String> header = EndPoints().header;

// Parse the endpoint URL
    var uri = Uri.parse(endpoint);

// Encode the payload into JSON format
    var body = jsonEncode(payload);

// If the access token exists, add it to the headers
    if (token != null) {
      header.addAll({'Authorization': "Bearer ${token['access']}"});
    }

    try {
// Send the PATCH request
      final http.Response response = await httpClient
          .patch(uri, headers: header, body: body)
          .timeout(const Duration(seconds: timeOutDuration));

      // Log the response endpoint and status code
      log("PATCH REQUEST $endpoint ", name: response.statusCode.toString());

// If the access token exists and the response is unauthorized, refresh the token and retry the request
      if (token != null) {
        if (response.statusCode == 403) {
          await refreshAccessToken(httpClient);
          return getRequest(httpClient, endpoint: endpoint);
        }
      }

// Process the response and return it
      return _processResponse(response);
    } catch (e) {
// Log any errors that occur and rethrow them

      logger.e("PATCH REQUEST ", e.toString());

      // log(e.toString(), name: "ERROR PATCH REQUEST " + uri.toString());

      throw exceptionHandler.getExceptionString(e);
    }
  }

/*
This function sends a PUT request to the given endpoint with the provided payload
@param httpClient - an instance of the http.Client class
@param endpoint - the API endpoint to send the request to
@param payload - a Map object containing the data to be sent in the request body
@returns a Future<dynamic> object representing the response from the API
*/

  Future<dynamic> putRequest(
    http.Client httpClient, {
    required String endpoint,
    required Map<String, dynamic> payload,
  }) async {
    final token = box.read('Token');
    final Map<String, String> header = EndPoints().header;
// Parse the endpoint URL
    var uri = Uri.parse(endpoint);

// Encode the payload as JSON
    var body = jsonEncode(payload);

// Add authorization header if a token is available
    if (token != null) {
      header.addAll({'Authorization': "Bearer ${token['access']}"});
    }

    try {
      // Send the PUT request to the server
      final http.Response response = await httpClient
          .put(uri, headers: header, body: body)
          .timeout(const Duration(seconds: timeOutDuration));

      // Log the request URL and response body

      log("PUT REQUEST $endpoint ", name: response.statusCode.toString());

      // If a token is available and the response status code is 401, refresh the access token and retry the request
      if (token != null) {
        if (response.statusCode == 403) {
          await refreshAccessToken(httpClient);
          return getRequest(httpClient, endpoint: endpoint);
        }
      }

      // Process and return the server response
      return _processResponse(response);
    } catch (e) {
      // Log and rethrow any exceptions that occur
      logger.e("PUT REQUEST ", e.toString());

      // log(e.toString(), name: "ERROR PUT REQUEST " + uri.toString());

      throw exceptionHandler.getExceptionString(e);
    }
  }

/*
This function sends a POST request to the given endpoint with the provided payload
@param httpClient - an instance of the http.Client class
@param endpoint - the API endpoint to send the request to
@param payload - a Map object containing the data to be sent in the request body
@returns a Future<dynamic> object representing the response from the API
*/
  Future<dynamic> postRequest(http.Client httpClient,
      {required String endpoint,
      required Map<String, dynamic> payload,
      bool removeToken = false,
      Map<String, dynamic> token = const {}}) async {
    // Parse the endpoint into a URI object
    var uri = Uri.parse(endpoint);

    // Encode the payload as a JSON string
    var body = jsonEncode(payload);

    // Get the access token from local storage
    final token = box.read('Token');

    // Set the HTTP headers
    final Map<String, String> header = EndPoints().header;

    // If a token is present, add an Authorization header with the access token
    if (!removeToken) {
      if (token != null) {
        header.addAll({'Authorization': "Bearer ${token['access']}"});
      }
    } else {
      header.remove('Authorization');
    }

    try {
      // Send the POST request with the provided endpoint, body, and headers
      var response = await http
          .post(uri, body: body, headers: header)
          .timeout(const Duration(seconds: timeOutDuration));

      // Log the request URL and response body
      log("POST REQUEST $endpoint ", name: response.statusCode.toString());

      // If a token is present and the status code is 401, refresh the access token and try again
      if (token != null && endpoint != endPoints.getToken) {
        if (response.statusCode == 403) {
          await refreshAccessToken(httpClient);
          return postRequest(httpClient, endpoint: endpoint, payload: payload);
        }
      }
      // Process the response
      return _processResponse(response);
    } catch (e) {
      // Log the error and re-throw it as an exception
      logger.e("POST REQUEST ", e.toString());
      // log(e.toString(), name: "ERROR POST REQUEST " + uri.toString());
      throw exceptionHandler.getExceptionString(e);
    }
  }

/*
This function sends a POST request to the given endpoint with the provided payload
@param httpClient - an instance of the http.Client class
@param endpoint - the API endpoint to send the request to
@returns a Future<dynamic> object representing the response from the API
*/
  Future<dynamic> deleteRequest(http.Client httpClient,
      {required String endpoint}) async {
    final token = box.read('Token');
    final Map<String, String> header = EndPoints().header;

    var uri = Uri.parse(endpoint);

    //Add Authorization header if token is available
    if (token != null) {
      header.addAll({'Authorization': "Bearer ${token['access']}"});
    }

    try {
      //Send DELETE request to specified endpoint with headers and timeout duration
      final http.Response response = await httpClient
          .delete(uri, headers: header)
          .timeout(const Duration(seconds: timeOutDuration));

      //Log the request URI and response body with status code
      log("DELETE REQUEST $endpoint ", name: response.statusCode.toString());

      //If token is available and status code is 401, refresh token and retry request
      if (token != null) {
        if (response.statusCode == 403) {
          await refreshAccessToken(httpClient);
          return deleteRequest(httpClient, endpoint: endpoint);
        }
      }

      //Process the response and return
      return _processResponse(response);
    } catch (e) {
      //Log the error and throw a formatted exception
      logger.e("DELETE REQUEST ", e.toString());

      // log(e.toString(), name: "ERROR DELETE REQUEST " + uri.toString());

      throw exceptionHandler.getExceptionString(e);
    }
  }

/*
This function makes a multipart request to the server with HTTP POST method
@param httpClient: instance of HTTP client
@param endpoint: URL of the endpoint to make the request to
@param fields: Map of fields to be included in the request
@param file: List of files to be uploaded
@param method: HTTP method to use for the request (default is POST)
@param token: Map containing the access and refresh tokens (default is empty)
@return A Future<dynamic> containing the response from the server
@throws An exception if there's an error during the request
*/

  Future<dynamic> multipartRequest(http.Client httpClient,
      {required String endpoint,
      required Map<String, String> fields,
      required List<Map<String, dynamic>> file,
      String method = "POST",
      Map<String, dynamic> token = const {}}) async {
    try {
// Parse the endpoint URL and initialize the header and token
      var uri = Uri.parse(endpoint);
      final token = box.read('Token');
      final Map<String, String> header = EndPoints().header;
// Add Authorization header with bearer token if available
      if (token != null) {
        header.addAll({'Authorization': "Bearer ${token['access']}"});
      }

// Create a new multipart request and add headers
      var request = http.MultipartRequest(method, uri);
      request.headers.addAll(header);

// Add files to the request
      if (file.isNotEmpty) {
        for (var element in file) {
          request.files.add(await http.MultipartFile.fromPath(
              element["name"], element["file"].path));
        }
      }

// Add fields to the request
      if (fields.isNotEmpty) {
        request.fields.addAll(fields);
      }

      request.fields['employment_term'] = "xx";

// Send the request and get the response
      http.StreamedResponse response = await request.send();

// Handle unauthorized error (401) by refreshing the access token and retrying
      if (token != null) {
        if (response.statusCode == 403) {
          await refreshAccessToken(httpClient);
          return multipartRequest(httpClient,
              endpoint: endpoint, fields: fields, file: file, method: method);
        }
      }
      log("MULTIPART REQUEST $endpoint ", name: response.statusCode.toString());

      return await _processResponseMuiltiPart(response);
    } catch (e) {
      logger.e("MULTIPART REQUEST ", e.toString());

      // log(e.toString(), name: "MULTIPART ERROR " + endpoint.toString());
      throw exceptionHandler.getExceptionString(e);
    }
  }

// This function sends a request to the server to refresh the access token using the current refresh token.
// If the response from the server is successful, the new access token is stored in the app's local storage.
// The function returns a boolean value to indicate whether the refresh token was successfully updated or not.
  Future<bool> refreshAccessToken(http.Client httpClient) async {
    try {
      final token = box.read('Token');

      // Define the URI for the refresh token endpoint
      var uri = Uri.parse(EndPoints().refreshToken);

      // Define the request body with the refresh token
      var body = json.encode({"refresh": token['refresh']});

      // Send a POST request to refresh the access token
      final http.Response response = await httpClient
          .post(uri, headers: EndPoints().header, body: body)
          .timeout(const Duration(seconds: timeOutDuration));

      log("REFRESH TOKEN ", name: response.statusCode.toString());

      // If the response status code is 200 OK, update the access token and return true
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;

        await box.write("Token",
            {'refresh': token['refresh'], 'access': jsonData['access']});

        return true;
      }

      // If the response status code is not 200 OK, return false
      return false;

      // If a SocketException is thrown, rethrow it
    } on SocketException catch (_) {
      rethrow;

      // If any other exception is thrown, rethrow it
    } catch (e) {
      rethrow;
    }
  }

// This function takes an http response object and returns the same object if status code is in 200, 201, 202, or 204
// Otherwise, it throws an exception based on the status code and message received in the response body
// 400 - BadRequestException is thrown when there are validation errors in the request body
// 401 - UnAuthorizedException is thrown when the user is not authenticated
// 403 - UnAuthorizedException is thrown when the user is authenticated but not authorized to perform the action
// 404 - NotFoundException is thrown when the requested resource is not found
// 500 - FetchDataException is thrown for all other cases where the request failed due to an internal server error or any other error.
  _processResponse(http.Response response) {
    print(response.body);
    switch (response.statusCode) {
      case 200:
        var responseJson = response;
        return responseJson;
      case 201:
        var responseJson = response;
        return responseJson;
      case 202:
        var responseJson = response;
        return responseJson;
      case 204:
        var responseJson = response;
        return responseJson;
      case 400:
        final body = jsonDecode(response.body);
        // final errors = body['errors'];
        // final email = body['email']?[0];
        // final number = body['contact_number']?[0];
        // final message = body['message'];

        throw BadRequestException(Util.getFirstItem(body) ?? body.toString());

      case 401:
        throw UnAuthorizedException(jsonDecode(response.body)['message'] ??
            jsonDecode(response.body)['detail']);
      case 403:
        throw UnAuthorizedException(jsonDecode(response.body)['message'] ??
            jsonDecode(response.body)['detail']);
      case 404:
        throw NotFoundException(jsonDecode(response.body)['message'] ??
            jsonDecode(response.body)['detail']);
      case 500:
      default:
        throw FetchDataException(
            'Sorry, something went wrong. Please try again later.\n${response.statusCode}');
    }
  }

  // This method takes in a `http.StreamedResponse` object as its parameter,
  // reads the response body and returns a Future that resolves to a JSON
  // string or throws an error based on the status code of the response.
  _processResponseMuiltiPart(http.StreamedResponse response) async {
    final responseBody = await response.stream.bytesToString();
    print(responseBody);

    switch (response.statusCode) {
      case 200:
        var responseJson = responseBody;
        return responseJson;
      case 201:
        var responseJson = responseBody;
        return responseJson;
      case 202:
        var responseJson = responseBody;
        return responseJson;
      case 400: //Bad request
        throw BadRequestException(jsonDecode(responseBody)['message'] ??
            jsonDecode(responseBody)['detail'] ??
            Util.getFirstItem(jsonDecode(responseBody)) ??
            jsonDecode(responseBody).toString());
      case 401: //Unauthorized
        throw UnAuthorizedException(jsonDecode(responseBody)['message'] ??
            jsonDecode(responseBody)['detail']);
      case 403: //Forbidden
        throw UnAuthorizedException(jsonDecode(responseBody)['message'] ??
            jsonDecode(responseBody)['detail']);
      case 404: //Resource Not Found
        throw NotFoundException(jsonDecode(responseBody)['message'] ??
            jsonDecode(responseBody)['detail']);
      case 500: //Internal Server Error
      default:
        throw FetchDataException(
            'Something went wrong! ${response.statusCode}');
    }
  }
}
