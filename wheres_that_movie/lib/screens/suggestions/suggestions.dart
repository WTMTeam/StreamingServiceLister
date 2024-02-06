// suggestions.dart
// Author: Samuel Rudqvist
// Date Created: 07/24/2023
//
// Purpose:
//   This is the screen where the user can select their
//   streaming services and one or more genres of movies
//   and get a suggestion of what to watch.
//
// Todo:
// * See #17
// Modification Log:
//    (xx/xx/xxxx)(SR):

// GENRE CODES
//https://www.themoviedb.org/talk/5daf6eb0ae36680011d7e6ee

// ? https://levelup.gitconnected.com/how-i-organize-api-files-in-my-flutter-project-8f21c17050df

// * Example: https://api.themoviedb.org/3/discover/movie?include_adult=false&include_video=true&language=en-US&page=1&sort_by=popularity.desc&watch_region=US&with_genres=35&with_watch_providers=8'

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wheres_that_movie/api/models/movie_model.dart';
import 'package:wheres_that_movie/api/models/genre_model.dart';
import 'package:wheres_that_movie/api/models/provider_model.dart';
import 'package:wheres_that_movie/screens/detailed_page/detailed.dart';
import 'package:wheres_that_movie/screens/suggestions/options_dialog.dart';
import 'package:wheres_that_movie/widgets/country_dropdown.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';

class Suggestions extends StatefulWidget {
  const Suggestions({super.key});

  @override
  State<Suggestions> createState() => _SuggestionsState();
}

class _SuggestionsState extends State<Suggestions> {
  final ScrollController _scrollController = ScrollController();
  final List<String> providers = ['Netflix', 'Apple TV', 'Disney'];
  final List<String> genres = ['Comedy', 'Horror', 'Thriller'];
  final List<String> movieOrShow = ['Movie', 'TV-Show'];
  final List<String> lengths = [
    '<30min',
    '30-60min',
    '60-90min',
    '90-120min',
    '120min>'
  ];
  List<Provider>? currentProviders;
  List<Genre>? currentGenres;
  List<String> options = ["Stream", "Buy", "Rent"];
  String currentMovieOrShow = 'Movie';
  String countryCode = "US";
  String currentOption = "Stream";
  dynamic currentLength = 'Choose Length';
  bool lengthLessThan = false;
  bool providerSelectAll = false;
  bool genreSelectAll = false;

  Future<List<Movie>>? movieSuggestions;

  List<int> testList = [1, 2, 3, 4, 5, 6];

  void setProviders(dynamic selectedProviders, {bool? selectAll}) {
    if (selectedProviders.isEmpty) {
      setState(() {
        currentProviders = null;
      });
    } else {
      currentProviders = selectedProviders;
      if (selectAll != null) {
        setState(() {
          providerSelectAll = selectAll;
        });
      }
    }
  }

  void setGenres(dynamic selectedGenres, {bool? selectAll}) {
    setState(() {
      if (selectedGenres.isEmpty) {
        currentGenres = null;
      }
      currentGenres = selectedGenres;
      if (selectAll != null) {
        genreSelectAll = selectAll;
      }
    });
  }

  void setMovieOrShow(dynamic option, {bool? selectAll}) {
    if (option == "Movie") {
      option = "TV Show";
    } else if (option == "TV Show") {
      option = "Movie";
    }
    setState(() {
      currentMovieOrShow = option;
    });
  }

  void setLength(dynamic lengthList, {bool? selectAll}) {
    setState(() {
      currentLength = lengthList[0];
      lengthLessThan = lengthList[1];
    });
  }

