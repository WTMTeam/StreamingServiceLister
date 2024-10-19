// logged_in.dart
// Author: Samuel Rudqvist
// Date Created: 03/08/2023
//
// Purpose:
//    This is the a searchable dropdown that gets the countries
//    from tmdb, adds them to the dropdown and updates the database
//    with the choice the user made.
//

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:wheres_that_movie/database/database_helper.dart';

class CountryDropdown extends StatefulWidget {
  final Function(String) onChanged;
  const CountryDropdown({super.key, required this.onChanged});

  @override
  State<CountryDropdown> createState() => _CountryDropdownState();
}

class _CountryDropdownState extends State<CountryDropdown> {
  final String apiKey = 'dbffa0d16fb8dc2873531156a5c5f41a';
  final String readAccessToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkYmZmYTBkMTZmYjhkYzI4NzM1MzExNTZhNWM1ZjQxYSIsInN1YiI6IjYzODYzNzE0MDM5OGFiMDBjODM5MTJkOSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.qQjwnSQLDfVNAuinpsM-ATK400-dnwuWUVirc7_AiQY';

  List<String> countryCodes = [];
  List<String> countryNames = [];
  String selectedCountry = "";
  String selectedCode = "";

  // Get the index of the code/name from the list
  getIndex(String codeOrName) {
    int index = 0;
    if (codeOrName.length > 2) {
      index = countryNames.indexOf(codeOrName);
    } else {
      index = countryCodes.indexOf(codeOrName);
    }
    return index;
  }

  checkDB() async {
    final result = await SQLHelper.getCountry();

    String code = result[0]['code'].toString();
    setState(() {
      selectedCode = code;
      selectedCountry = countryNames[getIndex(code)];
      widget.onChanged(code);
    });
  }

  // Insert a new journal to the database
  Future<void> _setCountry(String countryCode) async {
    await SQLHelper.setCountry(countryCode);
  }

  // reads the json file that contains the countries
  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/countries.json');
    final data = json.decode(response);

    for (final country in data) {
      countryCodes.add(country['iso_3166_1'].toString());
      countryNames.add(country['english_name'].toString());
    }

    return data;
  }

  @override
  void initState() {
    super.initState();
    readJson();
    checkDB();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return DropdownSearch<String>(
      popupProps: PopupProps.menu(
        showSelectedItems: true,
        showSearchBox: true,
        searchDelay: const Duration(milliseconds: 100),
        menuProps: MenuProps(
          borderRadius: BorderRadius.circular(10.0),
          backgroundColor:
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
        ),
        constraints: BoxConstraints(maxHeight: screenHeight / 3),
        itemBuilder:
            (BuildContext context, String item, bool isSelected, bool test) {
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              item,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        },
        searchFieldProps: TextFieldProps(
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: Theme.of(context).textTheme.bodyMedium),
        ),
        emptyBuilder: (context, searchEntry) {
          return Center(
            child: Text(
              'No results found',
              style: Theme.of(context).textTheme.displayMedium,
            ),
          );
        },
      ),
      items: (filter, infiniteScrollProps) => countryNames,
      decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(18.0),
        ),
        labelText: "Select Country",
      )),
      selectedItem: selectedCountry,
      onChanged: (value) async {
        String code = countryCodes[getIndex(value!)];
        await Future.delayed(const Duration(milliseconds: 500));
        _setCountry(code);
        widget.onChanged(code);
      },
      dropdownBuilder: (context, selectedItem) {
        return Text(
          selectedItem ?? '',
          style: Theme.of(context).textTheme.bodyMedium,
        );
      },
    );
  }
}
