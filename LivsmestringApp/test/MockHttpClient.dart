// File: MockHttpClient.dart
import 'package:dio/dio.dart';
import 'package:livsmestringapp/models/DataModel.dart';
import 'package:mockito/mockito.dart';

// Simple mock class for Dio - directly defined in this file
class MockDio extends Mock implements Dio {
  // This overrides the actual method signature to make the mock work
  Future<Response<T>> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onReceiveProgress,
      }) {
    return super.noSuchMethod(
      Invocation.method(
        #get,
        [path],
        {
          #queryParameters: queryParameters,
          #options: options,
          #cancelToken: cancelToken,
          #onReceiveProgress: onReceiveProgress,
        },
      ),
      returnValue: Future.value(Response<T>(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
      )),
    ) as Future<Response<T>>;
  }
}

// Function to create and set up a MockDio with predefined responses
MockDio getMockDio() {
  final mockDio = MockDio();

  // Define the response data that should be returned
  final responseData = {
    "Category": "career",
    "Chapters": [
      {
        "Title": "1_me_in_context",
        "Videos": [
          {
            "Title": "1.1_introduction",
            "LanguageUrls": {
              "en": "https://youtu.be/LEvsQV9x3Oo",
              "nb": "https://youtu.be/KOwLhVRP7UY",
              "ps": "https://youtu.be/I9zQ3BCxEEw"
            },
            "Tasks": null
          }
        ]
      }
    ]
  };

  // Setup the mock to return our predefined data when the endpoint is called
  when(mockDio.get(
    'https://testhttp.fly.dev/video',
    queryParameters: anyNamed('queryParameters'),
    options: anyNamed('options'),
  )).thenAnswer((_) async => Response(
    data: responseData,
    statusCode: 200,
    requestOptions: RequestOptions(path: 'https://testhttp.fly.dev/video'),
  ));

  return mockDio;
}

// Function that uses the mock Dio to fetch data
Future<Datamodel> mockFetchData(Dio dio, String category) async {
  try {
    final response = await dio.get('https://testhttp.fly.dev/video');

    if (response.statusCode == 200) {
      return Datamodel.fromJson(response.data);
    }
    throw DioError(
      requestOptions: RequestOptions(path: 'https://testhttp.fly.dev/video'),
      error: 'Failed to load data',
    );
  } catch (e) {
    throw Exception('Error in mockFetchData: $e');
  }
}