import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:rick_and_morty/app/model/character.dart';
import 'package:rick_and_morty/app/utils/query.dart';
import 'package:rick_and_morty/app/widgets/character_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Character> _filterCharacters(List<Character> characters) {
    if (_searchQuery.isEmpty) {
      return characters;
    }
    return characters
        .where((character) =>
            character.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    double screenWidth = MediaQuery.of(context).size.width;

    // Calculate the logo width based on screen width
    double logoWidth = screenWidth * 0.3; // Adjust this value as needed

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(31, 125, 239, 68),
        title: Row(
          children: [
            SizedBox(
              width: logoWidth,
              height: 62,
              child: Image.asset(
                "assets/logo.png",
                fit: BoxFit.contain,
              ),
            ),
            Spacer(), // This will push the search bar to the right
            Container(
              width: screenWidth * 0.5, // Adjust width as needed
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Type characters',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(
                      color: Colors.grey, // Change the border color
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(
                      color: Colors.grey, // Change the border color
                      width: 2.0,
                    ),
                  ),
                  filled: true,
                  fillColor: Color.fromARGB(255, 219, 246, 208),
                  prefixIcon: Icon(Icons.search, color: Colors.grey,),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
                ),
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Query(
            builder: (result, {fetchMore, refetch}) {
              // We have data
              if (result.data != null) {
                int? nextPage = 1;
                List<Character> characters =
                    (result.data!["characters"]["results"] as List)
                        .map((e) => Character.fromMap(e))
                        .toList();

                nextPage = result.data!["characters"]["info"]["next"];

                characters = _filterCharacters(characters);

                return RefreshIndicator(
                  onRefresh: () async {
                    await refetch!();
                    nextPage = 1;
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Center(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: characters
                                .map((e) => CharacterWidget(character: e))
                                .toList(),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        if (nextPage != null)
                          ElevatedButton(
                              onPressed: () async {
                                FetchMoreOptions opts = FetchMoreOptions(
                                  variables: {'page': nextPage},
                                  updateQuery: (previousResultData,
                                      fetchMoreResultData) {
                                    final List<dynamic> repos = [
                                      ...previousResultData!["characters"]
                                          ["results"] as List<dynamic>,
                                      ...fetchMoreResultData!["characters"]
                                          ["results"] as List<dynamic>
                                    ];
                                    fetchMoreResultData["characters"]
                                        ["results"] = repos;
                                    return fetchMoreResultData;
                                  },
                                );
                                await fetchMore!(opts);
                              },
                              child: result.isLoading
                                  ? CircularProgressIndicator()
                                  : const Text("Load More"))
                      ],
                    ),
                  ),
                );
              }
              // We got data but it is null
              else if (result.data == null) {
                return const Text("Data Not Found!");
              }
              // We don't have data yet -> LOADING STATE
              else if (result.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              // error state
              else {
                return const Center(
                  child: Center(child: Text("Something went wrong")),
                );
              }
            },
            options: QueryOptions(
                fetchPolicy: FetchPolicy.cacheAndNetwork,
                document: getAllCharachters(),
                variables: const {"page": 1}),
          ),
        ),
      ),
    );
  }
}
