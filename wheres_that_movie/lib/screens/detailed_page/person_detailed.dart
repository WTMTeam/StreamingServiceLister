import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wheres_that_movie/api/models/detailed_person_model.dart';
import 'package:wheres_that_movie/api/models/detailed_person_model.dart';
import 'package:wheres_that_movie/api/models/image_model.dart';
import 'package:wheres_that_movie/api/models/movie_model.dart';
import 'package:wheres_that_movie/api/models/person_model.dart';
import 'package:wheres_that_movie/api/models/show_model.dart';
import 'package:wheres_that_movie/screens/detailed_page/new_detailed.dart';

class PersonDetailed extends StatefulWidget {
  final int personId;
  const PersonDetailed({super.key, required this.personId});

  @override
  State<PersonDetailed> createState() => _PersonDetailedState();
}

class _PersonDetailedState extends State<PersonDetailed> {
  // List<Movie> movies = [];
  // List<Show> shows = [];
  bool _isLoading = true;
  late DetailedPerson detailedPerson;

  // DetailedPerson detailedPerson = DetailedPersonService().getDetailedPersonById(personId: widget.person.personID),

  getDetailedPerson(int id) async {
    var res = await DetailedPersonService().getDetailedPersonById(personId: id);

    setState(() {
      detailedPerson = res;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    getDetailedPerson(widget.personId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
    } else {
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
            // actions: [
            //   IconButton(
            //     onPressed: () {
            //       // if (itemInMyList) {
            //       //   _deleteItem(id);
            //       // } else {
            //       //   widget.movie != null
            //       //       ? _addItem(movie: widget.movie)
            //       //       : _addItem(show: widget.show);
            //       // }
            //     },
            //     icon: Icon(
            //         itemInMyList
            //             ? CupertinoIcons.delete
            //             : CupertinoIcons.add_circled,
            //         size: 32,
            //         color: Theme.of(context).primaryColor),
            //   ),
            // ],
          ),
          body: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(detailedPerson.biography),
              detailedPerson.images.isEmpty
                  ? const SizedBox()
                  : displayImages(detailedPerson.images),
            ],
          )));
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
}
