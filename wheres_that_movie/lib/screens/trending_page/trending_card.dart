// trending_card.dart
// Author: Samuel Rudqvist
// Date Created: Unknown

// Purpose:
//    Creates the card for the carousel on the trending screen

// Modification Log:
//    (03/07/2023)(SR): Removed dead code.
//    (03/07/2023)(SR): Changed deprecated headlines
//    (07/24/2023)(SR): Added placeholders in case the images are not loaded.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:wheres_that_movie/api/models/movie_model.dart';
import 'package:wheres_that_movie/api/models/show_model.dart';
import 'package:wheres_that_movie/screens/detailed_page/new_detailed.dart';

class CarouselCard extends StatelessWidget {
  final Movie? movie;
  final Show? show;
  final bool isHorizontal;
  const CarouselCard({
    super.key,
    this.movie,
    this.show,
    required this.isHorizontal,
  });

  @override
  Widget build(BuildContext context) {
    bool isMovie = movie != null;
    String title = movie?.title ?? show?.title ?? 'Unknown Title';
    String imgUrl =
        'https://image.tmdb.org/t/p/original${movie?.posterPath ?? show?.posterPath ?? ''}';
    double screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        Get.to(
            () => NewDetailed(
                  movie: movie,
                  show: show,
                ),
            transition: Transition.zoom);
      },
      child: Container(
        /* width: 300, */
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
        child: CachedNetworkImage(
          placeholder: (context, imgUrl) => const Center(
            child: CircularProgressIndicator(),
          ),
          imageUrl: imgUrl,
          width: 300,
          errorWidget: (context, imgUrl, error) => const Icon(
            Icons.no_photography_outlined,
            size: 50,
          ),
        ),
      ),
    );
  }
}
