import 'package:wheres_that_movie/api/models/movie_model.dart';

class MovieCastCredit {
  final Movie movie;
  final String character;
  final int? order;

  const MovieCastCredit({
    required this.movie,
    required this.character,
    required this.order,
  });
  factory MovieCastCredit.fromJson(Map<String, dynamic> json) {
    return MovieCastCredit(
      movie: Movie.fromJson(json),
      character: json['character'],
      order: json['order'],
    );
  }
}

class MovieCrewCredit {
  final Movie movie;
  final String department;
  final String job;

  const MovieCrewCredit({
    required this.movie,
    required this.department,
    required this.job,
  });
  factory MovieCrewCredit.fromJson(Map<String, dynamic> json) {
    return MovieCrewCredit(
      movie: Movie.fromJson(json),
      department: json['department'],
      job: json['job'],
    );
  }
}
