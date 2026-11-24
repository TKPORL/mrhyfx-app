import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/game.dart';
import '../services/api.dart';
import '../services/games_repo.dart';
import '../services/store.dart';
import 'theme.dart';
import 'support.dart';
import 'tip.dart';

class DetailPage extends StatefulWidget {
  final Game game;
  DetailPage({super.key, required this.game});
  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _fav = false;
  String? _codeShown;
  double _sx = 999;

  late Game g;

  @override
  void initState() {
    super.initState();
    g = widget.game;
    _loadDetail();
    Store.favs().then((v) {
      if (mounted) setState(() => _fav = v.contains(g.id));
    });
    Store.pushRecent(g.id);
  }

  /// 列表接口只带轻量字段，简介/解压码/链接从该帖分片里按需拉
  Future<void> _loadDetail() async {
    if (g.intro.isNotEmpty || g.page.isEmpty) return;
    final data = await Api.rawJson(Api.repo, 'app-details/${g.page}.json');
    if (data is! List || !mounted) return;
    Map? hit;
    for (final m in data.whereType<Map>()) {
      if ((m['id'] as num?)?.toInt() == g.id) {
        hit = m;
        break;
      }
    }
    if (hit != null) setState(() => g = g.withDetail(hit!));
  }

  Future<void> _toggleFav() async {
    final v = await Store.favs();
    if (v.contains(g.id)) {
      v.remove(g.id);
    } else {
      v.add(g.id);
    }
    await Store.saveFavs(v);
    final on = v.contains(g.id);
    if (mounted) {
      setState(() => _fav = on);
      Tip.show(context, on ? '已加入收藏' : '已取消收藏');
    }
  }

  Future<void> _copyCode() async {
    final code = g.code.trim();
    if (code.isEmpty) {
      Tip.show(context, '这条记录没有解压码，去网盘页面看说明');
      return;
    }
    await Clipboard.setData(ClipboardData(text: code));
    if (mounted) {
      setState(() => _codeShown = code);
      Tip.show(context, '解压码已复制：$code');
    }
  }

