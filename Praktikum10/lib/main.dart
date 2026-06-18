// lib/main.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/item_model.dart';
import 'pages/song_list_page.dart';
import 'pages/album_detail_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyPlaylist Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink.shade300,
          primary: Colors.pink.shade300,
          secondary: Colors.pink.shade200,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF5F5),
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  List<ArtistModel> _artists = [];
  List<AlbumModel> _albums = [];
  late TabController _tabController;
  int _currentTabIndex = 0;

  // Variabel Fitur Pencarian & Pengurutan
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _isAscending = true;

  // State Simulasi Mini Player
  SongModel? _playingSong;
  String _playingArtistName = "";
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Sinkronisasi Tab + Fitur Otomatis Bersihkan Kolom Search saat Pindah Tab
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
          _searchController.clear(); 
          _searchQuery = "";
        });
      }
    });

    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });

    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    String? artistString = prefs.getString('dash_artists');
    String? albumString = prefs.getString('dash_albums');

    if (artistString != null && albumString != null) {
      setState(() {
        _artists = List<ArtistModel>.from(json.decode(artistString).map((item) => ArtistModel.fromMap(item)));
        _albums = List<AlbumModel>.from(json.decode(albumString).map((item) => AlbumModel.fromMap(item)));
      });
    } else {
      _artists = [];
      _albums = [];
      await _saveData();
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dash_artists', json.encode(_artists.map((a) => a.toMap()).toList()));
    await prefs.setString('dash_albums', json.encode(_albums.map((a) => a.toMap()).toList()));
  }

  int _getSongCountForAlbum(int albumId) {
    int count = 0;
    for (var artist in _artists) {
      count += artist.songs.where((song) => song.albumId == albumId).length;
    }
    return count;
  }

  List<Map<String, dynamic>> _getFilteredFavorites() {
    List<Map<String, dynamic>> favSongs = [];
    for (var artist in _artists) {
      for (var song in artist.songs) {
        if (song.isFavorite && (song.title.toLowerCase().contains(_searchQuery) || artist.artistName.toLowerCase().contains(_searchQuery))) {
          favSongs.add({'id': song.id, 'title': song.title, 'artist': artist.artistName, 'songObj': song});
        }
      }
    }
    favSongs.sort((a, b) => _isAscending ? a['title'].compareTo(b['title']) : b['title'].compareTo(a['title']));
    return favSongs;
  }

  void _confirmDelete({required String title, required String content, required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () { onConfirm(); Navigator.pop(context); }, child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  void _showAddArtistDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Tambah Artis Baru', style: TextStyle(color: Colors.pink.shade400, fontWeight: FontWeight.bold)),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Nama Artis')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              setState(() => _artists.add(ArtistModel(id: DateTime.now().millisecondsSinceEpoch, artistName: controller.text.trim(), songs: [])));
              _saveData();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade300, foregroundColor: Colors.white),
            child: const Text('Simpan'),
          )
        ],
      ),
    );
  }

  void _showEditArtistDialog(ArtistModel artist) {
    final controller = TextEditingController(text: artist.artistName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit Nama Artis', style: TextStyle(color: Colors.pink.shade400, fontWeight: FontWeight.bold)),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Nama Artis')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              setState(() => artist.artistName = controller.text.trim());
              _saveData();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade300, foregroundColor: Colors.white),
            child: const Text('Perbarui'),
          )
        ],
      ),
    );
  }

  void _showAddAlbumDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Tambah Album Baru', style: TextStyle(color: Colors.pink.shade400, fontWeight: FontWeight.bold)),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Nama Album')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              setState(() => _albums.add(AlbumModel(id: DateTime.now().millisecondsSinceEpoch, albumName: controller.text.trim())));
              _saveData();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade300, foregroundColor: Colors.white),
            child: const Text('Simpan'),
          )
        ],
      ),
    );
  }

  void _showEditAlbumDialog(AlbumModel album) {
    final controller = TextEditingController(text: album.albumName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit Nama Album', style: TextStyle(color: Colors.pink.shade400, fontWeight: FontWeight.bold)),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Nama Album')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              setState(() => album.albumName = controller.text.trim());
              _saveData();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade300, foregroundColor: Colors.white),
            child: const Text('Perbarui'),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String title, required String subtitle}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.pink.shade100),
            const SizedBox(height: 16),
            Text(title, style: TextStyle(fontSize: 18, color: Colors.pink.shade400, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<ArtistModel> filteredArtists = _artists.where((a) => a.artistName.toLowerCase().contains(_searchQuery)).toList();
    filteredArtists.sort((a, b) => _isAscending ? a.artistName.compareTo(b.artistName) : b.artistName.compareTo(a.artistName));

    List<AlbumModel> filteredAlbums = _albums.where((a) => a.albumName.toLowerCase().contains(_searchQuery)).toList();
    filteredAlbums.sort((a, b) => _isAscending ? a.albumName.compareTo(b.albumName) : b.albumName.compareTo(a.albumName));

    final favoriteSongs = _getFilteredFavorites();

    return Scaffold(
      appBar: AppBar(
        title: const Text('MyPlaylist', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.pink.shade300,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(_isAscending ? Icons.sort_by_alpha : Icons.sort, color: Colors.white),
            onPressed: () => setState(() => _isAscending = !_isAscending),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari disini...',
                    prefixIcon: const Icon(Icons.search, color: Colors.pink),
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(icon: Icon(Icons.library_music), text: 'My Playlist'),
                  Tab(icon: Icon(Icons.album), text: 'My Album'),
                  Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: DAFTAR ARTIS
                filteredArtists.isEmpty
                    ? _buildEmptyState(icon: Icons.person_search_outlined, title: 'Artis Tidak Ada', subtitle: 'Mungkin belum ditambahkan, atau keyword pencarianmu salah.')
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredArtists.length,
                        itemBuilder: (context, index) {
                          final artist = filteredArtists[index];
                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            child: ListTile(
                              leading: CircleAvatar(backgroundColor: Colors.pink.shade50, child: Icon(Icons.person, color: Colors.pink.shade300)),
                              title: Text(artist.artistName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${artist.songs.length} Lagu'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent), onPressed: () => _showEditArtistDialog(artist)),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                    onPressed: () => _confirmDelete(
                                      title: 'Hapus Artis',
                                      content: 'Hapus ${artist.artistName}? Semua lagunya akan ikut terhapus.',
                                      onConfirm: () {
                                        setState(() {
                                          // Jika ada lagu dari artis ini yang lagi diputar, matikan player
                                          if (_playingSong != null && artist.songs.any((s) => s.id == _playingSong!.id)) {
                                            _playingSong = null;
                                            _isPlaying = false;
                                          }
                                          _artists.removeWhere((a) => a.id == artist.id);
                                        });
                                        _saveData();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SongListPage(
                                      artist: artist,
                                      globalAlbums: _albums,
                                      currentPlayingSongId: _playingSong?.id,
                                      onPlaySong: (song, name) {
                                        setState(() {
                                          _playingSong = song;
                                          _playingArtistName = name;
                                          _isPlaying = true;
                                        });
                                      },
                                    ),
                                  ),
                                );
                                _loadData();
                              },
                            ),
                          );
                        },
                      ),

                // TAB 2: DAFTAR ALBUM
                filteredAlbums.isEmpty
                    ? _buildEmptyState(icon: Icons.album_outlined, title: 'Album Tidak Ditemukan', subtitle: 'Buat album baru dengan menekan tombol "Album Baru" di kanan bawah layar.')
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredAlbums.length,
                        itemBuilder: (context, index) {
                          final album = filteredAlbums[index];
                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            child: ListTile(
                              leading: CircleAvatar(backgroundColor: Colors.pink.shade50, child: Icon(Icons.album, color: Colors.pink.shade300)),
                              title: Text(album.albumName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${_getSongCountForAlbum(album.id)} Lagu terdaftar'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent), onPressed: () => _showEditAlbumDialog(album)),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                    onPressed: () => _confirmDelete(
                                      title: 'Hapus Album',
                                      content: 'Hapus album ${album.albumName}? Lagu di dalamnya akan berubah status menjadi Single.',
                                      onConfirm: () {
                                        setState(() {
                                          _albums.removeWhere((a) => a.id == album.id);
                                          for (var art in _artists) {
                                            for (var s in art.songs) {
                                              if (s.albumId == album.id) s.albumId = null;
                                            }
                                          }
                                        });
                                        _saveData();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () async {
                                await Navigator.push(
                                  context, 
                                  MaterialPageRoute(
                                    builder: (context) => AlbumDetailPage(
                                      album: album, 
                                      allArtists: _artists, 
                                      onFavoriteChanged: () => _loadData()
                                    )
                                  )
                                );
                                _loadData();
                              },
                            ),
                          );
                        },
                      ),

                // TAB 3: DAFTAR FAVORIT (SINKRONISASI DATABASE UTAMA)
                favoriteSongs.isEmpty
                    ? _buildEmptyState(icon: Icons.favorite_border, title: 'Belum Ada Favorit', subtitle: 'Buka daftar lagu milik artis, lalu ketuk ikon hati untuk memunculkannya di sini.')
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: favoriteSongs.length,
                        itemBuilder: (context, index) {
                          final data = favoriteSongs[index];
                          final SongModel currentSong = data['songObj'];
                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            child: ListTile(
                              leading: CircleAvatar(backgroundColor: Colors.pink.shade50, child: Icon(Icons.music_note, color: Colors.pink.shade300)),
                              title: Text(data['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Penyanyi: ${data['artist']}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.favorite, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    currentSong.isFavorite = false;
                                    for (var art in _artists) {
                                      for (var s in art.songs) {
                                        if (s.id == currentSong.id) {
                                          s.isFavorite = false;
                                        }
                                      }
                                    }
                                  });
                                  _saveData();
                                },
                              ),
                              onTap: () {
                                setState(() {
                                  _playingSong = currentSong;
                                  _playingArtistName = data['artist'];
                                  _isPlaying = true;
                                });
                              },
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
          
          // ==================== PANEL MINI PLAYER SLICK (MELAYANG) ====================
          if (_playingSong != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.pink.shade400,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, -2))],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: Icon(_isPlaying ? Icons.audiotrack : Icons.music_note, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_playingSong!.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis)),
                          Text(_playingArtistName, style: const TextStyle(color: Colors.white70, fontSize: 12, overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Colors.white, size: 36),
                      onPressed: () => setState(() => _isPlaying = !_isPlaying),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => setState(() { _playingSong = null; _isPlaying = false; }),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      
      // FLOATING ACTION BUTTON AMAN (TIDAK BERTUMPANG TINDIH / SOLUSI 1)
      floatingActionButton: _currentTabIndex == 2
          ? null 
          : Padding(
              padding: EdgeInsets.only(bottom: _playingSong != null ? 80.0 : 0.0),
              child: FloatingActionButton.extended(
                onPressed: _currentTabIndex == 0 ? _showAddArtistDialog : _showAddAlbumDialog,
                backgroundColor: Colors.pink.shade300,
                foregroundColor: Colors.white,
                icon: Icon(_currentTabIndex == 0 ? Icons.person_add : Icons.library_add),
                label: Text(_currentTabIndex == 0 ? 'Artis Baru' : 'Album Baru'),
              ),
            ),
    );
  }
}