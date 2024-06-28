# Rick and Morty GraphQL Flutter App

## Introduction

This is a Flutter application that uses the [Rick and Morty GraphQL API](https://github.com/afuh/rick-and-morty-api) to display characters from the popular animated TV series.

It can also support my rick_and_morty movie website i had already developed("https://rick-and-morty-movie-website.netlify.app")

## Features

- Fetch and display a list of characters from the Rick and Morty universe
- View detailed information about each character, including their name, status, species, gender, and image
- Pagination support to load more characters as the user scrolls
- Search capability for users by character names
-filter character for ease of access


## Prerequisites

- Flutter SDK version 3.0.0 or higher
- Dart version 2.19.0 or higher

## Getting Started

1. **Clone the repository**:

   ```
   git clone https://github.com/itismrx/rick_and_morty.git
   ```

2. **Change to the project directory**:

   ```
   cd rick_and_morty
   ```

3. **Install the dependencies**:

   ```
   flutter pub get
   ```

4. **Run the app**:

   ```
   flutter run
   ```

## Dependencies

This project uses the following packages:

- `graphql_flutter: ^5.1.2`
- `flutter_riverpod: ^2.5.1`
- `cached_network_image: ^3.2.3`

## Usage

The app displays a list of characters from the Rick and Morty show. Users can tap on a character to view more details about them, including their name, status, species, gender, and image.

The app uses the `graphql_flutter` package to communicate with the GraphQL API and the `flutter_riverpod` package for state management. Offline support is provided by caching the character data using the `cached_network_image` package.



## License

This project is licensed under the [MIT License](LICENSE).