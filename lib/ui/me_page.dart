import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/game.dart';
import '../services/api.dart';
import '../services/cache.dart';
import '../services/dim.dart';
import '../services/games_repo.dart';
import '../services/store.dart';
import '../services/theme_ctrl.dart';
import 'about_page.dart';
import 'detail_page.dart';
import 'theme.dart';
import 'tip.dart';

class MePage extends StatefulWidget {
  MePage({super.key});
  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  static final _name = 'Tsinho 黄油站';
  int _favCount = 0;
  int _recentCount = 0;
  Map<String, dynamic>? _links;
  int _annCount = 0;
  String _ver = '1.0.0';
  String _modeLabel = '深色';

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final favs = await Store.favs();
    final recent = await Store.recent();
    final links = await Api.json(Api.appRepo, 'app-links.json');
    final ann = await Api.json(Api.appRepo, 'announcements.json');
    final ver = await Api.json(Api.appRepo, 'version.json');
    _syncModeLabel();
    if (!mounted) return;
    setState(() {
      _favCount = favs.length;
      _recentCount = recent.length;
      _links = links;
      _annCount = (ann?['items'] is List) ? (ann!['items'] as List).length : 0;
      _ver = ver?['version']?.toString() ?? '1.0.0';
    });
  }

  Future<void> _open(String? url) async {
    if (url == null || url.isEmpty) return;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final groups = (_links?['groups'] as List?) ?? [];
    final contacts = (_links?['contacts'] as List?) ?? [];
    return Scaffold(
      backgroundColor: T.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 26, 16, 120),
          children: [
            Center(
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(image: AssetImage('assets/avatar.webp'), fit: BoxFit.cover),
                  boxShadow: [BoxShadow(color: Color(0x44000000), blurRadius: 18, offset: Offset(0, 8))],
                ),
              ),
            ),
            SizedBox(height: 12),
            Center(
              child: Text(_name,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
            ),
            SizedBox(height: 5),
            Center(
              child: Text('已收藏 $_favCount 款 · 看过 $_recentCount 款',
                  style: TextStyle(fontSize: 12.5, color: T.tx3)),
            ),
            SizedBox(height: 24),
            _group([
              _row(Icons.notifications_none, Color(0xFFFF9F0A), '公告',
                  value: _annCount > 0 ? '$_annCount 条' : '暂无', onTap: _showAnn),
              _row(Icons.history, Color(0xFF5E5CE6), '最近浏览',
                  value: _recentCount > 0 ? '$_recentCount 款' : '暂无', onTap: _showRecent),
            ]),
            SizedBox(height: 14),
            _group([
              _row(Icons.brightness_4_outlined, const Color(0xFF5E5CE6), '外观',
                  value: _modeLabel, onTap: _pickTheme),
              _brightnessRow(),
            ]),
            if (groups.isNotEmpty || contacts.isNotEmpty) ...[
              SizedBox(height: 14),
              _group([
                for (final g in groups)
                  _row(Icons.groups_outlined, Color(0xFF0A84FF), (g['name'] ?? '').toString(),
                      value: (g['qq'] ?? '').toString(), onTap: () => _open(g['url']?.toString())),
                for (final c in contacts)
                  _row(Icons.chat_bubble_outline, Color(0xFF0A84FF), (c['name'] ?? '').toString(),
                      onTap: () => _open(c['url']?.toString())),
              ]),
            ],
            SizedBox(height: 14),
            _group([
              _row(Icons.cleaning_services_outlined, Color(0xFFFF375F), '清除缓存',
                  onTap: _clearCache),
              _row(Icons.info_outline, Color(0xFF8E8E93), '关于', value: 'v$_ver',
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => AboutPage()))),
            ]),
            SizedBox(height: 22),
            GestureDetector(
              onTap: () => _open('https://tkporl.github.io/mrhyfx/'),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: T.card,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: T.line, width: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.public, size: 16, color: T.tx2),
                    SizedBox(width: 7),
                    Text('访问网页版', style: TextStyle(fontSize: 13.5, color: T.tx2)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _syncModeLabel() {
    final m = ThemeCtrl.mode.value;
    _modeLabel = m == ThemeMode.light ? '浅色' : m == ThemeMode.system ? '跟随系统' : '深色';
  }

  Future<void> _pickTheme() async {
    final picked = await showModalBottomSheet<ThemeMode>(
      context: context,
      backgroundColor: T.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 16, 18, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('外观', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              ),
            ),
            for (final e in [
              (ThemeMode.dark, '深色', '全黑背景，夜里看舒服'),
              (ThemeMode.light, '浅色', '白底深字，白天更清楚'),
              (ThemeMode.system, '跟随系统', '跟手机设置走'),
            ])
              ListTile(
                title: Text(e.$2, style: const TextStyle(fontSize: 15)),
                subtitle: Text(e.$3, style: TextStyle(fontSize: 12, color: T.tx3)),
                trailing: ThemeCtrl.mode.value == e.$1
                    ? const Icon(Icons.check, size: 18, color: T.ac)
                    : null,
                onTap: () => Navigator.pop(c, e.$1),
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
    if (picked != null) {
      await ThemeCtrl.set(picked);
      if (mounted) setState(_syncModeLabel);
    }
  }

  Widget _brightnessRow() {
    return Padding(
      padding: EdgeInsets.fromLTRB(14, 10, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 27,
                height: 27,
                decoration: BoxDecoration(
                    color: Color(0xFF30D158), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.brightness_6, size: 15, color: Colors.white),
              ),
              SizedBox(width: 11),
              Expanded(child: Text('屏幕亮度', style: TextStyle(fontSize: 14))),
              Text('拖动调节', style: TextStyle(fontSize: 12, color: T.tx3)),
            ],
          ),
          const SizedBox(height: 6),
          ValueListenableBuilder<double>(
            valueListenable: Dim.value,
            builder: (c, v, _) => SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: SliderComponentShape.noOverlay,
                activeTrackColor: T.ac,
                inactiveTrackColor: T.card2,
                thumbColor: T.ac,
              ),
              child: Slider(
                min: 0,
                max: 0.6,
                value: v,
                onChanged: (x) => Dim.value.value = x,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _group(List<Widget> children) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        items.add(Divider(height: 0.5, thickness: 0.5, indent: 52, color: T.line));
      }
      items.add(children[i]);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Material(color: T.card, child: Column(children: items)),
    );
  }

  Widget _row(IconData ic, Color tint, String label, {String? value, VoidCallback? onTap}) => InkWell(
        onTap: onTap ?? () => Tip.show(context, '$label 还在做，先看别的'),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 27,
                height: 27,
                decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(8)),
                child: Icon(ic, size: 15, color: Colors.white),
              ),
              SizedBox(width: 11),
              Expanded(child: Text(label, style: TextStyle(fontSize: 14))),
              if (value != null && value.isNotEmpty)
                Text(value, style: TextStyle(fontSize: 12.5, color: T.tx3)),
              SizedBox(width: 6),
              Icon(Icons.chevron_right, size: 16, color: T.tx3),
            ],
          ),
        ),
      );

  Future<void> _clearCache() async {
    Tip.show(context, '正在清除…');
    await Store.clearAll();
    await Cache.clear();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    setState(() {
      _favCount = 0;
      _recentCount = 0;
    });
    Tip.show(context, '缓存与收藏记录已清除');
  }

  Future<void> _showAnn() async {
    final ann = await Api.json(Api.appRepo, 'announcements.json');
    final items = (ann?['items'] as List?) ?? [];
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: T.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (c) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: ListView(
            shrinkWrap: true,
            children: [
              Text('公告', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
              SizedBox(height: 12),
              if (items.isEmpty) Text('暂无公告', style: TextStyle(color: T.tx3)),
              for (final a in items)
                Padding(
                  padding: EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text((a['title'] ?? '').toString(),
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      SizedBox(height: 5),
                      Text((a['body'] ?? '').toString(),
                          style: TextStyle(fontSize: 13, height: 1.6, color: T.tx2)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showRecent() async {
    Tip.show(context, '读取中…');
    final ids = await Store.recent();
    final all = await GamesRepo.load();
    if (!mounted) return;
    final list = ids.map((i) => GamesRepo.byId(i)).whereType<Game>().toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: T.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (c) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.fromLTRB(16, 16, 16, 18),
          children: [
            Text('最近浏览', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
            SizedBox(height: 10),
            if (list.isEmpty) Text('还没有记录', style: TextStyle(color: T.tx3)),
            for (final g in list)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(g.cover,
                      width: 42, height: 52, fit: BoxFit.cover,
                      errorBuilder: (a, b, c2) =>
                          SizedBox(width: 42, height: 52, child: ColoredBox(color: T.card2))),
                ),
                title: Text(g.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13)),
                onTap: () {
                  Navigator.pop(c);
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => DetailPage(game: g)));
                },
              ),
          ],
        ),
      ),
    );
  }
}
