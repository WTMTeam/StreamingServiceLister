class ApiEndPoint {
  late String getMovieStreamingProviderInfoRegion;
  late String getMovieStreamingProviderInfo;
  late String getMovieProvidersByMovieID;
  late String getMovieSuggestions;
  late String getMovieGenresUrl;
  late String getMovieByMovieId;
  late String getTrendingMovies;
  late String getCastByMovieId;
  late String getMovieImages;

  late String getShowProvidersByShowID;
  late String getTvShowGenresUrl;
  late String getTrendingShows;
  late String getShowByShowId;
  late String getCastByShowId;
  late String getShowImages;

  late String getTrendingPeople;

  late String searchMovieShowPerson;
  late String getCountries;

  // * Genre Docs: https://developer.themoviedb.org/reference/genre-movie-list

  ApiEndPoint(
      {String? searchText,
      int? id,
      String? providerIDs,
      String? genreIDs,
      int? runtime,
      bool? runtimeLessThan,
      String? region,
      String? timeWindow}) {
    //Value added for simplicity but it is always better
    //  to add it in a configuration file
    String baseUrlPath = 'https://api.themoviedb.org/3';
    region ??= "US";
    genreIDs ??= "";
    providerIDs ??= "";
    runtime ??= 999;
    timeWindow ??= "week"; // can be day or week

// can be a comma (AND) or pipe (OR) separated query

// Movies
    getMovieStreamingProviderInfoRegion =
        '$baseUrlPath/watch/providers/movie?language=en-US&watch_region=US';
    getMovieStreamingProviderInfo =
        '$baseUrlPath/watch/providers/movie?language=en-US';
    getMovieProvidersByMovieID = '$baseUrlPath/movie/$id/watch/providers';
// check this
    getMovieSuggestions =
        '$baseUrlPath/discover/movie?include_adult=false&include_video=false&language=en-US&page=1&sort_by=popularity.desc&watch_region=$region&with_genres=$genreIDs&with_watch_providers=$providerIDs&with_watch_monetization_types=flatrate|free|ads&with_runtime.lte=$runtime';

    //getMovieSuggestions += '&with_runtime.lte=$runtime';

    getMovieGenresUrl = '$baseUrlPath/genre/movie/list?language=en';
    getMovieByMovieId = '$baseUrlPath/movie/$id';
    getTrendingMovies = '$baseUrlPath/trending/movie/$timeWindow';
    getCastByMovieId = '$baseUrlPath/movie/$id/credits?language=en-US';
    getMovieImages = '$baseUrlPath/movie/$id/images';

// Shows
    getShowProvidersByShowID = '$baseUrlPath/tv/$id/watch/providers';
    getTvShowGenresUrl = '$baseUrlPath/genre/tv/list?language=en';
    getTrendingShows = '$baseUrlPath/trending/tv/$timeWindow';
    getShowByShowId = '$baseUrlPath/tv/$id';
    getCastByShowId = '$baseUrlPath/tv/$id/credits?language=en-US';
    getShowImages = '$baseUrlPath/tv/$id/images';

// People
    getTrendingPeople = '$baseUrlPath/trending/person/$timeWindow';

// General
    searchMovieShowPerson =
        '$baseUrlPath/search/multi?query=$searchText&include_adult=false';
    getCountries = '$baseUrlPath/configuration/countries?language=en-US';
  }
}
