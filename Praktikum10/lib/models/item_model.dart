// lib/models/item_model.dart

class ArtistModel {
  int id;
  String artistName;
  List<SongModel> songs;

  ArtistModel({
    required this.id,
    required this.artistName,
    required this.songs,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'artistName': artistName,
      'songs': songs.map((song) => song.toMap()).toList(),
    };
  }

  factory ArtistModel.fromMap(Map<String, dynamic> map) {
    return ArtistModel(
      id: map['id'] ?? 0,
      artistName: map['artistName'] ?? '',
      songs: List<SongModel>.from(
        (map['songs'] ?? []).map((songMap) => SongModel.fromMap(songMap)),
      ),
    );
  }
}

class AlbumModel {
  int id;
  String albumName;

  AlbumModel({
    required this.id,
    required this.albumName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'albumName': albumName,
    };
  }

  factory AlbumModel.fromMap(Map<String, dynamic> map) {
    return AlbumModel(
      id: map['id'] ?? 0,
      albumName: map['albumName'] ?? '',
    );
  }
}

class SongModel {
  int id;
  String title;
  int? albumId;
  bool isFavorite;

  SongModel({
    required this.id,
    required this.title,
    this.albumId,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'albumId': albumId,
      'isFavorite': isFavorite,
    };
  }

  factory SongModel.fromMap(Map<String, dynamic> map) {
    return SongModel(
      id: map['id'] ?? 0,
      title: map['title'] ?? '',
      albumId: map['albumId'],
      isFavorite: map['isFavorite'] ?? false,
    );
  }
}