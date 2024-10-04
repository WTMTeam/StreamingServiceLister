// trending.dart
// Author: Samuel Rudqvist
// Date Created: Unknown

// Purpose:
//    This is the screen where the user can see the movies and shows
//    that are currently trending.

// Modification Log:
//    (03/07/2023)(SR): Removed dead code.
//    (03/07/2023)(SR): Changed deprecated headlines
//

import 'dart:math';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wheres_that_movie/api/models/movie_model.dart';
import 'package:wheres_that_movie/screens/trending_page/trending_appbar.dart';
import 'package:wheres_that_movie/screens/trending_page/trending_card.dart';

// carousel https://itnext.io/dynamically-sized-animated-carousel-in-flutter-8a88b005be74

class MyTrending extends StatefulWidget {
  const MyTrending({super.key});

  @override
  State<MyTrending> createState() => _MyTrendingState();
}

class _MyTrendingState extends State<MyTrending> {
  // final String apiKey = 'dbffa0d16fb8dc2873531156a5c5f41a';
  // final String readAccessToken =
  //     'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkYmZmYTBkMTZmYjhkYzI4NzM1MzExNTZhNWM1ZjQxYSIsInN1YiI6IjYzODYzNzE0MDM5OGFiMDBjODM5MTJkOSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.qQjwnSQLDfVNAuinpsM-ATK400-dnwuWUVirc7_AiQY';
  //List trendingMovies = [];
  List<Movie> trendingMovies = [];
  List trendingTitles = [];
  List voteAverageMovie = [];
  List cards = [];
  bool _isLoading = false;
  bool _isError = false;
  String _errorText = "";
  bool isHorizontal = false;
  bool cardsVisible = true;
  final carouselController = PageController(viewportFraction: 0.8);
  final carouselController2 = PageController(viewportFraction: 0.8);

  loadTrendingMovies() async {
    _isLoading = true;
    String timeWindow = "week";
    try {
      trendingMovies = await MovieService().getTrendingMovies(timeWindow);
      makeCardList();
    } catch (error) {
      _errorText = error.toString();
      _isError = true;
      _isLoading = false;
    } finally {
      setState(() {});
    }
  }

  // Make the card list
  makeCardList() {
    // reset the cards list
    List newCards = [];
    for (int i = 0; i < 10; i++) {
      try {
        newCards.add(CarouselCard(
          movie: trendingMovies[i],
          isHorizontal: isHorizontal,
        ));
        setState(() {
          cards = newCards;
        });
      } catch (e) {
        // Print error message
      }
    }
    // All the information should be loaded by now
    _isLoading = false;
  }

  @override
  void initState() {
    loadTrendingMovies();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

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
              CupertinoIcons.arrow_down,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
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
                const Icon(CupertinoIcons.wifi_exclamationmark),
                Text(_errorText),
              ],
            ),
          ));
    } else if (!isHorizontal) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(''),
          backgroundColor: Theme.of(context).canvasColor,
          toolbarHeight: 0,
          elevation: 0.0,
        ),
        body: SafeArea(
          bottom: false,
          child: Stack(children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 80.0),
              child: SizedBox(
                width: screenWidth,
                height: screenHeight / 1.2,
                // height: screenHeight - MediaQuery.of(context).padding.top,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: SizedBox(
                        // padding: const EdgeInsets.only(top: 100.0),
                        // margin: EdgeInsets.only(top: 50.0),
                        width: screenWidth,
                        height: screenHeight / 1.2,
                        // height: screenHeight - MediaQuery.of(context).padding.top,

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ExpandablePageView.builder(
                              scrollDirection: Axis.vertical,
                              controller: carouselController,
                              clipBehavior: Clip.none,
                              itemCount: cards.length,
                              itemBuilder: (_, index) {
                                if (!carouselController
                                    .position.haveDimensions) {
                                  // Wait for the layout to stabilize before attempting to animate the PageController
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    if (carouselController
                                        .position.haveDimensions) {
                                      // If the position has dimensions now, rebuild the widget tree to trigger the animation
                                      setState(() {});
                                    }
                                  });
                                  // return const SizedBox();
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                return Visibility(
                                  visible: cardsVisible,
                                  child: AnimatedBuilder(
                                    animation: carouselController,
                                    builder: (_, __) => Transform.scale(
                                      scale: max(
                                        0.85,
                                        (1 -
                                            (carouselController.page! - index)
                                                    .abs() /
                                                2),
                                      ),
                                      child: cards[index],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            MyCustomAppBar(
              title: "Trending",
              onBackButtonPressed: () {
                setState(() {
                  cardsVisible = false;
                });
                Navigator.of(context).pop();
              },
              onSwipeDown: () {
                setState(() {
                  cardsVisible = false;
                });
                cardsVisible = false;
                Navigator.of(context).pop();
              },
              makeCardList: makeCardList(),
              direction: isHorizontal,
              onIsHorizontalChanged: (newIsHorizontal) {
                setState(() {
                  isHorizontal = newIsHorizontal;
                  makeCardList();
                });
              },
            ),
          ]),
        ),
      );
    } else {
      return Scaffold(
          body: SafeArea(
        bottom: false,
        child: Column(children: <Widget>[
          MyCustomAppBar(
            title: "Trending",
            onBackButtonPressed: () {
              Navigator.of(context).pop();
            },
            onSwipeDown: () {
              Navigator.of(context).pop();
            },
            makeCardList: makeCardList(),
            direction: isHorizontal,
            onIsHorizontalChanged: (newIsHorizontal) {
              setState(() {
                isHorizontal = newIsHorizontal;
                makeCardList();
              });
            },
          ),
          SizedBox(
            height: screenHeight / 1.2,
            width: screenWidth,
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ExpandablePageView.builder(
                        controller: carouselController2,
                        // allows our shadow to be displayed outside of widget bounds
                        clipBehavior: Clip.none,
                        itemCount: cards.length,
                        itemBuilder: (_, index) {
                          if (!carouselController2.position.haveDimensions) {
                            // Wait for the layout to stabilize before attempting to animate the PageController
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (carouselController2.position.haveDimensions) {
                                // If the position has dimensions now, rebuild the widget tree to trigger the animation
                                setState(() {});
                              }
                            });
                            // return const SizedBox();
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return AnimatedBuilder(
                            animation: carouselController2,
                            builder: (_, __) => Transform.scale(
                              scale: max(
                                0.85,
                                (1 -
                                    (carouselController2.page! - index).abs() /
                                        2),
                              ),
                              child: cards[index],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ]),
      ));
    }
  }
}
