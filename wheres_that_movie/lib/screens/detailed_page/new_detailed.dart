import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wheres_that_movie/api/models/movie_model.dart';
import 'package:wheres_that_movie/api/models/provider_model.dart';
import 'package:wheres_that_movie/api/models/show_model.dart';
import 'package:wheres_that_movie/database/database_helper.dart';

class NewDetailed extends StatefulWidget {
  final Movie? movie;
  final Show? show;
  const NewDetailed({super.key, this.movie, this.show});

  @override
  State<NewDetailed> createState() => _NewDetailedState();
}

class _NewDetailedState extends State<NewDetailed> {
  Map<String, List<Provider>> allProviders = {};
  List<Provider> currentProviders = [];

  final List<String> options = ["Stream", "Buy", "Rent"];
  final List<String> supportedProviders = [
    'Netflix',
    'Disney Plus',
    'Paramount Plus',
    'Amazon Prime Video',
    'Hulu',
    'fuboTV',
    'Apple TV Plus',
  ];

  String currentOption = "Stream";
  String countryCode = "US";

  bool _isLoading = false;
  bool itemInMyList = false;

  getProviders(String currentOption, String countryCode,
      {Movie? movie, Show? show}) async {
    _isLoading = true;
    try {
      int id;
      bool isMovie;
      // Get the providers
      if (movie != null) {
        id = movie.movieID;
        isMovie = true;
        allProviders = await ProviderService()
            .getProvidersByIdAndType(id, isMovie, countryCode);
        print("New Detailed, Providers: $allProviders");
        _isLoading = false;
      } else if (show != null) {
        id = show.showID;
        isMovie = false;
        allProviders = await ProviderService()
            .getProvidersByIdAndType(id, isMovie, countryCode);
        _isLoading = false;
      } else {
        print("STOP NOT MOVIE OR SHOW");
      }

      print("New Detailed Providers $allProviders");

      setState(() {
        if (currentOption == "Stream") {
          currentProviders = allProviders['streamingProviders']!;
        } else if (currentOption == "Rent") {
          currentProviders = allProviders['rentProviders']!;
        } else if (currentOption == "Buy") {
          currentProviders = allProviders['buyProviders']!;
        }
      });
    } catch (e) {
      print("New Detailed");
      print("Error $e");
      // todo:
      //    display an error message and redirect to search page
    }
  }

  getMyList({Movie? movie, Show? show}) async {
    int id = 0;

    if (movie != null) {
      id = movie.movieID;
    } else if (show != null) {
      id = show.showID;
    }

    bool currExists = await SQLHelper.checkItem(id);
    setState(() {
      itemInMyList = currExists;
    });
  }

  Future<void> _addItem({Movie? movie, Show? show}) async {
    int isMovieInt = movie != null ? 1 : 0;
    int id = movie != null ? movie.movieID : show!.showID;
    String title = movie != null ? movie.title : show!.title;
    String posterPath = movie != null ? movie.posterPath : show!.posterPath;

    await SQLHelper.createItem(id, title, posterPath, isMovieInt);
    setState(() {
      getMyList();
    });
  }

  // Insert a new movie or show to the database
  // Future<void> _addItem({Movie? movie, Show? show}) async {
  //   //int movieId, String movieTitle, String moviePath, bool isMovie) async {
  //   int isMovieInt = 0;
  //   if (movie != null) {
  //     isMovieInt = 1;
  //   }
  //   if (movie != null) {
  //     int id = movie.movieID;
  //     String title = movie.title;
  //     String posterPath = movie.posterPath;
  //     await SQLHelper.createItem(id, title, posterPath, isMovieInt);
  //     setState(() {
  //       getMyList(movie: movie);
  //     });
  //   } else if (show != null) {
  //     int id = show.showID;
  //     String title = show.title;
  //     String posterPath = show.posterPath;
  //     await SQLHelper.createItem(id, title, posterPath, isMovieInt);
  //     setState(() {
  //       getMyList();
  //     });
  //   }
  // }

