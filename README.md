# Recipe App

This Flutter app allows users to search for a meal and see the ingredients and instructions to make it.

## Features
- Search meals by typing in a query
- Display list of meals with images and cook time
- Tap on a meal to view a detailed recipe, including the ingredients and instructions

## Code Structure

### home_screen.dart
The `HomeScreen` class is the main screen of the app. It contains a search bar where the user can type in a query and search for meals. When the user submits a query, the app calls the `_searchMeals` function to fetch the results from the Spoonacular API. The results are displayed in a `ListView` of `ListTile` widgets, each of which displays the meal's image, title, and cook time.

### recipe_screen.dart
The `RecipeScreen` class displays the detailed recipe for a selected meal. It fetches the recipe from the Spoonacular API using the meal ID, and displays the ingredients and instructions in a scrollable `ListView`.

## Dependencies
The app uses the `http` package to make API requests and the `fluttertoast` package to display error messages. It also imports a `keys.dart` file that contains the API key for Spoonacular.

## How to Run
1. Clone the repository
2. Open the project in Android Studio or VS Code
3. Insert spoonacular api key into .env file
4. Run the app on an emulator or physical device

# Contributing to Our Project using Gitflow Method

Thank you for your interest in contributing to our project! To ensure that contributions are made in an organized and systematic way, we use the Gitflow workflow method. This document outlines the steps to follow to contribute.

## Branches

### master
The `master` branch contains the latest stable release of our project. We do not make direct changes to the `master` branch.

### develop
The `develop` branch is the main branch where we merge in all feature branches. All development work should be done on this branch.

### feature branches
For each feature that you're working on, you should create a new branch off of `develop`. For example, if you're working on a new search feature, you could create a branch called `feature/search`:

`git checkout -b feature/search develop`

You can make all your changes related to the search feature in this branch. Once you're finished, you can merge it back into `develop`:

`git checkout develop git merge --no-ff feature/search`

### release branches
When we're ready to do a release, we create a new branch off of `develop` called `release/x.x.x`:

`git checkout -b release/1.0.0 develop`

We can then do any final testing and bug fixes on this branch before we release it. Once we're ready to release, we merge it into both `develop` and `master`:

`git checkout master git merge --no-ff release/1.0.0 git checkout develop git merge --no-ff release/1.0.0`

### hotfix branches
If a critical bug is found in production, we create a new branch off of `master` called `hotfix/x.x.x`:

`git checkout -b hotfix/1.0.1 master`

We can then make the necessary fixes and merge it back into both `develop` and `master`:

`git checkout master git merge --no-ff hotfix/1.0.1 git checkout develop git merge --no-ff hotfix/1.0.1`

## Contributing

To contribute to our project, please follow these steps:

1. Fork the repository
2. Clone your fork to your local machine
3. Create a new feature branch off of `develop`
4. Make your changes
5. Push your feature branch to your fork
6. Submit a pull request from your feature branch to our `develop` branch

We will review your pull request and, if everything looks good, merge it into `develop`.

Thank you for your contributions! If you have any questions or concerns, please don't hesitate to reach out to us.
