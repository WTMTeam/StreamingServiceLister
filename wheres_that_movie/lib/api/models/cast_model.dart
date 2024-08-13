import 'package:wheres_that_movie/api/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CastMember {
  final bool isAdult;
  final int gender;
  final int id;
  final String knownForDepartment;
  final String name;
  final String originalName;
  final double popularity;
  final String profilePath; // "/eOh4ubpOm2Igdg0QH2ghj0mFtC.jpg",
  final int castId;
  final String character;
  final String creditId;
  final int order;

  // {
  //     "adult": false,
  //     "gender": 2,
  //     "id": 500,
  //     "known_for_department": "Acting",
  //     "name": "Tom Cruise",
  //     "original_name": "Tom Cruise",
  //     "popularity": 94.258,
  //     "profile_path": "/eOh4.jpg",
  //     "cast_id": 13,
  //     "character": "Maverick",
  //     "credit_id": "52fe426fc3a36847f801e6b9",
  //     "order": 0
  //   },

  const CastMember({
    required this.isAdult,
    required this.gender,
    required this.id,
    required this.knownForDepartment,
    required this.name,
    required this.originalName,
    required this.popularity,
    required this.profilePath, // "/eOh4ubpOm2Igdg0QH2ghj0mFtC.jpg"
    required this.castId,
    required this.character,
    required this.creditId,
    required this.order,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    try {
      String profilePath = "";
      if (json['profile_path'] != null) {
        profilePath = json['profile_path'];
      }
      return CastMember(
        isAdult: json['adult'] ?? false,
        gender: json['gender'] ?? 0,
        id: json['id'] ?? 0,
        knownForDepartment: json['known_for_department'] ?? 'Unknown',
        name: json['name'] ?? 'Unknown',
        originalName: json['original_name'] ?? 'Unknown',
        popularity: (json['popularity'] ?? 0.0).toDouble(),
        profilePath: profilePath,
        castId: json['cast_id'] ?? 0,
        character: json['character'] ?? 'Unknown',
        creditId: json['credit_id'] ?? 'Unknown',
        order: json['order'] ?? 0,
      );
// {
//       "adult": false,
//       "gender": 2,
//       "id": 17419,
//       "known_for_department": "acting",
//       "name": "bryan cranston",
//       "original_name": "bryan cranston",
//       "popularity": 53.313,
//       "profile_path": "/knytxgkisp8w4gs60hf7uoxznwn.jpg",
//       "character": "walter white",
//       "credit_id": "52542282760ee313280017f9",
//       "order": 0
//     },
      return CastMember(
        isAdult: json['adult'],
        gender: json['gender'],
        id: json['id'],
        knownForDepartment: json['known_for_department'],
        name: json['name'],
        originalName: json['original_name'],
        popularity: json['popularity'],
        profilePath: profilePath,
        castId: json['cast_id'],
        character: json['character'],
        creditId: json['credit_id'],
        order: json['order'],
      );
    } catch (error) {
      print("error $json");
      print(error);
      throw Exception('Failed to parse CastMember from JSON');
    }
  }
}

class CastService {
  final Map<String, String> headers = {
    'accept': 'application/json',
    'Authorization':
        'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkYmZmYTBkMTZmYjhkYzI4NzM1MzExNTZhNWM1ZjQxYSIsInN1YiI6IjYzODYzNzE0MDM5OGFiMDBjODM5MTJkOSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.qQjwnSQLDfVNAuinpsM-ATK400-dnwuWUVirc7_AiQY',
  };

  Future<List<CastMember>> getCastByMovieId({int movieId = 0}) async {
    try {
      var response = await http.get(
          Uri.parse(ApiEndPoint(id: movieId).getCastByMovieId),
          headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<CastMember> cast = [];
        for (var castMember in data["cast"]) {
          cast.add(CastMember.fromJson(castMember));
        }

        return cast;
      } else {
        throw Exception(
            'HTTP FAILED getting cast with status code: ${response.statusCode}');
      }
    } catch (error) {
      print("Error getting cast: $error");
      throw Exception('Failed Getting Cast');
    }
  }

  Future<List<CastMember>> getCastByShowId({int showId = 0}) async {
    try {
      var response = await http.get(
          Uri.parse(ApiEndPoint(id: showId).getCastByShowId),
          headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<CastMember> cast = [];
        for (var castMember in data["cast"]) {
          cast.add(CastMember.fromJson(castMember));
        }
        return cast;
      } else {
        throw Exception(
            'HTTP FAILED getting cast with status code: ${response.statusCode}');
      }
    } catch (error) {
      print("Error getting show cast: $error");
      throw Exception("Failed Getting Cast");
    }
  }
}
