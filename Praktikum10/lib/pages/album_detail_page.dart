// lib/pages/album_detail_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/item_model.dart';

class AlbumDetailPage extends StatefulWidget {
  final AlbumModel album;
  final List<ArtistModel> allArtists;
  final Function onFavoriteChanged;

  const AlbumDetailPage({
    super.key,
    required this.album,
    required this.allArtists,
    required this.onFavoriteChanged,
  });

  @override
  State<AlbumDetailPage> createState() => _AlbumDetailPageState();
}

class _AlbumDetailPageState extends State<AlbumDetailPage> {
  List<Map<String, dynamic>> _getAlbumSongs() {
    List<Map<String, dynamic>> albumSongs = [];
    for (var artist in widget.allArtists) {
      for (var song in artist.songs) {
        if (song.albumId == widget.album.id) {
          albumSongs.add({
            'songObject': song,
            'title': song.title,
            'artist': artist.artistName,
            'isFavorite': song.isFavorite,
          });
        }
      }
    }
    return albumSongs;
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dash_artists', json.encode(widget.allArtists.map((a) => a.toMap()).toList()));
  }

  @override
  Widget build(BuildContext context) {
    final songs = _getAlbumSongs();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.album.albumName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.pink.shade300,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: songs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.album_outlined, size: 70, color: Colors.pink.shade100),
                  const SizedBox(height: 12),
                  Text('Belum ada lagu di album ini.', style: TextStyle(color: Colors.pink.shade400, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final songData = songs[index];
                final SongModel currentSong = songData['songObject'];

                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.pink.shade50, child: Icon(Icons.play_circle, color: Colors.pink.shade300)),
                    title: Text(songData['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Penyanyi: ${songData['artist']}'),
                    trailing: IconButton(
                      icon: Icon(currentSong.isFavorite ? Icons.favorite : Icons.favorite_border, color: currentSong.isFavorite ? Colors.red : Colors.grey),
                      onPressed: () async {
                        setState(() => currentSong.isFavorite = !currentSong.isFavorite);
                        await _saveData();
                        widget.onFavoriteChanged();
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}