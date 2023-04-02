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
3. Run the app on an emulator or physical device
