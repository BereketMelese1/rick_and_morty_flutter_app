import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:rick_and_morty/config/queriesDetail.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


class DetailScreen extends StatelessWidget {
  const DetailScreen({Key? key, required this.id}) : super(key: key);

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const  Color.fromARGB(31, 33, 31, 31),
        title: const  Text(
          'Personal Info',
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Query(
          options: QueryOptions(
            document: gql(getCharacterQuery),
            variables: {'id': id},
            fetchPolicy: FetchPolicy.cacheFirst,
          ),
          builder: (QueryResult result,
              {VoidCallback? refetch, FetchMore? fetchMore}) {
            if (result.hasException) {
              return Center(
                  child: Text('Error: ${result.exception.toString()}'));
            }

            if (result.isLoading) {
              return const Center(
                child: 
                SpinKitDoubleBounce(
                      color: Colors.blue,
                      size: 50.0,
        ),);
            }

            final character = result.data?['character'];

            if (character == null) {
              return Center(child: Text('No data found'));
            }

            return ListView(
              padding: EdgeInsets.all(32.0),
              children: [
                _CharacterHeader(character),
                const   SizedBox(height: 32.0),
                _CharacterInfo(character),
               const  Divider(color: Colors.green),
                _CharacterLocation(character),
              const   Divider(color: Colors.green),
                _CharacterEpisode(character),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _CharacterHeader(Map<String, dynamic> character) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: CachedNetworkImageProvider(character['image']),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 10,
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
         const  SizedBox(height: 32.0),
          Text(
            character['name'],
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _CharacterInfo(Map<String, dynamic> character) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 8.0),
        _buildInfoRow(Icons.person, Colors.green, character['status'],
            character['status'] == 'Alive' ? Colors.green : Colors.red),
        const SizedBox(height: 8.0),
        _buildInfoRow(
            Icons.person_2_outlined, Colors.orange, character['species']),
        const SizedBox(height: 8.0),
        if (character['type'].isNotEmpty)
          _buildInfoRow(Icons.category, Colors.purple, character['type']),
        const SizedBox(height: 8.0),
        _buildInfoRow(Icons.transgender, Colors.pink, character['gender']),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _CharacterLocation(Map<String, dynamic> character) {
    return Column(
      children: [
        const Text(
          'Locations:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ListTile(
          leading: Icon(Icons.location_on, color: Colors.red),
          title: Text(
            'Origin',
          ),
          subtitle: Text(
            character['origin']['name'],
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        ListTile(
          leading: Icon(Icons.location_city, color: Colors.blue),
          title: Text(
            'Location',
          ),
          subtitle: Text(
            character['location']['name'],
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _CharacterEpisode(Map<String, dynamic> character) {
    final List<dynamic> episodes = character['episode'];

    return Column(
      children: [
        Text(
          'Episodes:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ListView.builder(
          shrinkWrap:
              true, // Ensures the ListView takes only the space it needs
          physics:
              NeverScrollableScrollPhysics(), // Prevents the ListView from scrolling independently
          itemCount: episodes.length,
          itemBuilder: (context, index) {
            final episode = episodes[index];
            return ListTile(
              leading: Icon(Icons.movie, color: Colors.blue),
              title: Text(
                episode['name'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Episode: ${episode['episode']}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, Color iconColor, String text,
      [Color? textColor]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor),
        SizedBox(width: 8.0),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: textColor ?? Colors.black,
          ),
        ),
      ],
    );
  }
}
