// logged_in.dart
// Author: Samuel Rudqvist
// Date Created: 09/10/2022
//
// Purpose:
//    This is the screen that the user is presented with after
//    the splash screen. Here the user can search for movies
//    and shows, click them to see more information or click a
//    button to see the trending movies or shows.
//
// Modification Log:
//    (03/07/2023)(SR): Removed dead code.
//    (03/07/2023)(SR): Changed deprecated headlines and imageUrl to
//                      use interpolation.
//    (04/07/2023)(SR): The appBar is now implemented, cards disappearing
//                      is now handled.
//    (05/25/2023)(SR): Added Credits to the Drawer menu.
//    (07/24/2023)(SR): Added CircularProgressIndicator for loading search results.
//                      Added clear as an optional parameter to mySearch, with default value
//                      of false. Added navigation to the suggestions screen.
//    (04/10/2024)(SR): Reimplemented the search function with the http package.
//                      Redesigned the search carousel to match the suggestions carousel.

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wheres_that_movie/api/constants.dart';
import 'package:wheres_that_movie/api/models/movie_model.dart';
import 'package:wheres_that_movie/api/models/show_model.dart';
import 'package:wheres_that_movie/screens/credits/credits.dart';
import 'package:wheres_that_movie/screens/detailed_page/new_detailed.dart';
import 'package:wheres_that_movie/screens/my_list/my_list.dart';
import 'package:wheres_that_movie/screens/suggestions/suggestions.dart';
import 'package:wheres_that_movie/screens/trending_page/trending.dart';
import 'package:wheres_that_movie/utils/provider/dark_theme_provider.dart';
import 'package:tmdb_api/tmdb_api.dart';
import 'local_widgets/search_result_cards.dart';
import 'package:get/get.dart';

class MyLoggedIn extends StatefulWidget {
  const MyLoggedIn({super.key});

  @override
  State<MyLoggedIn> createState() => _MyLoggedInState();
}

// * https://api.themoviedb.org/3/discover/movie?sort_by=popularity.desc&api_key=dbffa0d16fb8dc2873531156a5c5f41a

// https://www.youtube.com/watch?v=ll8B8OnqVp4
class _MyLoggedInState extends State<MyLoggedIn> {
  final String apiKey = 'dbffa0d16fb8dc2873531156a5c5f41a';
  final String readAccessToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkYmZmYTBkMTZmYjhkYzI4NzM1MzExNTZhNWM1ZjQxYSIsInN1YiI6IjYzODYzNzE0MDM5OGFiMDBjODM5MTJkOSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.qQjwnSQLDfVNAuinpsM-ATK400-dnwuWUVirc7_AiQY';

  String previousSearch = "";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final myController = TextEditingController();
  final carouselController = PageController(viewportFraction: 0.8);
  final scrollController = ScrollController();
  int pageCount = 1;
  List searchResults = [];
  List tvShows = [];
  List movies = [];
  List people = [];
  List cards = [];
  List showsAndMovies = [];

  bool loadingSearchResults = false;

