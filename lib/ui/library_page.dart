import 'package:flutter/material.dart';
import '../models/game.dart';
import '../services/api.dart';
import '../services/store.dart';
import 'detail_page.dart';
import 'theme.dart';

class LibraryPage extends StatefulWidget {
  final Set<int> favs;
  final Future<void> Function() onFavChanged;
  final bool onlyFav;
  const LibraryPage({super.key, required this.favs, required this.onFavChanged, this.onlyFav = false});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  List<Game> _all = [];
  bool _loading = true;
  String _kw = '';
  String _tag = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool force = false}) async {
    setState(() => _loading = true);
    final data = await Api.cachedRawJson(Api.repo, 'app-games.json', force: force);
    final list = Game.listFrom(data);
    if (!mounted) return;
    setState(() {
      _all = list;
      _loading = false;
    });
  }

  List<Game> get _shown {
    var l = _all;
    if (widget.onlyFav) l = l.where((g) => widget.favs.contains(g.id)).toList();
    if (_tag.isNotEmpty) l = l.where((g) => g.tags.contains(_tag)).toList();
    if (_kw.isNotEmpty) {
      final k = _kw.toLowerCase();
      l = l.where((g) => g.title.toLowerCase().contains(k)).toList();
    }
    return l;
  }

  List<String> get _tags {
    final s = <String>{};
    for (final g in _all) {
      s.addAll(g.tags);
    }
    return s.take(12).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _shown;
    return Scaffold(
      backgroundColor: T.bg,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: T.ac,
          backgroundColor: T.card,
          onRefresh: () => _load(force: true),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _header()),
              if (_loading)
                const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator(color: T.ac)))
              else if (list.isEmpty)
                SliverFillRemaining(hasScrollBody: false, child: _empty())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 13,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1 / 1.28,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (c, i) => _card(list[i]),
                      childCount: list.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.onlyFav ? '我的收藏' : 'Tsinho 游戏库',
              style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text('${_all.length} 款在架 · 每日更新',
              style: const TextStyle(fontSize: 12.5, color: T.tx3)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 37,
                  decoration: BoxDecoration(color: T.card, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      const Icon(Icons.search, size: 17, color: T.tx3),
                      const SizedBox(width: 7),
                      Expanded(
                        child: TextField(
                          onChanged: (v) => setState(() => _kw = v.trim()),
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: '搜索游戏名',
                            hintStyle: TextStyle(color: T.tx3, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _pickTag,
                child: Container(
                  width: 41,
                  height: 37,
                  decoration: BoxDecoration(
                    color: _tag.isEmpty ? T.card : T.ac.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _tag.isEmpty ? Colors.transparent : T.ac.withOpacity(0.4), width: 0.5),
                  ),
                  child: Icon(Icons.tune, size: 17, color: _tag.isEmpty ? T.tx2 : T.ac),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickTag() async {
    final tags = ['', ..._tags];
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: T.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('按类型筛选', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((t) {
                  final on = t == _tag;
                  return GestureDetector(
                    onTap: () => Navigator.pop(c, t),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                      decoration: BoxDecoration(
                        color: on ? T.ac : T.card2,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(t.isEmpty ? '全部' : t,
                          style: TextStyle(fontSize: 13, color: on ? Colors.black : T.tx2)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) setState(() => _tag = picked);
  }

  Widget _card(Game g) {
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailPage(game: g)));
        widget.onFavChanged();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: T.card2),
            Image.network(g.cover, fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const ColoredBox(color: T.card2)),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC000000)],
                  stops: [0.45, 1],
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(g.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.3, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('${g.platform}  ${g.size}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10.5, color: Color(0xB3FFFFFF))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_rounded, size: 42, color: T.tx3),
          const SizedBox(height: 12),
          Text(widget.onlyFav ? '还没有收藏' : '暂时没有数据',
              style: const TextStyle(fontSize: 15, color: T.tx2)),
          const SizedBox(height: 6),
          Text(widget.onlyFav ? '在详情页点右上角的心形' : '下拉刷新试试',
              style: const TextStyle(fontSize: 12.5, color: T.tx3)),
        ],
      ),
    );
  }
}