  void _showOptionsDialog(BuildContext context,
      Function(dynamic, {bool? selectAll}) setCurrentOption, button,
      {List<Provider>? currentProviders,
      List<Genre>? currentGenres,
      int? currentLength}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return OptionsDialog(
          button: button,
          countryCode: countryCode,
          currentProviders: currentProviders,
          currentGenres: currentGenres,
          currentLength: currentLength,
          onOptionSelected: (option, {bool? selectAllCallback}) {
            setCurrentOption(option, selectAll: selectAllCallback);
          },
        );
      },
    );
  }

  double getViewportFraction(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Adjust these threshold values based on your preference
    if (screenWidth > 400) {
      return 0.8;
    } else {
      return 0.9;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            CupertinoIcons.arrow_left,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          "Suggestions",
          style: Theme.of(context).textTheme.displayLarge,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).canvasColor,
        elevation: 10.0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 0.0, vertical: 20.0),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 10.0,
                  ),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(50.0)),
                  child: CountryDropdown(
                    onChanged: (code) {
                      countryCode = code;
                      print("Code: $code");
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                      top: 5.0, bottom: 5.0, left: 10.0, right: 10.0),
                  alignment: Alignment.bottomLeft,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.0),
                      border:
                          Border.all(color: Theme.of(context).primaryColor)),
                  constraints: const BoxConstraints(maxHeight: 55.0),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: DropdownButton(
                      isExpanded: true,
                      underline: Container(),
                      borderRadius: BorderRadius.circular(10.0),
                      dropdownColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      value: currentOption,
                      items: options
                          .map<DropdownMenuItem<String>>(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (String? value) => setState(
                        () {
                          if (value != null) currentOption = value;
                        },
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _showOptionsDialog(
                                context, setProviders, "Provider",
                                currentProviders: currentProviders);
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(175, 40),
                            // maximumSize: const Size(200, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          child: const Text("Providers"),
                        ),
                        const SizedBox(
                          height: 4.0,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _showOptionsDialog(context, setGenres, "Genre",
                                currentGenres: currentGenres);
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(175, 40),
                            // maximumSize: const Size(200, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          child: const Text("Genres"),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        ElevatedButton.icon(
                          //icon: const Icon(Icons.sync_outlined),
                          icon: const Icon(CupertinoIcons.shuffle),
                          onPressed: null,
                          // onPressed: () {
                          //   setMovieOrShow(currentMovieOrShow);
                          // },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(175, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          label: Text(currentMovieOrShow),
                        ),
                        const SizedBox(
                          height: 4.0,
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(CupertinoIcons.timer),
                          onPressed: () {
                            if (currentLength.runtimeType != int) {
                              currentLength = null;
                            }
                            _showOptionsDialog(context, setLength, "length",
                                currentLength: currentLength);
                          },
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size(175, 40),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0))),
                          label: currentLength.runtimeType == int
                              ? Text('${currentLength.toString()}min')
                              : const Text("Choose Length"),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 6.0, horizontal: 20.0),
                  child: Divider(
                    thickness: 2.0,
                    color: Theme.of(context).highlightColor,
                  ),
                ),
                if (currentProviders != null)
                  if (!providerSelectAll)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        spacing: 8.0,
                        children: currentProviders!
                            .map(
                              (provider) => ElevatedButton(
                                onPressed: () {
                                  print(provider.providerName);
                                  print(
                                      "PRovider select all: $providerSelectAll");
                                },
                                style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(100, 40),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                    side: BorderSide(
                                        width: 2.0,
                                        color: Theme.of(context).primaryColor)),
                                child: Text(provider.providerName),
                              ),
                            )
                            .toList(),
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(100, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          side: BorderSide(
                              width: 2.0,
                              color: Theme.of(context).primaryColor)),
                      child: const Text("All Providers"),
                    ),
                if (currentGenres != null)
                  if (!genreSelectAll)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        spacing: 8.0,
                        children: currentGenres!
                            .map(
                              (genre) => ElevatedButton(
                                onPressed: () {
                                  print(genre.genreName);
                                },
                                style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(100, 40),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                    side: BorderSide(
                                        width: 2.0,
                                        color: Theme.of(context).primaryColor)),
                                child: Text(genre.genreName),
                              ),
                            )
                            .toList(),
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(100, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          side: BorderSide(
                              width: 2.0,
                              color: Theme.of(context).primaryColor)),
                      child: const Text("All Genres"),
                    ),
                ElevatedButton(
                  child: const Text("Get Suggestions"),
                  onPressed: () async {
                    try {
                      // Call the asynchronous function and wait for the result
                      if (currentLength.runtimeType != int) {
                        currentLength = null;
                      }
                      setState(() {
                        movieSuggestions = MovieService().getMovieSuggestions(
                          currentOption: currentOption,
                          providers: currentProviders,
                          genres: currentGenres,
                          region: countryCode,
                          runtime: currentLength,
                        );
                      });
                    } catch (error) {
                      // Handle errors if any
                      print("Error fetching movie suggestions: $error");
                    }
                  },
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
                  child: FutureBuilder<List<Movie>>(
                    future: movieSuggestions,
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Text("Something Went Wrong ");
                        //return Text("Error: ${snapshot.error}");
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text(""));
                      } else {
                        //print("Snapshot: ${snapshot.data.length}");
// After loading your content, scroll to a specific position
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          double maxScrollOffset =
                              _scrollController.position.maxScrollExtent;

                          // Calculate the scrolling position as a percentage of the screen height
                          _scrollController.animateTo(
                            maxScrollOffset,
                            // Specify the position where you want to scroll
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        });
                        return CarouselSlider.builder(
                          options: CarouselOptions(
                              height: 450.0,
                              aspectRatio: 1.5,
                              viewportFraction: getViewportFraction(context)),
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index, realIndex) {
                            Movie movie = snapshot.data[index];
                            String posterUrl =
                                "https://image.tmdb.org/t/p/w300${movie.posterPath}";
                            return InkWell(
                              onTap: () {
                                Get.to(
                                    () => DetailedPage(
                                        id: movie.movieID, isMovie: true),
                                    transition: Transition.zoom);
                                // Navigator.of(context).push(
                                //   MaterialPageRoute(
                                //     builder: (context) => DetailedPage(
                                //         id: movie.movieID, isMovie: true),
                                //   ),
                                // );
                              },
                              child: Container(
                                height: 450,
                                width: 300,
                                clipBehavior: Clip.antiAlias,
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                  shape: BoxShape.rectangle,
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: posterUrl,
                                  width: 500,
                                  errorWidget: (context, posterUrl, error) =>
                                      const Icon(
                                    Icons.no_photography_outlined,
                                    size: 50,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
