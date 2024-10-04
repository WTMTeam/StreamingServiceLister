import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wheres_that_movie/api/models/detailed_person_model.dart';
import 'package:wheres_that_movie/api/models/image_model.dart';
import 'package:wheres_that_movie/api/models/movie_credit_model.dart';
import 'package:wheres_that_movie/api/models/movie_model.dart';
import 'package:wheres_that_movie/api/models/show_credit_model.dart';
import 'package:wheres_that_movie/api/models/show_model.dart';
import 'package:wheres_that_movie/screens/detailed_page/new_detailed.dart';
import 'package:wheres_that_movie/widgets/long_text_container.dart';

class PersonDetailed extends StatefulWidget {
  final int personId;
  const PersonDetailed({super.key, required this.personId});

  @override
  State<PersonDetailed> createState() => _PersonDetailedState();
}

class _PersonDetailedState extends State<PersonDetailed> {
  List<Movie> movies = [];
  List<Show> shows = [];
  bool _isLoading = true;
  bool _isError = false;
  String _errorText = "";
  late DetailedPerson detailedPerson;

  getDetailedPerson(int id) async {
    try {
      var res =
          await DetailedPersonService().getDetailedPersonById(personId: id);

      getMovies(res.movieCastCredits, res.movieCrewCredits);
      getShows(res.showCastCredits, res.showCrewCredits);

      setState(() {
        detailedPerson = res;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isError = true;
        _errorText = error.toString();
      });
    }
  }

  getMovies(
      List<MovieCastCredit> castCredits, List<MovieCrewCredit> crewCredits) {
    for (var credit in castCredits) {
      movies.add(credit.movie);
    }
    for (var crew in crewCredits) {
      movies.add(crew.movie);
    }
  }

  getShows(List<ShowCastCredit> castCredits, List<ShowCrewCredit> crewCredits) {
    for (var credit in castCredits) {
      shows.add(credit.show);
    }
    for (var crew in crewCredits) {
      shows.add(crew.show);
    }
  }

  @override
  void initState() {
    getDetailedPerson(widget.personId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).canvasColor,
          surfaceTintColor: Colors.transparent,
          shadowColor: Theme.of(context).colorScheme.secondary,
          elevation: 10.0,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              CupertinoIcons.fullscreen_exit,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        body: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    } else if (_isError) {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).canvasColor,
            surfaceTintColor: Colors.transparent,
            shadowColor: Theme.of(context).colorScheme.secondary,
            elevation: 10.0,
            centerTitle: true,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                CupertinoIcons.arrow_down,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              "Something went wrong",
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Text(_errorText),
              ],
            ),
          ));
    } else {
      return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                CupertinoIcons.fullscreen_exit,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: detailedPerson.name.length > 10
                ? Text(
                    detailedPerson.name,
                    style: Theme.of(context).textTheme.displayMedium,
                    overflow: TextOverflow.ellipsis,
                  )
                : Text(
                    detailedPerson.name,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
            centerTitle: true,
            backgroundColor: Theme.of(context).canvasColor,
            surfaceTintColor: Colors.transparent,
            shadowColor: Theme.of(context).colorScheme.secondary,
            elevation: 10.0,
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: Icon(CupertinoIcons.home,
                    size: 32, color: Theme.of(context).primaryColor),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                detailedPerson.images.isEmpty
                    ? const SizedBox()
                    : Center(
                        child: SizedBox(
                            height: 400,
                            width: width,
                            child: displayImages(detailedPerson.images)),
                      ),
                Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: LongText(longText: detailedPerson.biography)),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    "Movies",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                displayMovies(movies),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    "TV-Shows",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                displayShows(shows),
              ],
            )),
          ));
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
            aspectRatio: movieImages[0].aspectRatio,
            viewportFraction: 0.7),
        itemCount: movieImages.length,
        itemBuilder: (context, index, realIndex) {
          String path =
              "https://image.tmdb.org/t/p/original${movieImages[index].filePath}";
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 20.0),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(28.0)),
              shape: BoxShape.rectangle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(1, 2),
                ),
              ],
            ),
            child: CachedNetworkImage(
              placeholder: (context, url) => Container(
                margin: const EdgeInsets.symmetric(vertical: 20.0),
                height: 2000,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
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

  Widget displayMovies(List<Movie> movies) {
    movies.sort((b, a) => a.rating.compareTo(b.rating));
    return (Container(
      margin: const EdgeInsets.only(bottom: 12.0, left: 5.0, right: 5.0),
      height: 150.0,
      child: ListView.builder(
        itemCount: movies.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: ((context, index) {
          Movie movie = movies[index];
          bool missingPath = movie.posterPath.isEmpty;

          if (!missingPath) {
            String profilePath =
                "https://image.tmdb.org/t/p/original${movie.posterPath}";

            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 6.0, horizontal: 6.0),
              child: InkWell(
                onTap: () {
                  Get.to(
                      () => NewDetailed(
                            movie: movie,
                          ),
                      transition: Transition.zoom);
                },
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(12.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(1, 2),
                      ),
                    ],
                  ),
                  child: CachedNetworkImage(
                    imageUrl: profilePath,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              ),
            );
          } else {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 6.0, horizontal: 6.0),
              child: InkWell(
                onTap: () {
                  Get.to(
                      () => NewDetailed(
                            movie: movie,
                          ),
                      transition: Transition.zoom);
                },
                child: Container(
                  width: 92.0,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(12.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(1, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      movie.title.split(' ').join('\n'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ),
            );
          }
        }),
      ),
    ));
  }

  Widget displayShows(List<Show> shows) {
    shows.sort((b, a) => a.rating.compareTo(b.rating));
    return (Container(
      margin: const EdgeInsets.only(bottom: 12.0, left: 5.0, right: 5.0),
      height: 150.0,
      child: ListView.builder(
        itemCount: shows.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: ((context, index) {
          Show show = shows[index];
          bool missingPath = show.posterPath.isEmpty;

          if (!missingPath) {
            String profilePath =
                "https://image.tmdb.org/t/p/original${show.posterPath}";

            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 6.0, horizontal: 6.0),
              child: InkWell(
                onTap: () {
                  Get.to(
                      () => NewDetailed(
                            show: show,
                          ),
                      transition: Transition.zoom);
                },
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(12.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(1, 2),
                      ),
                    ],
                  ),
                  child: CachedNetworkImage(
                    imageUrl: profilePath,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              ),
            );
          } else {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 6.0, horizontal: 6.0),
              child: InkWell(
                onTap: () {
                  Get.to(
                      () => NewDetailed(
                            show: show,
                          ),
                      transition: Transition.zoom);
                },
                child: Container(
                  width: 92.0,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(12.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(1, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      show.title.split(' ').join('\n'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ),
            );
          }
        }),
      ),
    ));
  }
}
