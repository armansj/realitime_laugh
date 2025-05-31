import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class GifService {
  static final GifService _instance = GifService._internal();
  factory GifService() => _instance;
  GifService._internal();

  final Random _random = Random();

  // List of funny search terms for variety
  final List<String> _funnySearchTerms = [
    'funny',
    'hilarious',
    'comedy',
    'laugh',
    'silly',
    'humor',
    'amusing',
    'witty',
    'entertaining',
    'comical',
  ];

  // Tenor API - Alternative (owned by Google)
  // Get free API key at: https://developers.google.com/tenor/guides/quickstart
  static const String _tenorApiKey = 'AIzaSyCDwkdRNS0jwBcR0AfvnfA0VmAIewRAqfU'; // Your API key
  static const String _tenorBaseUrl = 'https://tenor.googleapis.com/v2';

  /// Get a random funny search query for variety
  String _getRandomFunnyQuery() {
    final randomTerm = _funnySearchTerms[_random.nextInt(_funnySearchTerms.length)];
    
    // Add some additional random terms for more variety
    final additionalTerms = ['memes', 'fail', 'cats', 'dogs', 'reaction', 'viral'];
    final randomAdditional = additionalTerms[_random.nextInt(additionalTerms.length)];
    
    return '$randomTerm $randomAdditional';
  }

  /// Fetch funny GIFs from Tenor API (Google)
  /// [query] - search terms (if null, uses random funny terms)
  /// [limit] - number of GIFs to fetch
  Future<List<GifData>> fetchFunnyGifsFromTenor({
    String? query,
    int limit = 20,
  }) async {
    try {
      // For demo purposes, return some fallback data if API key is not set
      if (_tenorApiKey == 'YOUR_TENOR_API_KEY_HERE') {
        return _getFallbackGifs();
      }

      // Use random funny query if no specific query provided
      final searchQuery = query ?? _getRandomFunnyQuery();

      final url = Uri.parse(
        '$_tenorBaseUrl/search?key=$_tenorApiKey&q=$searchQuery&limit=$limit&contentfilter=medium'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> gifs = data['results'] ?? [];
        
        // Shuffle the results for more randomness
        final gifList = gifs.map((gif) => GifData.fromTenorJson(gif)).toList();
        gifList.shuffle(_random);
        
        return gifList;
      } else {
        print('Tenor API error: ${response.statusCode}');
        return _getFallbackGifs();
      }
    } catch (e) {
      print('Error fetching GIFs from Tenor: $e');
      return _getFallbackGifs();
    }
  }

  /// Main method to get funny GIFs - uses Tenor API by default
  Future<List<GifData>> getFunnyGifs({int limit = 20}) async {
    return await fetchFunnyGifsFromTenor(limit: limit);
  }
  /// Fallback GIFs for when API is not available or fails
  List<GifData> _getFallbackGifs() {
    return [
      GifData(
        id: 'fallback_1',
        title: 'Dancing Cat',
        url: 'https://media.giphy.com/media/JIX9t2j0ZTN9S/giphy.gif',
        previewUrl: 'https://media.giphy.com/media/JIX9t2j0ZTN9S/200w.gif',
        description: 'A cat doing an epic dance move!',
      ),
      GifData(
        id: 'fallback_2',
        title: 'Epic Fail',
        url: 'https://media.giphy.com/media/l2Je66zG6mAAZxgqI/giphy.gif',
        previewUrl: 'https://media.giphy.com/media/l2Je66zG6mAAZxgqI/200w.gif',
        description: 'Someone having a hilarious fail moment!',
      ),
      GifData(
        id: 'fallback_3',
        title: 'Funny Dog',
        url: 'https://media.giphy.com/media/mCRJDo24UvJMA/giphy.gif',
        previewUrl: 'https://media.giphy.com/media/mCRJDo24UvJMA/200w.gif',
        description: 'A dog doing something absolutely ridiculous!',
      ),
      GifData(
        id: 'fallback_4',
        title: 'Comedy Gold',
        url: 'https://media.giphy.com/media/26ufdipQqU2lhNA4g/giphy.gif',
        previewUrl: 'https://media.giphy.com/media/26ufdipQqU2lhNA4g/200w.gif',
        description: 'Pure comedy gold that will make you laugh!',
      ),
      GifData(
        id: 'fallback_5',
        title: 'Surprise Reaction',
        url: 'https://media.giphy.com/media/5VKbvrjxpVJCM/giphy.gif',
        previewUrl: 'https://media.giphy.com/media/5VKbvrjxpVJCM/200w.gif',
        description: 'The most surprised reaction ever!',
      ),
    ];
  }
}

/// Model class for GIF data
class GifData {
  final String id;
  final String title;
  final String url;
  final String previewUrl;
  final String description;

  GifData({
    required this.id,
    required this.title,
    required this.url,
    required this.previewUrl,
    required this.description,
  });
  /// Create GifData from Tenor API response
  factory GifData.fromTenorJson(Map<String, dynamic> json) {
    final mediumGif = json['media_formats']['gif'] ?? {};
    final smallGif = json['media_formats']['tinygif'] ?? mediumGif;
    
    return GifData(
      id: json['id'] ?? '',
      title: json['content_description'] ?? 'Funny GIF',
      url: mediumGif['url'] ?? '',
      previewUrl: smallGif['url'] ?? mediumGif['url'] ?? '',
      description: json['content_description'] ?? 'A hilarious GIF!',
    );
  }
}
