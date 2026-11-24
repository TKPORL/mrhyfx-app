import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/game.dart';
import '../services/games_repo.dart';
import 'detail_page.dart';
import 'theme.dart';

/// 求助帖专区：页面底部是最新，这里按 qztRank 升序（最新在前）展示全量
class QztPage extends StatefulWidget {
  const QztPage({super.key});
  @override
  State<QztPage> createState() => _QztPageState();
}

class _QztPageState extends State<QztPage> {
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
    final l = GamesRepo.all.where((g) => g.source == 'qzt').toList()
      ..sort((a, b) => a.qztRank.compareTo(b.qztRank));
    if (!mounted) return;
    setState(() {
      _list = l;
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
                      Text('求助帖',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                      SizedBox(height: 5),
                      Text('大家求过的游戏，共 ${_list.length} 款 · 最新的排最前',
                          style: TextStyle(fontSize: 12.5, color: T.tx3)),
                    ],
                  ),
                ),
              ),
              if (_loading)
                SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator(color: T.ac)))
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
                      (c, i) => _card(_list[i]),
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

  Widget _card(Game g) {
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
            if (g.qztRank > 0 && g.qztRank <= 10)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: T.ac, borderRadius: BorderRadius.circular(6)),
                  child: Text('最新',
                      style: TextStyle(
                          fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.black)),
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
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600, height: 1.3, color: Colors.white)),
                  SizedBox(height: 4),
                  Text('第 ${g.qztRank} 条',
                      style: TextStyle(fontSize: 10.5, color: Color(0xB3FFFFFF))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
