import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {
  final String apiKey =
      '8324046971b04e0e9e1a998ae608ab3f'; // Replace with your API key
  final String baseUrl = 'https://newsapi.org/v2/everything/';

Future<List<dynamic>> fetchNews(String query, {int limit = 10, int page = 1}) async {
    final response = await http.get(
      Uri.parse('$baseUrl?q=$query&apiKey=$apiKey&pageSize=$limit&page=$page'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final articles = data['articles'] as List<dynamic>;
      return articles.take(limit).toList(); // Limit the number of articles
    } else {
      throw Exception('Failed to load news');
    }
  }
}
