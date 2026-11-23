import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/game.dart';
import '../services/games_repo.dart';
import '../services/store.dart';
import 'announce.dart';
import 'detail_page.dart';
import 'theme.dart';

class LibraryPage extends StatefulWidget {
  final Set<int> favs;
  final Future<void> Function() onFavChanged;
  final bool onlyFav;
  final VoidCallback? onGoLibrary;
  LibraryPage({super.key, required this.favs, required this.onFavChanged, this.onlyFav = false, this.onGoLibrary});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  List<Game> _all = [];
  bool _loading = true;
  String _kw = '';
  String _tag = '';
  final _scroll = ScrollController();
  bool _showTop = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final on = _scroll.offset > 700;
      if (on != _showTop) setState(() => _showTop = on);
    });
    _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load({bool force = false}) async {
    setState(() => _loading = true);
    final list = await GamesRepo.load(force: force);
    if (!mounted) return;
    setState(() {
      _all = list;
      _loading = false;
    });
  }

  Future<void> _toggleFav(int id) async {
    final v = await Store.favs();
    if (!v.remove(id)) v.add(id);
    await Store.saveFavs(v);
    await widget.onFavChanged();
  }

  bool _isNew(Game g) {
    if (g.date.isEmpty) return false;
    final d = DateTime.tryParse(g.date);
    if (d == null) return false;
    return DateTime.now().difference(d).inDays <= 7;
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

  /// 从全部游戏里统计真实类型，按出现次数排序（不写死）
  static final _tagNoise = {
    '简介', '更新', '存档', '电脑', '电脑版', '汉化', '中文', '日系', '官方中文版',
    '生肉', '动态', '步兵', '步兵版', '官中', '官中版', '新作', '全回想',
  };

  List<String> get _tags {
    final count = <String, int>{};
    for (final g in _all) {
      for (final t in g.tags) {
        final x = t.trim();
        if (x.isEmpty) continue;
        if (x.contains(' ')) continue;            // 「百度网盘 发布者备注」这类是整个介绍标题
        if (x.length > 8) continue;
        if (_tagNoise.contains(x)) continue;
        if (RegExp(r'发布者|备注|网盘|链接|解压|出处|原名|别名').hasMatch(x)) continue;
        count[x] = (count[x] ?? 0) + 1;
      }
    }
    // 只留下真正成类型的：至少出现 3 次且占比够，杂项自动沉底
    final min = (_all.length * 0.004).round().clamp(3, 9999);
    final list = count.entries.where((e) => e.value >= min).map((e) => e.key).toList()
      ..sort((a, b) => count[b]!.compareTo(count[a]!));
    return list.take(40).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _shown;
    return Scaffold(
      backgroundColor: T.bg,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            RefreshIndicator(
              color: T.ac,
              backgroundColor: T.card,
              onRefresh: () => _load(force: true),
              child: CustomScrollView(
                controller: _scroll,
                physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                slivers: [
                  SliverToBoxAdapter(child: _header()),
                  if (_loading)
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(18, 11, 18, 130),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 13,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1 / 0.96,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (c, i) => ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: ShimmerBox(),
                          ),
                          childCount: 8,
                        ),
                      ),
                    )
                  else if (list.isEmpty)
                    SliverFillRemaining(hasScrollBody: false, child: _empty())
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(18, 11, 18, 130),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 13,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1 / 0.96,
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
            Positioned(
              right: 16,
              bottom: 104,
              child: IgnorePointer(
                ignoring: !_showTop,
                child: AnimatedSlide(
                  offset: _showTop ? Offset.zero : Offset(0, 0.6),
                  duration: Duration(milliseconds: 220),
                  child: AnimatedOpacity(
                    opacity: _showTop ? 1 : 0,
                    duration: Duration(milliseconds: 200),
                    child: _topBtn(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBtn() => GestureDetector(
        onTap: () => _scroll.animateTo(0,
            duration: Duration(milliseconds: 420), curve: Curves.easeOutCubic),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: T.glass,
            shape: BoxShape.circle,
            border: Border.all(color: T.line, width: 0.5),
            boxShadow: [BoxShadow(color: Color(0x66000000), blurRadius: 16, offset: Offset(0, 6))],
          ),
          child: Icon(Icons.keyboard_arrow_up_rounded, size: 22, color: T.tx),
        ),
      );

  Widget _header() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.onlyFav ? '我的收藏' : 'Tsinho 黄油站',
                        style: TextStyle(
                            fontSize: 27, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                    SizedBox(height: 4),
                    Text(_loading ? '正在加载全部游戏…' : '${_all.length} 款在架 · 每日更新',
                        style: TextStyle(fontSize: 12.5, color: T.tx3)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => showAnnouncements(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: T.glass,
                    border: Border.all(color: T.line, width: 0.5),
                  ),
                  child: Icon(Icons.notifications_none_rounded, size: 19, color: T.tx2),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 37,
                  decoration: BoxDecoration(color: T.card, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      SizedBox(width: 10),
                      Icon(Icons.search, size: 17, color: T.tx3),
                      SizedBox(width: 7),
                      Expanded(
                        child: TextField(
                          onChanged: (v) => setState(() => _kw = v.trim()),
                          style: TextStyle(fontSize: 14),
                          decoration: InputDecoration(
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
              SizedBox(width: 8),
              GestureDetector(
                onTap: _pickTag,
                child: Container(
                  width: 41,
                  height: 37,
                  decoration: BoxDecoration(
                    color: _tag.isEmpty ? T.card : T.ac.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: _tag.isEmpty ? Colors.transparent : T.ac.withOpacity(0.4), width: 0.5),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (c) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('按类型筛选', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              SizedBox(height: 14),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 380),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags.map((t) {
                      final on = t == _tag;
                      return GestureDetector(
                        onTap: () => Navigator.pop(c, t),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 13, vertical: 8),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) setState(() => _tag = picked);
  }

  Widget _card(Game g) {
    return _Pressable(
      onTap: () async {
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailPage(game: g)));
        widget.onFavChanged();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: g.cover,
              fit: BoxFit.cover,
              fadeInDuration: Duration(milliseconds: 260),
              placeholder: (c, u) => ShimmerBox(),
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
            if (_isNew(g))
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: T.ac,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('NEW',
                      style: TextStyle(
                          fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.black)),
                ),
              ),
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () => _toggleFav(g.id),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.32),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.favs.contains(g.id) ? Icons.favorite : Icons.favorite_border,
                    size: 15,
                    color: widget.favs.contains(g.id) ? Color(0xFFFF375F) : Colors.white,
                  ),
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
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600, height: 1.3, color: Colors.white)),
                  SizedBox(height: 4),
                  Text(g.platform,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10.5, color: Color(0xB3FFFFFF))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty() {
    final err = GamesRepo.error;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(err != null ? Icons.wifi_off_rounded : Icons.inbox_rounded,
                size: 42, color: T.tx3),
            SizedBox(height: 12),
            Text(
                widget.onlyFav
                    ? '还没有收藏'
                    : err != null
                        ? '没连上数据'
                        : '暂时没有数据',
                style: TextStyle(fontSize: 15, color: T.tx2)),
            SizedBox(height: 6),
            Text(
                widget.onlyFav
                    ? '在游戏封面右上角点一下心形，就会出现在这里'
                    : err ?? '下拉可以刷新',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: T.tx3, height: 1.6)),
            if (widget.onlyFav && widget.onGoLibrary != null) ...[
              SizedBox(height: 18),
              GestureDetector(
                onTap: widget.onGoLibrary,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                  decoration: BoxDecoration(
                    color: T.ac.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: T.ac.withOpacity(0.35), width: 0.5),
                  ),
                  child: Text('去游戏库逛逛',
                      style: TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w600, color: T.ac)),
                ),
              ),
            ],
            if (!widget.onlyFav && err != null) ...[
              SizedBox(height: 18),
              GestureDetector(
                onTap: () => _load(force: true),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                  decoration: BoxDecoration(
                    color: T.ac.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('重新加载',
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: T.ac)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 图片加载中的微光占位
class ShimmerBox extends StatefulWidget {
  ShimmerBox({super.key});
  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: Duration(milliseconds: 1200))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => DecoratedBox(
        decoration: BoxDecoration(
          color: T.card2,
          gradient: LinearGradient(
            begin: Alignment(-1.4 + _c.value * 2.8, 0),
            end: Alignment(-0.4 + _c.value * 2.8, 0),
            colors: [Color(0xFF232326), Color(0xFF303034), Color(0xFF232326)],
          ),
        ),
      ),
    );
  }
}


/// 卡片按压：按下缩到 0.96，松开回弹（对齐 demo 的 :active 缩放）
class _Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _Pressable({required this.child, required this.onTap});
  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.96 : 1,
        duration: Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
