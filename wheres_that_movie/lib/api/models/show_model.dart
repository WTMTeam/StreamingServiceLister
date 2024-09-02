import 'dart:convert';

import 'package:wheres_that_movie/api/constants.dart';
import 'package:http/http.dart' as http;

class Show {
  final int showID;
  final List<dynamic> genreIDs;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final num rating;

  const Show({
    required this.showID,
    required this.genreIDs,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.rating,
  });

  factory Show.fromJson(Map<String, dynamic> json) {
    String backdropPath = "";
    String posterPath = "";

    if (json['backdrop_path'] != null) {
      backdropPath = json['backdrop_path'];
    }
    if (json['poster_path'] != null) {
      posterPath = json['poster_path'];
    }

    return Show(
      showID: json['id'],
      genreIDs: json['genre_ids'] ?? json['genres'],
      title: json['name'],
      overview: json['overview'],
      posterPath: posterPath,
      backdropPath: backdropPath,
      rating: json['vote_average'],
    );
  }
}

class ShowService {
  final Map<String, String> headers = {
    'accept': 'application/json',
    'Authorization':
        'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkYmZmYTBkMTZmYjhkYzI4NzM1MzExNTZhNWM1ZjQxYSIsInN1YiI6IjYzODYzNzE0MDM5OGFiMDBjODM5MTJkOSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.qQjwnSQLDfVNAuinpsM-ATK400-dnwuWUVirc7_AiQY',
  };

  Future<Show> getShowById(int id) async {
    var response = await http
        .get(Uri.parse(ApiEndPoint(id: id).getShowByShowId), headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('data: $data');

      return Show.fromJson(data);
    } else {
      throw Exception(
          'HTTP FAILED getting genres with status code: ${response.statusCode}');
    }
  }
}
