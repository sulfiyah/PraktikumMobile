class Movie {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final double voteAverage;
  final String releaseDate;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    required this.voteAverage,
    required this.releaseDate,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'] ?? 'No Title',
      overview: (json['overview'] != null && json['overview'] != '')
          ? json['overview']
          : 'Tidak ada deskripsi.',
      posterPath: json['poster_path'],
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      releaseDate: (json['release_date'] != null && json['release_date'] != '')
          ? json['release_date']
          : '-',
    );
  }

  // URL gambar poster, w500 = ukuran gambar (bisa diganti w200/original)
  String get posterUrl => posterPath != null
      ? 'https://image.tmdb.org/t/p/w500$posterPath'
      : 'https://via.placeholder.com/500x750.png?text=No+Image';
}
