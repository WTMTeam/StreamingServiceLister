import 'dart:convert';

import 'package:wheres_that_movie/api/constants.dart';
import 'package:wheres_that_movie/api/models/image_model.dart';
import 'package:wheres_that_movie/api/models/movie_credit_model.dart';
import 'package:wheres_that_movie/api/models/show_credit_model.dart';

import 'package:http/http.dart' as http;
//fetch('https://api.themoviedb.org/3/person/500?append_to_response=images%2Cmovie_credits%2Ctv_credits%2Ctagged_images&language=en-US', options)

class DetailedPerson {
  final bool adult;
  final List<dynamic> alsoKnownAs;
  final String biography;
  final String? birthday;
  final String? deathday;
  final int gender;
  final String? homepage;
  final int personID;
  final String imdbID;
  final String knownForDepartment;
  final String name;
  final String? placeOfBirth;
  final double popularity;
  final String? profilePath;
  final List<MovieImage> images;
  final List<MovieCastCredit> movieCastCredits;
  final List<MovieCrewCredit> movieCrewCredits;
  final List<ShowCastCredit> showCastCredits;
  final List<ShowCrewCredit> showCrewCredits;

  const DetailedPerson({
    required this.adult,
    required this.alsoKnownAs,
    required this.biography,
    required this.birthday,
    required this.deathday,
    required this.gender,
    required this.homepage,
    required this.personID,
    required this.imdbID,
    required this.knownForDepartment,
    required this.name,
    required this.placeOfBirth,
    required this.popularity,
    required this.profilePath,
    required this.images,
    required this.movieCastCredits,
    required this.movieCrewCredits,
    required this.showCastCredits,
    required this.showCrewCredits,
  });

  factory DetailedPerson.fromJson(Map<String, dynamic> json) {
    print(json);
    try {
      String profilePath = "";
      String deathdate = "";
      List<MovieImage> images = [];
      List<MovieCastCredit> movieCastCredits = [];
      List<MovieCrewCredit> movieCrewCredits = [];
      List<ShowCastCredit> showCastCredits = [];
      List<ShowCrewCredit> showCrewCredits = [];

      if (json['profile_path'] != null) {
        profilePath = json['profile_path'];
      }
      if (json['deathday'] != null) {
        deathdate = json['deathday'];
      }
      if (json['movie_credits']['cast'] != null) {
        var list = json['movie_credits']['cast'];
        for (var item in list) {
          movieCastCredits.add(MovieCastCredit.fromJson(item));
        }
      }
      if (json['movie_credits']['crew'] != null) {
        var list = json['movie_credits']['crew'];
        for (var item in list) {
          movieCrewCredits.add(MovieCrewCredit.fromJson(item));
        }
      }
      if (json['tv_credits']['cast'] != null) {
        var list = json['tv_credits']['cast'];
        for (var item in list) {
          showCastCredits.add(ShowCastCredit.fromJson(item));
        }
      }
      if (json['tv_credits']['crew'] != null) {
        var list = json['tv_credits']['crew'];
        for (var item in list) {
          showCrewCredits.add(ShowCrewCredit.fromJson(item));
        }
      }
      if (json['images']['profiles'] != null) {
        var list = json['images']['profiles'];
        for (var item in list) {
          images.add(MovieImage.fromJson(item));
        }
      }
      return DetailedPerson(
        adult: json['adult'],
        alsoKnownAs: json['also_known_as'],
        biography: json['biography'],
        birthday: json['birthday'],
        deathday: deathdate,
        gender: json['gender'],
        homepage: json['homepage'],
        personID: json['id'],
        imdbID: json['imdb_id'],
        knownForDepartment: json['known_for_department'],
        name: json['name'],
        placeOfBirth: json['place_of_birth'],
        popularity: json['popularity'],
        profilePath: profilePath,
        images: images,
        movieCastCredits: movieCastCredits,
        movieCrewCredits: movieCrewCredits,
        showCastCredits: showCastCredits,
        showCrewCredits: showCrewCredits,
      );
    } catch (e) {
      print('error in DetailedPerson $e');
      return const DetailedPerson(
        adult: false,
        alsoKnownAs: [],
        biography: "",
        birthday: "",
        deathday: "",
        gender: 0000,
        homepage: '',
        personID: 0000,
        imdbID: '',
        knownForDepartment: '',
        name: '',
        placeOfBirth: '',
        popularity: 0.00,
        profilePath: '',
        images: [],
        movieCastCredits: [],
        movieCrewCredits: [],
        showCastCredits: [],
        showCrewCredits: [],
      );
    }
  }
}

class DetailedPersonService {
  final Map<String, String> headers = {
    'accept': 'application/json',
    'Authorization':
        'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkYmZmYTBkMTZmYjhkYzI4NzM1MzExNTZhNWM1ZjQxYSIsInN1YiI6IjYzODYzNzE0MDM5OGFiMDBjODM5MTJkOSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.qQjwnSQLDfVNAuinpsM-ATK400-dnwuWUVirc7_AiQY',
  };

  Future<DetailedPerson> getDetailedPersonById({int personId = 0}) async {
    try {
      var response = await http.get(
          Uri.parse(ApiEndPoint(id: personId).getDetailedPerson),
          headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final person = DetailedPerson.fromJson(data);
        return person;
      } else {
        throw Exception(
            'HTTP FAILED getting DetailedPerson with status code: ${response.statusCode}');
      }
    } catch (error) {
      print("Error getting DetailedPerson: $error");
      throw Exception('Failed getting DetailedPerson');
    }
  }
}
