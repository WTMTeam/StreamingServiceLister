// adult boolean Defaults to true
// gender integer Defaults to 0
// id integer Defaults to 0
// known_for_department string
// name string
// original_name string
// popularity number Defaults to 0
// profile_path string
// known_for array of objects

import 'dart:convert';

import 'package:wheres_that_movie/api/constants.dart';
import 'package:wheres_that_movie/api/models/detailed_person_model.dart';
import 'package:wheres_that_movie/api/models/movie_model.dart';
import 'package:wheres_that_movie/api/models/show_model.dart';

class Person {
  final bool adult;
  final int personID;
  final int gender;
  final String knownForDepartment;
  final String name;
  final String originalName;
  final double popularity;
  final String profilePath;
  final List<Movie> movies;
  final List<Show> shows;

  const Person({
    required this.adult,
    required this.personID,
    required this.gender,
    required this.knownForDepartment,
    required this.name,
    required this.originalName,
    required this.popularity,
    required this.profilePath,
    required this.movies,
    required this.shows,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    try {
      String profilePath = "";
      if (json['profile_path'] != null) {
        profilePath = json['profile_path'];
      }

      List<Movie> movies = [];
      List<Show> shows = [];

      List<dynamic> moviesShows = json['known_for'];

      for (var item in moviesShows) {
        if (item['media_type'] == "movie") {
          movies.add(Movie.fromJson(item));
        } else if (item['media_type'] == "tv") {
          shows.add(Show.fromJson(item));
        }
      }

      return Person(
        adult: json['adult'],
        personID: json['id'],
        gender: json['gender'],
        knownForDepartment: json['known_for_department'],
        name: json['name'],
        originalName: json['original_name'],
        popularity: json['popularity'],
        profilePath: profilePath,
        movies: movies,
        shows: shows,
      );
    } catch (error) {
      print('error in person: $error');
      return const Person(
        adult: false,
        personID: 0000,
        gender: 0000,
        knownForDepartment: '',
        name: '',
        originalName: '',
        popularity: 0.00,
        profilePath: '',
        movies: [],
        shows: [],
      );
    }
  }
}
