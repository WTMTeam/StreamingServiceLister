// my_list.dart
// Author: Samuel Rudqvist
// Date Created: 09/19/2022
//
// Purpose:
//    This is where the user can view the movies and shows
//    in their list that is saved locally on their phone.
// Modification Log:
//    (03/07/2023)(SR): Removed dead code.
//    (04/07/2023)(SR): The appBar has been added.
//

import 'package:flutter/material.dart';
import 'package:wheres_that_movie/database/database_helper.dart';
import 'package:wheres_that_movie/screens/my_list/local_widgets/my_list_container.dart';

class MyList extends StatefulWidget {
  const MyList({super.key});

  @override
  State<MyList> createState() => _MyListState();
}

class _MyListState extends State<MyList> {
  final myController = TextEditingController();

  List<Map<String, dynamic>> myList = [];
  bool _isLoading = true;

  // Refresh the list
  void _refreshList() async {
    final data = await SQLHelper.getMovies();
    setState(() {
      myList = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  // Delete an item
  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    _refreshList();
  }

  ScrollController myScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Text("isLoading"),
      );
    } else {
      return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: myList.isEmpty
                ? Text(
                    "Add a Movie or Show",
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  )
                : Text(
                    "Your List",
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
            centerTitle: true,
            backgroundColor: Theme.of(context).canvasColor,
            surfaceTintColor: Colors.transparent,
            shadowColor: Theme.of(context).colorScheme.secondary,
            elevation: 10.0,
          ),
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: MyListContainer(
                      myList: myList,
                      myController: myScrollController,
                      refreshList: _refreshList,
                      onRemoved: (itemToRemove) {
                        setState(() {
                          _deleteItem(itemToRemove);
                        });
                      }),
                ),
                const SizedBox(
                  height: 25.0,
                ),
              ]),
            ),
          ));
    }
  }
}
