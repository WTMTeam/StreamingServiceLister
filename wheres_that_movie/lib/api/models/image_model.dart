import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:wheres_that_movie/api/constants.dart';

class MovieImage {
  //final String imageType; // backdrop, poster, logo
  final double aspectRatio;
  final int height;
  final String iso;
  final String filePath;
  final double voteAverage;
  final int votecount;
  final int width;

  const MovieImage({
    //required this.imageType, // backdrop, poster, logo
    required this.aspectRatio,
    required this.height,
    required this.iso,
    required this.filePath,
    required this.voteAverage,
    required this.votecount,
    required this.width,
  });

  factory MovieImage.fromJson(Map<String, dynamic> json) {
    return MovieImage(
//imageType: json['
      aspectRatio: json['aspect_ratio'],
      height: json['height'],
      iso: json['iso_639_1'] ?? '',
      filePath: json['file_path'],
      voteAverage: json['vote_average'],
      votecount: json['vote_count'],
      width: json['width'],
    );
  }
}

// do Show images here

enum ImageType { backdrops, posters, logos }

final Map<String, String> headers = {
  'accept': 'application/json',
  'Authorization':
      'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkYmZmYTBkMTZmYjhkYzI4NzM1MzExNTZhNWM1ZjQxYSIsInN1YiI6IjYzODYzNzE0MDM5OGFiMDBjODM5MTJkOSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.qQjwnSQLDfVNAuinpsM-ATK400-dnwuWUVirc7_AiQY',
};

class ImageService {
  Future<List<MovieImage>> getMovieImagesByType(
      {required ImageType imagetype, required int movieId}) async {
    print("here $imagetype");

    List<MovieImage> imageList = [];
    String imageTypeString;
    switch (imagetype) {
      case ImageType.backdrops:
        imageTypeString = "backdrops";
        break;
      case ImageType.posters:
        imageTypeString = "posters";
        break;
      case ImageType.logos:
        imageTypeString = "logos";
        break;

      default:
        imageTypeString = "backdrops";
    }
    // todo: swap url to movieimageurl
    var response = await http.get(
        Uri.parse(ApiEndPoint(id: movieId).getMovieImages),
        headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final imageJson = data[imageTypeString];
      try {
        for (int i = 0; i < imageJson.length; i++) {
          imageList.add(MovieImage.fromJson(imageJson[i]));
        }
      } catch (error) {
        print("Error adding image to imagelist");
      }
    }
    //imageList.sort((a, b) => b.voteAverage.compareTo(a.voteAverage));
    return imageList;
  }
} 

// backdrops: [
// {
//       "aspect_ratio": 0.667,
//       "height": 3000,
//       "iso_639_1": "it",
//       "file_path": "/2NdxHNZGFlYvomCYWkjGUNPqw7g.jpg",
//       "vote_average": 0,
//       "vote_count": 0,
//       "width": 2000
//     },
//],
// posters: [ ...

