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
      genreIDs: json['genre_ids'],
      title: json['name'],
      overview: json['overview'],
      posterPath: posterPath,
      backdropPath: backdropPath,
      rating: json['vote_average'],
    );
  }
}
