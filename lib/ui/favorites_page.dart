import 'package:flutter/material.dart';
import '../services/store.dart';
import 'library_page.dart';
import 'theme.dart';

/// 我的 → 我的收藏（独立页，从底部导航挪过来）
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  Set<int> _favs = {};

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final v = await Store.favs();
    if (mounted) setState(() => _favs = v);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.bg,
      appBar: AppBar(
        backgroundColor: T.bg,
        elevation: 0,
        title: Text('我的收藏',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: T.tx)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: T.tx),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: LibraryPage(favs: _favs, onFavChanged: _reload, onlyFav: true),
      ),
    );
  }
}