  mySearch({clear = false}) async {
    searchResults = [];
    tvShows = [];
    movies = [];
    people = [];
    showsAndMovies = [];
    setState(() {
      cards = [];
      loadingSearchResults = !clear;
    });

    // ? Redundant?
    if (myController.text.isEmpty) {
      setState(() {
        cards = [];
      });
    }
    // else if (myController.text == previousSearch) {
    //   // Do nothing
    // }
    else {
      String query = myController.text;

      final Map<String, String> headers = {
        'accept': 'application/json',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkYmZmYTBkMTZmYjhkYzI4NzM1MzExNTZhNWM1ZjQxYSIsInN1YiI6IjYzODYzNzE0MDM5OGFiMDBjODM5MTJkOSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.qQjwnSQLDfVNAuinpsM-ATK400-dnwuWUVirc7_AiQY',
      };
      var response = await http.get(
          Uri.parse(ApiEndPoint(searchText: query).searchMovieShowPerson),
          headers: headers);

      if (response.statusCode != 200) {
        // set an error state
        // early return
        print("Error getting search results");
      }

      final data = jsonDecode(response.body);
      print(data);
      Map result = data;

      setState(() {
        previousSearch = myController.text;
        searchResults = result['results'];
      });

      for (int i = 0; i < searchResults.length; i++) {
        if (searchResults[i]['media_type'] == "movie") {
          Movie currentMovie = Movie.fromJson(searchResults[i]);
          showsAndMovies.add(currentMovie);
        } else if (searchResults[i]['media_type'] == "tv") {
          Show currentShow = Show.fromJson(searchResults[i]);
          showsAndMovies.add(currentShow);
        } else if (searchResults[i]['media_type'] == "person") {
          people.add(searchResults[i]['name']);
        }
      }

      setState(() {
        cards = showsAndMovies;
        loadingSearchResults = false;
      });
    }
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
  void dispose() {
    myController.dispose();
    scrollController.dispose();
    carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = Provider.of<DarkThemeProvider>(context);
    // Scroll to the start of the carousel
    int toTop() {
      try {
        int animTime = carouselController.offset.round();
        if (animTime < 600) {
          animTime = 500;
        }
        // original time 200
        carouselController.animateTo(0,
            duration: Duration(milliseconds: animTime),
            curve: Curves.easeInOut);
        return animTime;
      } catch (e) {
        return 0;
        // Handle errors here
      }
    }

    return Scaffold(
      // Used for opening the drawer header
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          icon: Icon(
            Icons.menu,
            color: Theme.of(context).colorScheme.primary,
            size: 30,
          ),
        ),
        title: Text(
          "Search Movies and Shows",
          style: Theme.of(context).textTheme.displayMedium,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const Suggestions(),
              ));
            },
            icon: Icon(CupertinoIcons.wand_rays,
                color: Theme.of(context).colorScheme.primary),
          ),
        ],
        centerTitle: true,
        backgroundColor: Theme.of(context).canvasColor,
        surfaceTintColor: Colors.transparent,
        shadowColor: Theme.of(context).colorScheme.secondary,
        elevation: 10.0,
      ),

      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          controller: scrollController.hasClients ? scrollController : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(10.0),
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 30.0),
                child: TextField(
                  controller: myController,
                  autofocus: false,
                  onTapOutside: (event) {
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    currentFocus.unfocus();
                  },
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: "Search for a movie or show",
                    prefixIcon: const Icon(
                      Icons.search_outlined,
                      // color: Theme.of(context).primaryColor,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        myController.clear();
                        toTop();

                        mySearch(clear: true);
                      },
                      icon: const Icon(Icons.clear),
                    ),
                  ),
                  onChanged: (value) async {
                    if (myController.text.isEmpty) {
                      mySearch(clear: true);
                      toTop();
                    }
                  },
                  onSubmitted: (value) async {
                    if (myController.text.isEmpty) {
                      // Do nothing
                    } else {
                      int waitTime = toTop();
                      Future.delayed(Duration(milliseconds: waitTime), () {
                        mySearch();
                      });
                    }
                  },
                ),
              ),
              ElevatedButton(
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 100.0),
                  child: Text(
                    "Search",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onPressed: () {
                  if (myController.text.isEmpty) {
                    // Do nothing
                  } else {
                    int waitTime = toTop();
                    Future.delayed(Duration(milliseconds: waitTime), () {
                      mySearch();
                    });
                  }
                },
              ),
              loadingSearchResults
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 200.0),
                      child: CircularProgressIndicator(),
                    )
                  : cards.isEmpty
                      ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 8.0),
                          child: CarouselSlider.builder(
                            options: CarouselOptions(
                                height: 450.0,
                                aspectRatio: 1.5,
                                viewportFraction: getViewportFraction(context)),
                            itemCount: showsAndMovies.length,
                            itemBuilder: (context, index, realIndex) {
                              Movie? movie;
                              Show? show;
                              String isMovie = "";
                              String posterUrl = "";
                              if (showsAndMovies[index] is Movie) {
                                isMovie = "true";
                                movie = showsAndMovies[index];
                                posterUrl =
                                    "https://image.tmdb.org/t/p/w300${movie!.posterPath}";
                              } else if (showsAndMovies[index] is Show) {
                                isMovie = "false";
                                show = showsAndMovies[index];
                                posterUrl =
                                    "https://image.tmdb.org/t/p/w300${show!.posterPath}";
                              } else {
                                print("whuuuut");
                              }
                              return InkWell(
                                onTap: () {
                                  if (isMovie == "true") {
                                    Get.to(() => NewDetailed(movie: movie),
                                        transition: Transition.zoom);
                                  } else if (isMovie == "false") {
                                    Get.to(() => NewDetailed(show: show),
                                        transition: Transition.zoom);
                                  }
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
                          ),
                        ),
              Container(
                margin: const EdgeInsets.only(bottom: 10.0),
                child: ElevatedButton(
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 70.0),
                    child: Text(
                      "See Trending",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onPressed: () {
                    double keyboardValue =
                        MediaQuery.of(context).viewInsets.bottom;

                    FocusScope.of(context).unfocus();
                    if (keyboardValue > 0) {
                      Future.delayed(const Duration(milliseconds: 450), () {
                        Get.to(() => const MyTrending(),
                            transition: Transition.downToUp);
                      });
                    } else {
                      Get.to(() => const MyTrending(),
                          transition: Transition.downToUp);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // Settings Menu
      drawer: Drawer(
          backgroundColor: Theme.of(context).canvasColor,
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                      vertical: 70.0, horizontal: 10.0),
                  children: [
                    Row(
                      children: <Widget>[
                        const Padding(padding: EdgeInsets.only(left: 5.0)),
                        Image.asset(
                          'assets/logo2.png',
                          width: 45,
                          height: 45,
                        ),

                        const SizedBox(
                          width: 10.0,
                        ),
                        // Add the logged in users name
                        Text(
                          "WTM",
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ],
                    ),

                    // Add some space between the username/logo and the first option
                    const SizedBox(
                      height: 20.0,
                    ),

                    Card(
                      color: Theme.of(context).cardColor,
                      child: ListTile(
                        title: Text(
                          "My List",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        leading: Icon(
                          Icons.list,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const MyList(),
                          ));
                        },
                      ),
                    ),

                    Card(
                      color: Theme.of(context).cardColor,
                      child: ListTile(
                        title: Text(
                          "Suggestions",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        // leading: const Icon(CupertinoIcons.shuffle_medium),
                        leading: Icon(
                          CupertinoIcons.wand_rays,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const Suggestions(),
                          ));
                        },
                      ),
                    ),

                    Card(
                      color: Theme.of(context).cardColor,
                      child: SwitchListTile(
                        activeColor: Theme.of(context).canvasColor,
                        title: Text(
                          "Theme",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        secondary: Icon(
                          themeState.getDarkTheme
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onChanged: (bool value) {
                          setState(() {
                            themeState.setDarkTheme = value;
                            previousSearch = "";
                          });
                        },
                        value: themeState.getDarkTheme,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(
                    bottom: 50.0, left: 10.0, right: 10.0),
                child: Card(
                  color: Theme.of(context).cardColor,
                  child: ListTile(
                    title: Text(
                      "Credits",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    leading: Icon(
                      Icons.info_outline,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const Credits(),
                      ));
                    },
                  ),
                ),
              )
            ],
          )),
    );
  }
}
