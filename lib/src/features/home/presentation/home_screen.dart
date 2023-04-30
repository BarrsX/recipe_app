import '../../user/presentation/bloc/user_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../auth/presentation/bloc/auth_event.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';

import '../../recipe/domain/models/recipe.dart';

import 'widgets/meal_list_view.dart';
import 'widgets/search_field.dart';

import 'bloc/home_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AuthenticationBloc _authBloc = AuthenticationBloc();
  late final UserBloc _userBloc = UserBloc();
  final TextEditingController _searchController = TextEditingController();
  late final HomeBloc _homeBloc = HomeBloc();
  late User? loggedInUser = _userBloc.getUser();

  @override
  void initState() {
    _homeBloc.loadOrSearchMeals();
    super.initState();
  }

  @override
  void dispose() {
    _homeBloc.dispose();
    super.dispose();
  }

  void _onPressHome() {
    _homeBloc.resetSearch();
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.home),
            onPressed: _onPressHome,
          ),
          backgroundColor: Theme.of(context).primaryColor,
          title: SearchField(
            searchController: _searchController,
            homeBloc: _homeBloc,
            onHomePressed: _onPressHome,
          ),
          actions: [
            Builder(builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            }),
          ],
        ),
        body: Stack(
          children: [
            StreamBuilder<List<Recipe>>(
              stream: _homeBloc.meals,
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.isNotEmpty) {
                  return MealListView(
                      meals: snapshot.data!, homeBloc: _homeBloc);
                } else if (_homeBloc.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return const Center(child: Text('No Results Found'));
                }
              },
            ),
            StreamBuilder(
              stream: _homeBloc.isError,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'An error occurred',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _homeBloc.loadOrSearchMeals(_searchController.text);
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
        endDrawer: Drawer(
          child: ListView(
            children: [
              ListTile(
                title: Text('Hi, ${loggedInUser?.displayName ?? "User"}!',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              ListTile(
                leading: const Icon(Icons.shuffle_rounded),
                title: const Text('Randomize'),
                onTap: () {
                  _homeBloc.resetSearch();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign out'),
                onTap: () async {
                  _authBloc.add(AuthenticationLoggedOut());
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (_) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