  Future<void> _open(String url) async {
    if (url.isEmpty) {
      Tip.show(context, '这条记录没有下载链接');
      return;
    }
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!ok && mounted) Tip.show(context, '打开失败，链接可能已失效');
  }

  @override
  Widget build(BuildContext context) {
    var related = GamesRepo.all
        .where((x) => x.id != g.id && x.tags.any(g.tags.contains))
        .take(6)
        .toList();
    // 标签太少匹配不到时，用同平台兜底，避免这里空着
    if (related.isEmpty) {
      related = GamesRepo.all
          .where((x) => x.id != g.id && x.platform == g.platform)
          .take(6)
          .toList();
    }
    // 还是空（冷门游戏、标签和平台都匹配不到）→ 取浏览记录里的邻居，保证这一块不空
    if (related.isEmpty) {
      related = GamesRepo.all.where((x) => x.id != g.id).take(6).toList();
    }

    return GestureDetector(
      onHorizontalDragStart: (d) => _sx = d.globalPosition.dx,
      onHorizontalDragEnd: (d) {
        if (_sx < 40 && (d.primaryVelocity ?? 0) > 220) Navigator.maybePop(context);
      },
      child: Scaffold(
        backgroundColor: T.bg,
        body: Stack(
          children: [
            ListView(
              padding: EdgeInsets.only(bottom: 120),
              children: [
                // 固定 3:4 画幅，所有游戏一致；图片填满裁切（主角偏一侧时由裁切中心决定）
                SizedBox(
                  height: 318,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: g.cover,
                        fit: BoxFit.cover,
                        fadeInDuration: Duration(milliseconds: 240),
                        errorWidget: (c, u, e) => ColoredBox(color: T.card2),
                      ),
                      IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0x990B0B0C),
                                Colors.transparent,
                                Colors.transparent,
                                T.bg,
                              ],
                              stops: [0, 0.22, 0.46, 1],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, -56),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(g.title,
                            style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700, height: 1.22)),
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (g.platform.isNotEmpty) _tag(g.platform, hot: true),
                            ...g.tags.where((t) => t != g.platform).take(4).map((t) => _tag(t)),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            if (g.sizeDisplay != '—') _fact(g.sizeDisplay, '体积'),
                            _fact(g.platform, '平台'),
                            if (g.typeDisplay != '—') _fact(g.typeDisplay, '类型'),
                          ],
                        ),
                        SizedBox(height: 18),
                        if (g.shots.isNotEmpty) ...[
                          Text('截图', style: TextStyle(fontSize: 13, color: T.tx3)),
                          SizedBox(height: 10),
                          SizedBox(
                            height: 104,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: g.shots.length,
                              separatorBuilder: (c, i) => SizedBox(width: 8),
                              itemBuilder: (c, i) => ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: g.shots[i],
                                  width: 150,
                                  fit: BoxFit.cover,
                                  errorWidget: (a, b, d) => SizedBox(
                                      width: 150,
                                      child: ColoredBox(color: T.card2)),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 18),
                        ],
                        if (g.intro.isNotEmpty) ...[
                          Text('说明', style: TextStyle(fontSize: 13, color: T.tx3)),
                          SizedBox(height: 8),
                          Text(g.intro, style: TextStyle(fontSize: 14, height: 1.7, color: T.tx2)),
                        ],
                        if (_codeShown != null) ...[
                          SizedBox(height: 16),
                          _codeBox(_codeShown!),
                        ],
                        SizedBox(height: 22),
                        if (related.isNotEmpty) ...[
                          Text('同类推荐', style: TextStyle(fontSize: 13, color: T.tx3)),
                          SizedBox(height: 10),
                          SizedBox(
                            height: 132,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: related.length,
                              separatorBuilder: (c, i) => SizedBox(width: 10),
                              itemBuilder: (c, i) {
                                final r = related[i];
                                return GestureDetector(
                                  onTap: () => Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(builder: (_) => DetailPage(game: r))),
                                  child: SizedBox(
                                    width: 92,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: CachedNetworkImage(
                                            imageUrl: r.cover,
                                            width: 92,
                                            height: 92,
                                            fit: BoxFit.cover,
                                            errorWidget: (a, b, c2) => SizedBox(
                                                width: 92, height: 92, child: ColoredBox(color: T.card2)),
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text(r.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 11, height: 1.25, color: T.tx2)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                        SizedBox(height: 18),
                        _support(),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 12,
              right: 12,
              top: MediaQuery.of(context).padding.top + 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circle(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
                  _circle(_fav ? Icons.favorite : Icons.favorite_border, _toggleFav,
                      color: _fav ? Color(0xFFFF375F) : T.tx),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
                decoration: BoxDecoration(
                  color: T.sheet,
                  border: Border(top: BorderSide(color: T.line, width: 0.5)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _copyCode,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: T.tx,
                            side: BorderSide(color: T.line),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                          ),
                          child: Text('解压码',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 48,
                        child: FilledButton(
                          onPressed: () => _open(g.linkMobile.isNotEmpty ? g.linkMobile : g.linkPc),
                          style: FilledButton.styleFrom(
                            backgroundColor: T.ac,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                          ),
                          child: Text('获取下载',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _codeBox(String code) => Container(
        width: double.infinity,
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: T.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: T.ac.withOpacity(0.3), width: 0.5),
        ),
        child: Row(
          children: [
            Text('解压码 ', style: TextStyle(fontSize: 12, color: T.tx3)),
            Expanded(
              child: SelectableText(code,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: T.ac)),
            ),
          ],
        ),
      );

  Widget _support() => GestureDetector(
        onTap: () => showSupportSheet(context),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: T.ac.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: T.ac.withOpacity(0.18), width: 0.5),
          ),
          child: Row(
            children: [
              Icon(Icons.local_cafe_outlined, size: 16, color: T.ac),
              SizedBox(width: 9),
              Expanded(
                child: Text('喜欢这款？请站长喝杯咖啡',
                    style: TextStyle(fontSize: 13, color: T.tx2)),
              ),
              Text('支持', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: T.ac)),
            ],
          ),
        ),
      );

  Widget _tag(String t, {bool hot = false}) => Container(
        padding: EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: hot ? T.ac.withOpacity(0.14) : T.card2,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(t, style: TextStyle(fontSize: 11.5, color: hot ? T.ac : T.tx2)),
      );

  Widget _fact(String v, String label) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(v.isEmpty ? '—' : v,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            SizedBox(height: 3),
            Text(label, style: TextStyle(fontSize: 11, color: T.tx3)),
          ],
        ),
      );

  Widget _circle(IconData ic, VoidCallback onTap, {Color? color}) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.42),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white12, width: 0.5),
          ),
          child: Icon(ic, size: 16, color: color ?? T.tx),
        ),
      );
}