  void _deleteItem(int movieOrShowId) async {
    List<Map<String, dynamic>> currItem =
        await SQLHelper.getItem(movieOrShowId);
    int id = currItem[0]['id'];
    await SQLHelper.deleteItem(id);
    getMyList();
  }

  @override
  void initState() {
    currentOption = "Stream";
    getProviders(currentOption, countryCode,
        movie: widget.movie, show: widget.show);
    getMyList(movie: widget.movie, show: widget.show);
    super.initState();
  }

  final ScrollController _myController = ScrollController();

  void openApp(String scheme, String title) async {
    Uri appScheme = Uri.parse(scheme);

    // iOS-specific implementation
    if (Platform.isIOS) {
      if (await canLaunchUrl(appScheme)) {
        // print("Can Launch Url");
        if (scheme == 'nflx://') {
          Uri specific = Uri.parse("nflx://www.netflix.com/search?q=$title");
          await launchUrl(specific);
        } else {
          await launchUrl(appScheme);
        }
      } else {
        switch (scheme) {
          case 'nflx://':
            await launchUrl(
                Uri.parse('https://itunes.apple.com/app/id363590051'));
            break;
          case 'disneyplus://':
            await launchUrl(
                Uri.parse('https://itunes.apple.com/app/id1446075923'));
            break;
          case 'paramountplus://':
            await launchUrl(Uri.parse(
                'https://itunes.apple.com/us/app/cbs-all-access-stream-tv/id530168168'));
            break;
          case 'primevideo://':
            await launchUrl(Uri.parse(
                'https://itunes.apple.com/us/app/amazon-prime-video/id545519333'));
            break;
          case 'hulu://':
            await launchUrl(Uri.parse(
                'https://itunes.apple.com/app/hulu-watch-tv-shows-movies/id376510438'));
            break;
          case 'fuboTV://':
            await launchUrl(Uri.parse(
                'https://itunes.apple.com/us/app/fubotv-watch-live-sports-tv/id905401434'));
            break;
          case 'videos://':
            await launchUrl(Uri.parse(
                'https://apps.apple.com/us/app/apple-tv/id1174078549'));
            break;
          // case 'hbomax://':
          //   await launchUrl(Uri.parse(
          //       'https://apps.apple.com/us/app/apple-tv/id1174078549'));
          //   break;
          default:
        }
      }
    }
    // Android-specific implementation
    else {
      //! Implement the rest of these
      const String appPackageName = 'com.netflix.mediaclient';
      if (await DeviceApps.isAppInstalled(appPackageName)) {
        await DeviceApps.openApp(appPackageName);
      } else {
        throw 'Could not launch Netflix.';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      print("loading new detailed");
      return const Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    } else {
      print("should be done loading");
      String title = "Missing Title";
      String backdropUrl = "";

      double width = MediaQuery.of(context).size.width;
      double height = MediaQuery.of(context).size.height;

      if (widget.movie != null) {
        title = widget.movie!.title;
        print(width);
        int widthInt = width.toInt();
        print(widthInt);
        backdropUrl =
            "https://image.tmdb.org/t/p/w300${widget.movie!.backdropPath}";

        //backdropUrl = "https://image.tmdb.org/t/p/w45${widget.movie!.backdropPath}";
      }

      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              // Icons.arrow_back_ios,
              //CupertinoIcons.arrow_down_right_arrow_up_left,
              CupertinoIcons.fullscreen_exit,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: title.length > 10
              ? Text(
                  title,
                  style: Theme.of(context).textTheme.displayMedium,
                  overflow: TextOverflow.ellipsis,
                )
              : Text(
                  title,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
          centerTitle: true,
          backgroundColor: Theme.of(context).canvasColor,
          elevation: 10.0,
        ),
        body: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: backdropUrl,
              fit: BoxFit.fitWidth,
              width: width,
              height: height,
              // You can add placeholder and error widgets if needed
              placeholder: (context, url) =>
                  const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            Column(
              children: [
                const Text("Test"),
              ],
            ),
          ],
        ),
      );
    }
  }
}
