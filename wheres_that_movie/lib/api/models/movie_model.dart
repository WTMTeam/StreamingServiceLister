import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wheres_that_movie/api/constants.dart';
import 'package:wheres_that_movie/api/models/genre_model.dart';
import 'package:wheres_that_movie/api/models/provider_model.dart';

class Movie {
  final int movieID;
  final List<dynamic> genreIDs;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final num rating;

  const Movie({
    required this.movieID,
    required this.genreIDs,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.rating,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    try {
      String backdropPath = "";
      String posterPath = "";
      if (json['backdrop_path'] != null) {
        backdropPath = json['backdrop_path'];
      }

      if (json['poster_path'] != null) {
        posterPath = json['poster_path'];
      }

      return Movie(
        movieID: json['id'],
        genreIDs: json['genre_ids'],
        title: json['title'],
        overview: json['overview'],
        posterPath: posterPath,
        backdropPath: backdropPath,
        rating: json['vote_average'],
      );
    } catch (error) {
      print("error $json");
      print(error);
      return const Movie(
        movieID: 0000,
        genreIDs: [0, 0, 0],
        title: "ERROR",
        overview: "ERROR",
        posterPath: "ERROR",
        backdropPath: "ERROR",
        rating: 0.0,
      );
    }
  }
}

class MovieService {
  // Todo:
  // - Sort based on something
  // - Accept and send on provider data, genre data osv.
  // - is there additional data we want to grab?
  Future<List<Movie>> getMovieSuggestions(
      {String? currentOption,
      List<Provider>? providers,
      List<Genre>? genres,
      String? region,
      int? runtime, // runtime in minutes
      bool? runtimeLessThan}) async {
    String providerIDs = "";
    String genreIDs = "";

    if (currentOption != null) {
      print("Current Option: $currentOption");
    }

    // Concatenate Provider IDs
    if (providers != null && providers.isNotEmpty) {
      for (Provider provider in providers) {
        providerIDs += "${provider.providerID}|";
      }

      // Remove the trailing "|"
      providerIDs = providerIDs.substring(0, providerIDs.length - 1);
    }
    //print("Provider IDs: $providerIDs");
    // Concatenate Genre IDs
    if (genres != null && genres.isNotEmpty) {
      for (Genre genre in genres) {
        genreIDs += "${genre.genreID}|";
      }

      // Remove the trailing "|"
      genreIDs = genreIDs.substring(0, genreIDs.length - 1);
    }

    runtime ??= 999;

    final Map<String, String> headers = {
      'accept': 'application/json',
      'Authorization':
          'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkYmZmYTBkMTZmYjhkYzI4NzM1MzExNTZhNWM1ZjQxYSIsInN1YiI6IjYzODYzNzE0MDM5OGFiMDBjODM5MTJkOSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.qQjwnSQLDfVNAuinpsM-ATK400-dnwuWUVirc7_AiQY',
    };
    var response = await http.get(
        Uri.parse(ApiEndPoint(
          providerIDs: providerIDs,
          genreIDs: genreIDs,
          region: region,
          runtime: runtime,
        ).getMovieSuggestions),
        headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Data: $data");
      final List<Movie> movieList = [];

      //for (var i = 0; i < data['results'].length; i++) {
      // TODO:
      // Filter the results based on if they have the right streaming provider for flatrate, free or ads
      int counter = 0;
      for (var i = 0; i < data['results'].length; i++) {
        if (counter == 11) {
          break;
        }
        final entry = data['results'][i];
        try {
          if (providerIDs.isNotEmpty) {
            Movie currentMovie = Movie.fromJson(entry);
            var providerResponse = await http.get(
                Uri.parse(ApiEndPoint(
                  id: currentMovie.movieID,
                ).getMovieProvidersByMovieID),
                headers: headers);

            if (providerResponse.statusCode == 200) {
              final providerData = jsonDecode(providerResponse.body);

              if (currentOption == "Stream") {
                List streamingProviders =
                    providerData['results'][region]['flatrate'] ?? [];
                List<int> streamingProvidersIDs = streamingProviders
                    .map<int>((provider) => provider['provider_id'])
                    .toList();

                // Split the concatenated providerIDs string into a list of integers
                List<int> selectedProviderIds =
                    providerIDs.split("|").map(int.parse).toList();

                // Check if any of the selected provider IDs exist in the streaming providers list
                bool hasCommonProvider = selectedProviderIds
                    .any((id) => streamingProvidersIDs.contains(id));

                if (hasCommonProvider) {
                  counter++;
                  movieList.add(Movie.fromJson(entry));
                }
              } else if (currentOption == "Rent") {
                // rent logic
                List streamingProviders =
                    providerData['results'][region]['rent'] ?? [];
                List<int> streamingProvidersIDs = streamingProviders
                    .map<int>((provider) => provider['provider_id'])
                    .toList();

                // Split the concatenated providerIDs string into a list of integers
                List<int> selectedProviderIds =
                    providerIDs.split("|").map(int.parse).toList();

                // Check if any of the selected provider IDs exist in the streaming providers list
                bool hasCommonProvider = selectedProviderIds
                    .any((id) => streamingProvidersIDs.contains(id));

                if (hasCommonProvider) {
                  counter++;
                  movieList.add(Movie.fromJson(entry));
                }
              } else if (currentOption == "Buy") {
                // buy logic
                List streamingProviders =
                    providerData['results'][region]['buy'] ?? [];
                List<int> streamingProvidersIDs = streamingProviders
                    .map<int>((provider) => provider['provider_id'])
                    .toList();

                // Split the concatenated providerIDs string into a list of integers
                List<int> selectedProviderIds =
                    providerIDs.split("|").map(int.parse).toList();

                // Check if any of the selected provider IDs exist in the streaming providers list
                bool hasCommonProvider = selectedProviderIds
                    .any((id) => streamingProvidersIDs.contains(id));

                if (hasCommonProvider) {
                  counter++;
                  movieList.add(Movie.fromJson(entry));
                }
              } else {
                print("Error with currentOption in getMovieSuggestions");
              }
            }
          } else {
            movieList.add(Movie.fromJson(entry));
          }
        } catch (e) {
          print("Exception: $e");
        }
      }
      // for (var i = 0; i < 11; i++) {
      //   final entry = data['results'][i];
      //   try {
      //     movieList.add(Movie.fromJson(entry));
      //   } catch (e) {
      //     print("Exception: $e");
      //   }
      // }
      // for (Movie movie in movieList) {
      //   print("${movie.movieID}, ${movie.title}");
      // }
      return movieList;
    } else {
      throw Exception('HTTP FAILED with status code: ${response.statusCode}');
    }
  }
}
