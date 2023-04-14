import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../auth/data/repository/auth_repository.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_event.dart';
import '../../recipe/domain/models/recipe.dart';
import 'bloc/home_bloc.dart';
import 'widgets/meal_list_view.dart';
import 'widgets/search_field.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  late HomeBloc _homeBloc = HomeBloc();
  late AuthenticationRepository _authRepository;
  late AuthenticationBloc _authBloc =
      AuthenticationBloc(repository: _authRepository);

  @override
  void initState() {
    _authRepository = AuthenticationRepository();
    _homeBloc.loadOrSearchMeals();
    super.initState();
  }

  @override
  void dispose() {
    _homeBloc.dispose();
    super.dispose();
  }

  void onPressHome() {
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
            onPressed: onPressHome,
          ),
          title: SearchField(
            searchController: _searchController,
            homeBloc: _homeBloc,
            onHomePressed: onPressHome,
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
              stream: _homeBloc.isLoading,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return Container();
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
              const ListTile(
                title: Text('Menu',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold)),
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
                  if (_authBloc.isClosed) {
                    _authBloc.add(AuthenticationLoggedOut());
                  }
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
