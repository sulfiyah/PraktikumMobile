import 'dart:convert';
import 'package:http/http.dart' as http;
import 'movie_model.dart';

class MovieService {
  static const String _apiKey = '8b0761abc15115804ea79e883ffb2c4e';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  // Ambil daftar film populer (untuk halaman list)
  Future<List<Movie>> fetchPopularMovies({int page = 1}) async {
    final uri = Uri.parse(
      '$_baseUrl/movie/popular?api_key=$_apiKey&language=id-ID&page=$page',
    );

    final response = await http.get(uri).timeout(
      const Duration(seconds: 10),
      onTimeout: () =>
          throw Exception('Request timeout. Periksa koneksi internet kamu.'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception(
          'API Key TMDB tidak valid. Periksa kembali _apiKey di movie_service.dart');
    } else {
      throw Exception('Gagal memuat film. Status: ${response.statusCode}');
    }
  }

  // Ambil detail satu film (untuk halaman detail)
  Future<Movie> fetchMovieDetail(int movieId) async {
    final uri = Uri.parse(
      '$_baseUrl/movie/$movieId?api_key=$_apiKey&language=id-ID',
    );

    final response = await http.get(uri).timeout(
      const Duration(seconds: 10),
      onTimeout: () =>
          throw Exception('Request timeout. Periksa koneksi internet kamu.'),
    );

    if (response.statusCode == 200) {
      return Movie.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('API Key TMDB tidak valid.');
    } else {
      throw Exception('Gagal memuat detail film. Status: ${response.statusCode}');
    }
  }
}
