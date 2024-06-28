import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:rick_and_morty/app/model/character.dart';
import 'package:rick_and_morty/app/utils/query.dart';
import 'package:rick_and_morty/app/widgets/character_widget.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedGender = "All";
  String _selectedStatus = "All";
  String _selectedSpecies = "All";

  final List<String> _genders = ["All", "Male", "Female", "Genderless", "unknown"];
  final List<String> _statuses = ["All", "Alive", "Dead", "unknown"];
  final List<String> _species = ["All", "Human", "Alien", "Humanoid", "unknown"]; // Add more species as needed

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
    List<Character> filteredCharacters = characters;

    if (_searchQuery.isNotEmpty) {
      filteredCharacters = filteredCharacters.where((character) =>
          character.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    if (_selectedGender != "All") {
      filteredCharacters = filteredCharacters.where((character) =>
          character.gender == _selectedGender).toList();
    }

    if (_selectedStatus != "All") {
      filteredCharacters = filteredCharacters.where((character) =>
          character.status == _selectedStatus).toList();
    }

    if (_selectedSpecies != "All") {
      filteredCharacters = filteredCharacters.where((character) =>
          character.species == _selectedSpecies).toList();
    }

    return filteredCharacters;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double logoWidth = screenWidth * 0.3;

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
            Spacer(),
            Container(
              width: screenWidth * 0.5,
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
                      color: Colors.grey,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(
                      color: Colors.grey,
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
                                  ? SpinKitDoubleBounce(
                                      color: Colors.blue,
                                      size: 50.0,
                                        )
                                  : const Text("Load More"))
                      ],
                    ),
                  ),
                );
              } else if (result.data == null) {
                return const Text("Data Not Found!");
              } else if (result.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return const Center(
                  child: Center(child: Text("Something went wrong")),
                );
              }
            },
            options: QueryOptions(
              fetchPolicy: FetchPolicy.cacheAndNetwork,
              document: getAllCharachters(),
              variables: {
                "page": 1,
                "gender": _selectedGender != "All" ? _selectedGender : null,
                "status": _selectedStatus != "All" ? _selectedStatus : null,
                "species": _selectedSpecies != "All" ? _selectedSpecies : null,
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color.fromARGB(31, 125, 239, 68),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            alignment: WrapAlignment.spaceAround,
            spacing: 16,
            runSpacing: 8,
            children: [
              Column(
                children: [
                  Text("Gender"),
                  DropdownButton<String>(
                    value: _selectedGender,
                    items: _genders.map((String gender) {
                      return DropdownMenuItem<String>(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGender = newValue!;
                      });
                    },
                  ),
                ],
              ),
              Column(
                children: [
                  Text("Status"),
                  DropdownButton<String>(
                    value: _selectedStatus,
                    items: _statuses.map((String status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedStatus = newValue!;
                      });
                    },
                  ),
                ],
              ),
              Column(
                children: [
                  Text("Species"),
                  DropdownButton<String>(
                    value: _selectedSpecies,
                    items: _species.map((String species) {
                      return DropdownMenuItem<String>(
                        value: species,
                        child: Text(species),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSpecies = newValue!;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
