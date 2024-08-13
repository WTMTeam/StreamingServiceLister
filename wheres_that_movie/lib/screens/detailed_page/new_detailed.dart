import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wheres_that_movie/api/models/cast_model.dart';
import 'package:wheres_that_movie/api/models/image_model.dart';
import 'package:wheres_that_movie/api/models/movie_model.dart';
import 'package:wheres_that_movie/api/models/provider_model.dart';
import 'package:wheres_that_movie/api/models/show_model.dart';
import 'package:wheres_that_movie/database/database_helper.dart';
import 'package:wheres_that_movie/screens/detailed_page/local_widgets/display_description.dart';
import 'package:wheres_that_movie/screens/detailed_page/local_widgets/options_modal.dart';

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
  List<CastMember> cast = [];
  List<MovieImage> movieImages = [];
  //List<Person> castPersonList = [];
  //List<CastMember> castMemebers = [];
  List<int> castIds = [];

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

      if (movie != null) {
        id = movie.movieID;
        isMovie = true;
        allProviders = await ProviderService()
            .getProvidersByIdAndType(id, isMovie, countryCode);
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
      print("New Detailed Error:");
      print("Error $e");
      // todo:
      //    display an error message and redirect to search page
    }
  }

  getMovieCastList(int id) async {
    var castList = await CastService().getCastByMovieId(
      movieId: id,
    );

    setState(() {
      cast = castList;
    });
  }

  getShowCastList(int id) async {
    var castList = await CastService().getCastByShowId(
      showId: id,
    );

    setState(() {
      cast = castList;
    });
  }

  getMovieImages(int id) async {
    var imageList = await ImageService()
        .getMovieImagesByType(imagetype: ImageType.backdrops, movieId: id);

    setState(() {
      movieImages = imageList;
    });
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

    if (widget.movie != null) {
      getMovieCastList(widget.movie!.movieID);
      getMovieImages(widget.movie!.movieID);
    } else if (widget.show != null) {
      getShowCastList(widget.show!.showID);
    }

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
      String title = "Missing Title";

      if (widget.movie != null) {
        title = widget.movie!.title;
      } else if (widget.show != null) {
        title = widget.show!.title;
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
          surfaceTintColor: Colors.transparent,
          shadowColor: Theme.of(context).colorScheme.secondary,
          elevation: 10.0,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              movieImages.isEmpty
                  ? const SizedBox()
                  : displayImages(movieImages),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      currentOption,
                      style: Theme.of(context).textTheme.labelLarge,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        backgroundColor: Theme.of(context).cardColor,
                        context: context,
                        builder: (BuildContext context) {
                          return optionsModal(context, (String selectedOption) {
                            setState(() {
                              currentOption = selectedOption;
                            });
                          });
                        },
                      );
                    },
                    icon: Icon(
                      size: 32.0,
                      CupertinoIcons.line_horizontal_3_decrease,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              displayList(currentOption),
              DescriptionCard(
                  description: widget.movie?.overview ??
                      widget.show?.overview ??
                      'No overview available'),

              displayCast(cast),
              // DescriptionCard(
              //   description: "Your description here",
              //   padding: EdgeInsets.all(16.0),
              //   textStyle: TextStyle(fontSize: 16, color: Colors.blue),
              // )

              // Get the cast
            ],
          ),
        ),
      );
    }
  }

  Widget displayImages(List<MovieImage> movieImages) {
    return (SizedBox(
      child: CarouselSlider.builder(
        options: CarouselOptions(
            autoPlay: true,
            autoPlayAnimationDuration: const Duration(milliseconds: 1500),
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayCurve: Curves.ease,
            //autoPlayCurve: Curves.easeInToLinear,
            //autoPlayCurve: Curves.linearToEaseOut,
            aspectRatio: movieImages[0].aspectRatio,
            viewportFraction: 0.9),
        itemCount: movieImages.length,
        itemBuilder: (context, index, realIndex) {
          String path =
              "https://image.tmdb.org/t/p/original${movieImages[index].filePath}";
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 20.0),
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(28.0)),
              shape: BoxShape.rectangle,
            ),
            child: CachedNetworkImage(
              placeholder: (context, url) => Container(
                margin: const EdgeInsets.symmetric(vertical: 20.0),
                //width: width - 10,
                height: 2000,
                decoration: const BoxDecoration(
                  color: Colors.transparent, // Placeholder color
                  borderRadius: BorderRadius.all(Radius.circular(28.0)),
                ),
              ),
              fadeOutDuration: const Duration(milliseconds: 150),
              imageUrl: path,
              errorWidget: (context, posterUrl, error) => const Icon(
                Icons.no_photography_outlined,
                size: 50,
              ),
            ),
          );
        },
      ),
    ));
  }

  // providerType needs to be
  // streamingProviders
  // rentProviders
  // buyProviders
  Widget displayList(String option) {
    String providerType;
    String errorText;

    switch (option.toLowerCase()) {
      case "stream":
        providerType = "streamingProviders";
        errorText = "streaming";
        break;
      case "rent":
        providerType = "rentProviders";
        errorText = "renting";
        break;
      case "buy":
        providerType = "buyProviders";
        errorText = "buying";
        break;
      default:
        throw ArgumentError('Invalid option: $option');
    }
    if (allProviders[providerType] == null) {
      return Text("Could not load $providerType");
    } else if (allProviders[providerType]!.isEmpty) {
      return Center(
        child: Text(
          "There are no $errorText providers",
          style: Theme.of(context).textTheme.displayMedium,
        ),
      );
    }
    return (Container(
      margin: const EdgeInsets.only(bottom: 12.0, left: 5.0, right: 5.0),
      height: 92.0,
      child: ListView.builder(
        itemCount: allProviders[providerType]!.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: ((context, index) {
          Provider provider = allProviders[providerType]![index];
          String providerImageUrl =
              "https://image.tmdb.org/t/p/w92${provider.logoPath}";

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 6.0),
            child: InkWell(
              onTap: () {
                //call to open provider app?
              },
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(12.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5), // Shadow color
                      spreadRadius: 2, // Spread radius
                      blurRadius: 5, // Blur radius
                      offset:
                          const Offset(1, 2), // Offset from the top left corner
                    ),
                  ],
                ),
                child: CachedNetworkImage(
                  imageUrl: providerImageUrl,
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          );
        }),
      ),
    ));
  }

  Widget displayCast(List<CastMember> cast) {
    return (Container(
      margin: const EdgeInsets.only(bottom: 12.0, left: 5.0, right: 5.0),
      height: 92.0,
      child: ListView.builder(
        itemCount: cast.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: ((context, index) {
          CastMember castMember = cast[index];
          String profilePath =
              "https://image.tmdb.org/t/p/w92${castMember.profilePath}";

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 6.0),
            child: InkWell(
              onTap: () {
                // Go to person page
              },
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(12.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5), // Shadow color
                      spreadRadius: 2, // Spread radius
                      blurRadius: 5, // Blur radius
                      offset:
                          const Offset(1, 2), // Offset from the top left corner
                    ),
                  ],
                ),
                child: CachedNetworkImage(
                  imageUrl: profilePath,
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          );
        }),
      ),
    ));
  }
}
