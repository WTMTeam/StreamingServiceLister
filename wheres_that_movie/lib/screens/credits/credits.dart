// credits.dart
// Author: Samuel Rudqvist
// Created Date: May 22 2023
// Purpose:
//    The credits screen gives credit to people who
//    have been important to the project and to TMDB.
//
// Modification Log:
//    (07/24/2023)(SR): Added JustWatch attribution under TMDB.

import 'package:flutter/material.dart';

class Credits extends StatelessWidget {
  const Credits({super.key});

  @override
  Widget build(BuildContext context) {
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
        title: Text("Credits", style: Theme.of(context).textTheme.displayLarge),
        centerTitle: true,
        backgroundColor: Theme.of(context).canvasColor,
        surfaceTintColor: Colors.transparent,
        shadowColor: Theme.of(context).colorScheme.secondary,
        elevation: 10.0,
      ),
      body: SafeArea(
          bottom: false,
          child: ListView(
            children: [
              Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: ExpansionTile(
                  title: Text(
                    "Scott Sigman",
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 18.0, right: 8.0, bottom: 8.0),
                      child: Text(
                        "Special thanks to Dr. Scott Sigman for all the support during the development of this app.",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                  // tilePadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  // backgroundColor: Theme.of(context).cardColor,
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: ExpansionTile(
                  title: Text(
                    "Testers",
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 18.0, right: 8.0, bottom: 8.0),
                      child: Text(
                        "Thanks to everyone who is helping out by testing the app. Your feedback is truly appreciated.",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                  // tilePadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  // backgroundColor: Theme.of(context).cardColor,
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: ExpansionTile(
                  title: Text(
                    "TMDB",
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 18.0, right: 8.0, bottom: 8.0),
                      child: Text(
                        "This product uses the TMDB API but is not endorsed or certified by TMDB. The provider data is from JustWatch.",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                  // tilePadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  // backgroundColor: Theme.of(context).cardColor,
                ),
              ),
            ],
          )),
    );
  }
}
