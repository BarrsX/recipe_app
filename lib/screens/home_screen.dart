// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'recipe_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final String spoonacularApiKey = dotenv.env['SPOONACULAR_API_KEY']!;
  List<dynamic> _meals = [];
  bool _isLoading = false;
  bool _isError = false;
  bool _haveSearched = false;

  void _searchMeals(String query) async {
    setState(() {
      _isLoading = true;
      _isError = false; // add this line to reset when retrying
      _haveSearched = true;
    });

    final url = Uri.parse(
        'https://api.spoonacular.com/recipes/complexSearch?query=$query&addRecipeInformation=true&apiKey=$spoonacularApiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _meals = data['results'];
          _isLoading = false;
        });
      } else {
        print('Error: ${response.statusCode} ${response.body}');
        setState(() {
          _isLoading = false;
          _isError = true;
        });

        Fluttertoast.showToast(
            msg: 'Error: ${response.statusCode} ${response.reasonPhrase}',
            backgroundColor: Colors.red,
            toastLength: Toast.LENGTH_LONG);
      }
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
        _isError = true;
      });

      Fluttertoast.showToast(
          msg: 'An error occurred',
          backgroundColor: Colors.red,
          toastLength: Toast.LENGTH_LONG);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search meals',
            hintStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[500],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          onSubmitted: _searchMeals,
        ),
      ),
      body: Stack(
        children: <Widget>[
          Visibility(
            visible: !_isLoading && !_isError,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: _meals.isEmpty && _haveSearched
                  ? const Center(child: Text('No Results Found'))
                  : ListView.builder(
                      itemCount: _meals.length,
                      itemBuilder: (context, index) {
                        final meal = _meals[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            leading: Container(
                              width: 80,
                              height: 80,
                              margin: const EdgeInsets.only(right: 16),
                              child: Image.network(
                                meal['image'],
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              meal['title'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                                'Ready in ${meal['readyInMinutes']} minutes'),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => RecipeScreen(meal['id']),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
          Visibility(
            visible: _isLoading && !_isError,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          Visibility(
            visible: _isError,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'An error occurred',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _searchMeals(_searchController.text); // retry
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
