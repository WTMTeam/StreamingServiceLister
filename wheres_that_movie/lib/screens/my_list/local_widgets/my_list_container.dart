// my_list_container.dart
// Author: Samuel Rudqvist
// Date Created: Unknown
//
// Purpose:
//    This is displaying the information in the users list
//
// Modification Log:
//    (03/07/2023)(SR): Removed dead code and changed imgUrl
//                      to use interpolation.
//

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wheres_that_movie/api/models/movie_model.dart';
import 'package:wheres_that_movie/api/models/show_model.dart';
import 'package:wheres_that_movie/screens/detailed_page/detailed.dart';
import 'package:wheres_that_movie/screens/detailed_page/new_detailed.dart';
import '../../../widgets/my_container.dart';

class MyListContainer extends StatefulWidget {
  final List<Map<String, dynamic>> myList;
  final ScrollController myController;
  final VoidCallback refreshList;

  final Function(int) onRemoved;
  const MyListContainer({
    super.key,
    required this.myList,
    required this.onRemoved,
    required this.myController,
    required this.refreshList,
  });

  @override
  State<MyListContainer> createState() => _MyListContainerState();
}

class _MyListContainerState extends State<MyListContainer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: widget.myList.length,
          controller: widget.myController,
          // Build each item of the list
          itemBuilder: ((context, index) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              child: MyContainer(
                child: ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: 0.0),
                  leading: CachedNetworkImage(
                    imageUrl:
                        "https://image.tmdb.org/t/p/w45${widget.myList[index]['movieImgPath']}",
                    // * We have to set the width so that the ListTile has a size
                    // * otherwise an error will be thrown
                    width: 45.0,
                  ),
                  title: Text(
                    widget.myList[index]['movieTitle'],
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: IconButton(
                      // Send the item that is to be removed to my_list.dart
                      onPressed: () {
                        final itemToRemove = widget.myList[index]['id'];
                        widget.onRemoved(itemToRemove);
                      },
                      icon: const Icon(Icons.delete_outline)),
                  onTap: () async {
                    bool isMovie = false;
                    if (widget.myList[index]['isMovie'] == 1) {
                      isMovie = true;
                      print("movie ID: ${widget.myList[index]['movieId']}");
                      Movie movie = await MovieService()
                          .getMovieById(widget.myList[index]['movieId']);

                      Get.to(
                          () => NewDetailed(
                                movie: movie,
                              ),
                          transition: Transition.zoom);
                    } else {
                      print("show ID: ${widget.myList[index]['movieId']}");
                      Show show = await ShowService()
                          .getShowById(widget.myList[index]['movieId']);
                      Get.to(
                          () => NewDetailed(
                                show: show,
                              ),
                          transition: Transition.zoom);

                      // Navigator.of(context)
                      //     .push(
                      //   MaterialPageRoute(
                      //     builder: (context) => DetailedPage(
                      //       id: widget.myList[index]['movieId'],
                      //       isMovie: isMovie,
                      //     ),
                      // builder: (context) => DetailedPage(
                      //   id: widget.myList[index]['movieId'],
                      //   isMovie: isMovie,
                      // ),
                      //   ),
                      // )
                      //     .then((_) {
                      //   widget.refreshList();
                      //});
                    }
                  },
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
