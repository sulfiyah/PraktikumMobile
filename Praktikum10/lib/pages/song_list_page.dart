// lib/pages/song_list_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/item_model.dart';

class SongListPage extends StatefulWidget {
  final ArtistModel artist;
  final List<AlbumModel> globalAlbums;
  final Function(SongModel, String) onPlaySong; // Callback untuk putar lagu
  final int? currentPlayingSongId;

  const SongListPage({
    super.key, 
    required this.artist, 
    required this.globalAlbums,
    required this.onPlaySong,
    required this.currentPlayingSongId,
  });

  @override
  State<SongListPage> createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {
  final TextEditingController _titleController = TextEditingController();
  AlbumModel? _selectedAlbum;

  String _getAlbumName(int? albumId) {
    if (albumId == null) return 'Single / No Album';
    final album = widget.globalAlbums.firstWhere((a) => a.id == albumId, orElse: () => AlbumModel(id: -1, albumName: ''));
    return album.albumName.isNotEmpty ? album.albumName : 'Unknown Album';
  }

  Future<void> _updateAndSaveSongs() async {
    final prefs = await SharedPreferences.getInstance();
    String? artistString = prefs.getString('dash_artists');

    if (artistString != null) {
      List<dynamic> itemsMap = json.decode(artistString);
      List<ArtistModel> allArtists = itemsMap.map((item) => ArtistModel.fromMap(item)).toList();

      int index = allArtists.indexWhere((a) => a.id == widget.artist.id);
      if (index != -1) {
        allArtists[index] = widget.artist;
      }
      await prefs.setString('dash_artists', json.encode(allArtists.map((a) => a.toMap()).toList()));
    }
  }

  void _showAddSongDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Tambah Lagu Baru', style: TextStyle(color: Colors.pink.shade400, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Judul Lagu')),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<AlbumModel>(
                    decoration: const InputDecoration(labelText: 'Pilih Album'),
                    value: _selectedAlbum,
                    items: widget.globalAlbums.map((album) {
                      return DropdownMenuItem<AlbumModel>(value: album, child: Text(album.albumName));
                    }).toList(),
                    onChanged: (value) => setDialogState(() => _selectedAlbum = value),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Judul lagu tidak boleh kosong!')));
                      return;
                    }
                    setState(() {
                      widget.artist.songs.add(SongModel(
                        id: DateTime.now().millisecondsSinceEpoch,
                        title: _titleController.text.trim(),
                        albumId: _selectedAlbum?.id,
                      ));
                    });
                    _updateAndSaveSongs();
                    _titleController.clear();
                    _selectedAlbum = null;
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade300, foregroundColor: Colors.white),
                  child: const Text('Simpan'),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _showEditSongDialog(SongModel song) {
    final editTitleController = TextEditingController(text: song.title);
    AlbumModel? currentSelectedAlbum = widget.globalAlbums.firstWhere(
      (a) => a.id == song.albumId, 
      orElse: () => AlbumModel(id: -1, albumName: '')
    );
    if (currentSelectedAlbum.id == -1) currentSelectedAlbum = null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Edit Data Lagu', style: TextStyle(color: Colors.pink.shade400, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: editTitleController, decoration: const InputDecoration(labelText: 'Judul Lagu')),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<AlbumModel>(
                    decoration: const InputDecoration(labelText: 'Pilih Album'),
                    value: currentSelectedAlbum,
                    items: widget.globalAlbums.map((album) {
                      return DropdownMenuItem<AlbumModel>(value: album, child: Text(album.albumName));
                    }).toList(),
                    onChanged: (value) => setDialogState(() => currentSelectedAlbum = value),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  onPressed: () {
                    if (editTitleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Judul lagu tidak boleh kosong!')));
                      return;
                    }
                    setState(() {
                      song.title = editTitleController.text.trim();
                      song.albumId = currentSelectedAlbum?.id;
                    });
                    _updateAndSaveSongs();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade300, foregroundColor: Colors.white),
                  child: const Text('Perbarui'),
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.artist.artistName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.pink.shade300,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: widget.artist.songs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.music_off_outlined, size: 70, color: Colors.pink.shade100),
                  const SizedBox(height: 12),
                  Text('Belum ada lagu.', style: TextStyle(color: Colors.pink.shade400, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.artist.songs.length,
              itemBuilder: (context, index) {
                final song = widget.artist.songs[index];
                final isCurrentPlaying = widget.currentPlayingSongId == song.id;

                return Card(
                  color: isCurrentPlaying ? Colors.pink.shade50 : Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: isCurrentPlaying ? BorderSide(color: Colors.pink.shade300, width: 1.5) : BorderSide.none,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isCurrentPlaying ? Colors.pink.shade300 : Colors.pink.shade50,
                      child: Icon(
                        isCurrentPlaying ? Icons.audiotrack : Icons.music_note, 
                        color: isCurrentPlaying ? Colors.white : Colors.pink.shade300
                      ),
                    ),
                    title: Text(
                      song.title, 
                      style: TextStyle(fontWeight: FontWeight.bold, color: isCurrentPlaying ? Colors.pink.shade700 : Colors.black87)
                    ),
                    subtitle: Text('Album: ${_getAlbumName(song.albumId)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(song.isFavorite ? Icons.favorite : Icons.favorite_border, color: song.isFavorite ? Colors.red : Colors.grey),
                          onPressed: () {
                            setState(() => song.isFavorite = !song.isFavorite);
                            _updateAndSaveSongs();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                          onPressed: () => _showEditSongDialog(song),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () {
                            setState(() => widget.artist.songs.removeWhere((s) => s.id == song.id));
                            _updateAndSaveSongs();
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      widget.onPlaySong(song, widget.artist.artistName);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Memutar: ${song.title}'), duration: const Duration(seconds: 1)),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSongDialog,
        backgroundColor: Colors.pink.shade300,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}