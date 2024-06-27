// queries.dart

const String getCharacterQuery = """
  query GetCharacter(\$id: ID!) {
    character(id: \$id) {
      id
      name
      status
      species
      type
      gender
      image
      origin {
        name
      }
      location {
        name
      }
      episode{
        name
        episode
    }
    }
  }
""";
