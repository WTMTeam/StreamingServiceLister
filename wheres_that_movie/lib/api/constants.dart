//
//
//
//

class ApiEndPoint {
  late String getMovieSuggestions;
  late String getMovieGenresUrl;
  late String getTvShowGenresUrl;
  late String getMovieStreamingProviderInfo;
  late String getMovieStreamingProviderInfoRegion;
  late String getCountries;
  late String getMovieProvidersByMovieID;
  late String getShowProvidersByShowID;
  late String searchMovieShowPerson;
  late String getCastByMovieId;
  late String getCastByShowId;
  late String getMovieImages;
  late String getShowImages;

  // * Genre Docs: https://developer.themoviedb.org/reference/genre-movie-list

  ApiEndPoint(
      {String? searchText,
      int? id,
      String? providerIDs,
      String? genreIDs,
      int? runtime,
      bool? runtimeLessThan,
      String? region}) {
    //Value added for simplicity but it is always better
    //  to add it in a configuration file
    String baseUrlPath = 'https://api.themoviedb.org/3';
    region ??= "US";
    genreIDs ??= ""; // Use pipe | for "or".
    //genreIDs ??= "35|53"; // Use pipe | for "or".
    providerIDs ??= "";
    runtime ??= 999;
    //providerIDs ??= "8|9";

// with_watch_monetization_types
// string
// possible values are: [flatrate, free, ads, rent, buy] use in conjunction with watch_region, can be a comma (AND) or pipe (OR) separated query

    searchMovieShowPerson =
        '$baseUrlPath/search/multi?query=$searchText&include_adult=false';

    getMovieSuggestions =
        '$baseUrlPath/discover/movie?include_adult=false&include_video=false&language=en-US&page=1&sort_by=popularity.desc&watch_region=$region&with_genres=$genreIDs&with_watch_providers=$providerIDs&with_watch_monetization_types=flatrate|free|ads';

    if (runtime != null) {
      getMovieSuggestions += '&with_runtime.lte=$runtime';
    }
    // getMovieSuggestions =
    // '$baseUrlPath/discover/movie?include_adult=false&include_video=false&language=en-US&page=1&sort_by=popularity.desc&watch_region=$region&with_genres=$genreIDs&with_watch_providers=$providerIDs';

    // discover/movie?include_adult=false&include_video=false&language=en-US&page=1&sort_by=popularity.desc&watch_region=US&with_genres=35&with_watch_providers=8

    // Get the list of genres for movies or shows
    getMovieGenresUrl = '$baseUrlPath/genre/movie/list?language=en';
    getTvShowGenresUrl = '$baseUrlPath/genre/tv/list?language=en';

    getMovieProvidersByMovieID = '$baseUrlPath/movie/$id/watch/providers';
    getShowProvidersByShowID = '$baseUrlPath/tv/$id/watch/providers';
    // Get the streaming provider information for movies
    getMovieStreamingProviderInfo =
        '$baseUrlPath/watch/providers/movie?language=en-US';
    getMovieStreamingProviderInfoRegion =
        '$baseUrlPath/watch/providers/movie?language=en-US&watch_region=US';

    // Get the Countries used in TMDidB
    getCountries = '$baseUrlPath/configuration/countries?language=en-US';

    getCastByMovieId = '$baseUrlPath/movie/$id/credits?language=en-US';

    getCastByShowId = '$baseUrlPath/tv/$id/credits?language=en-US';
    getMovieImages = '$baseUrlPath/movie/$id/images';
    getShowImages = '$baseUrlPath/tv/$id/images';
  }
}

// * Use like this
// Future<List<Film>> getAllFilms() async {
//   var response = await http.get(
//     Uri.parse(ApiEndPoint().FILM_ALL),
//   );
// // ...
// }

// Future<Film> getSingleFilm(int idFilm) async {
//   var response = await http.get(
//     Uri.parse(ApiEndPoint(id: idFilm).FILM_SINGLE),
//   );
//   //...
// }
