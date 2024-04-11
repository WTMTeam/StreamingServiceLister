import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:wheres_that_movie/api/constants.dart';

class Provider {
  final int providerID;
  final String providerName;
  final String logoPath;
  final int displayPriority;

  const Provider(
      {required this.providerID,
      required this.providerName,
      required this.logoPath,
      required this.displayPriority});

  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      providerID: json['provider_id'],
      providerName: json['provider_name'],
      logoPath: json['logo_path'],
      displayPriority: json['display_priority'],
      // regions: json['display_priorities'],
    );
  }
}

class ProviderService {
  Future<List<Provider>> getProvidersByIdAndType(int id, bool isMovie) async {
    
    final Map<String, String> headers = {
      'accept': 'application/json',
      'Authorization':
          'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkYmZmYTBkMTZmYjhkYzI4NzM1MzExNTZhNWM1ZjQxYSIsInN1YiI6IjYzODYzNzE0MDM5OGFiMDBjODM5MTJkOSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.qQjwnSQLDfVNAuinpsM-ATK400-dnwuWUVirc7_AiQY',
    };
    dynamic response;

    if (isMovie) {
    response = await http.get(
        Uri.parse(ApiEndPoint(id: id).getMovieProvidersByMovieID),
        headers: headers);
    } else {
    print("Add support for tv shows in provider api for detailed");
    }

    if (response.statusCode == 200) {
      List<Provider> providerList;
      final data = jsonDecode(response.body);
      print(data);

      return data;
    }

    print(response);
    return response;

  }


  Future<List<Provider>> getProviders(String countryCode) async {
    // final response =
    //     await http.get(Uri.parse('https://randomuser.me/api?results=20'));
    final Map<String, String> headers = {
      'accept': 'application/json',
      'Authorization':
          'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkYmZmYTBkMTZmYjhkYzI4NzM1MzExNTZhNWM1ZjQxYSIsInN1YiI6IjYzODYzNzE0MDM5OGFiMDBjODM5MTJkOSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.qQjwnSQLDfVNAuinpsM-ATK400-dnwuWUVirc7_AiQY',
    };
    var response = await http.get(
        Uri.parse(ApiEndPoint().getMovieStreamingProviderInfo),
        headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List<Provider> providerList = [];
      for (var i = 0; i < data['results'].length; i++) {
        final entry = data['results'][i];
        try {
          Map<String, dynamic> countryData = entry['display_priorities'];
          bool isUSInMap = countryData.containsKey(countryCode);
          //bool isUSInMap = countryData.containsKey('US');
          if (isUSInMap) {
            providerList.add(Provider.fromJson(entry));
          }
        } catch (e) {
          print("HERE");
          print("Exception: $e");
        }
      }
      // Sort the providerList based on displayPriority
      providerList
          .sort((a, b) => a.displayPriority.compareTo(b.displayPriority));

      return providerList;
    } else {
      throw Exception('HTTP FAILED with status code: ${response.statusCode}');
    }
  }
}

// Future<List<dynamic>> getAllFilms() async {
//     print("here");
//     final Map<String, String> headers = {
//       'accept': 'application/json',
//       'Authorization':
//           'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkYmZmYTBkMTZmYjhkYzI4NzM1MzExNTZhNWM1ZjQxYSIsInN1YiI6IjYzODYzNzE0MDM5OGFiMDBjODM5MTJkOSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.qQjwnSQLDfVNAuinpsM-ATK400-dnwuWUVirc7_AiQY',
//     };
//     var response = await http.get(
//         Uri.parse(ApiEndPoint().getMovieStreamingProviderInfo),
//         headers: headers);
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       log("Data: $data");

//       // final List<User> userList = [];

//       // for (var i = 0; i < data['results'].length; i++) {
//       //   final entry = data['results'][i];
//       //   userList.add(User.fromJson(entry));
//       // }
//       // return userList;
//     } else {
//       throw Exception('HTTP FAILED with status code: ${response.statusCode}');
//     }

//     throw Exception("Test Failed");
//   }
