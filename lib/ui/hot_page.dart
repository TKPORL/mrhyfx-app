import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/game.dart';
import '../services/api.dart';
import '../services/games_repo.dart';
import 'detail_page.dart';
import 'theme.dart';

/// 热门：按站点下载量排序，每次进入都重新拉榜单（不吃缓存）
class HotPage extends StatefulWidget {
  const HotPage({super.key});
  @override
  State<HotPage> createState() => _HotPageState();
}

class _HotPageState extends State<HotPage> {
  List<Game> _list = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await GamesRepo.load();
    final data = await Api.json(Api.repo, 'app-hot.json');
    final items = ((data?['items'] as List?) ?? const []).whereType<Map>();
    String norm(String x) => x
        .replaceAll(RegExp(r'PC\+安卓|PC|安卓|手机|双端|直装', caseSensitive: false), '')
        .replaceAll(RegExp(r'[\s\-_·（）()【】\[\]]'), '')
        .toLowerCase();
    final out = <Game>[];
    for (final it in items) {
      final raw = (it['name'] ?? '').toString();
      if (raw.contains('合集') || raw.contains('本帖')) continue;
      final key = norm(raw);
      if (key.length < 2) continue;
      for (final g in GamesRepo.all) {
        final t = norm(g.title);
        if (t == key || (key.length > 3 && t.contains(key)) || (t.length > 3 && key.contains(t))) {
          if (!out.any((x) => x.id == g.id)) out.add(g);
          break;
        }
      }
    }
    if (!mounted) return;
    setState(() {
      _list = out;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.bg,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: T.ac,
          backgroundColor: T.card,
          onRefresh: _load,
          child: CustomScrollView(
            physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(18, 10, 18, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.local_fire_department_rounded, size: 22, color: T.ac),
                          SizedBox(width: 6),
                          Text('热门榜',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                        ],
                      ),
                      SizedBox(height: 5),
                      Text('按站内真实下载量实时统计 · 下拉刷新',
                          style: TextStyle(fontSize: 12.5, color: T.tx3)),
                    ],
                  ),
                ),
              ),
              if (_loading)
                SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator(color: T.ac)))
              else if (_list.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text('暂时没有榜单数据', style: TextStyle(fontSize: 13, color: T.tx3)),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(18, 0, 18, 120),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 13,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1 / 0.96,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (c, i) => _card(_list[i], i + 1),
                      childCount: _list.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(Game g, int rank) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailPage(game: g))),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: g.cover,
              fit: BoxFit.cover,
              fadeInDuration: Duration(milliseconds: 240),
              placeholder: (c, u) => ColoredBox(color: T.card2),
              errorWidget: (c, u, e) => ColoredBox(color: T.card2),
            ),
            DecoratedBox(
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
              top: 8,
              left: 8,
              child: Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: rank <= 3 ? T.ac : Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text('$rank',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: rank <= 3 ? Colors.black : Colors.white)),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 9,
              child: Text(g.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, height: 1.3, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
