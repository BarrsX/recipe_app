import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../bloc/home_bloc.dart';

class SearchField extends StatelessWidget {
  final TextEditingController searchController;
  final HomeBloc homeBloc;

  const SearchField({Key? key, required this.searchController, required this.homeBloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TypeAheadField(
      textFieldConfiguration: TextFieldConfiguration(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search meals',
          hintStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        onSubmitted: homeBloc.loadOrSearchMeals,
      ),
      suggestionsCallback: homeBloc.getSuggestionList,
      itemBuilder: (context, String suggestion) {
        return ListTile(
          title: Text(suggestion),
        );
      },
      onSuggestionSelected: (String suggestion) {
        searchController.text = suggestion;
        homeBloc.loadOrSearchMeals(suggestion);
      },
    );
  }
}
