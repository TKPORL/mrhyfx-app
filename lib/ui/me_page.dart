import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/game.dart';
import '../services/api.dart';
import '../services/cache.dart';
import '../services/store.dart';
import 'detail_page.dart';
import 'theme.dart';

class MePage extends StatefulWidget {
  const MePage({super.key});
  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  String _name = 'Tsinho';
  int _favCount = 0;
  int _recentCount = 0;
  Map<String, dynamic>? _links;
  int _annCount = 0;
  String? _newVersion;
  String? _avatar;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final name = await Store.name();
    final favs = await Store.favs();
    final recent = await Store.recent();
    final links = await Api.json(Api.appRepo, 'app-links.json');
    final ann = await Api.json(Api.appRepo, 'announcements.json');
    final ver = await Api.json(Api.appRepo, 'version.json');
    final av = await Store.avatarPath();
    if (!mounted) return;
    setState(() {
      _name = name;
      _favCount = favs.length;
      _recentCount = recent.length;
      _links = links;
      _annCount = (ann?['items'] is List) ? (ann!['items'] as List).length : 0;
      _avatar = av;
      final v = ver?['version']?.toString();
      if (v != null && v != '1.0.0') _newVersion = v;
    });
    if (_newVersion != null) {
      _snack('发现新版本 v$_newVersion，可在公告里查看更新说明');
    }
  }

  void _snack(String m) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(m), behavior: SnackBarBehavior.floating, backgroundColor: T.card2));
  }

  Future<void> _rename() async {
    final c = TextEditingController(text: _name);
    final v = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: T.card,
        title: const Text('修改昵称', style: TextStyle(fontSize: 17)),
        content: TextField(
          controller: c,
          autofocus: true,
          maxLength: 16,
          decoration: const InputDecoration(counterText: ''),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, c.text.trim()),
              child: const Text('保存', style: TextStyle(color: T.ac))),
        ],
      ),
    );
    if (v != null && v.isNotEmpty) {
      await Store.setName(v);
      if (mounted) setState(() => _name = v);
    }
  }

  Future<void> _open(String? url) async {
    if (url == null || url.isEmpty) return;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> _pickAvatar() async {
    try {
      final f = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 480, imageQuality: 86);
      if (f == null) return;
      await Store.setAvatarPath(f.path);
      if (mounted) setState(() => _avatar = f.path);
    } catch (e) {
      _snack('打开相册失败：$e');
    }
  }

  Future<void> _export() async {
    final favs = await Store.favs();
    final recent = await Store.recent();
    final data = {
      'app': 'tsinho-gamebox',
      'v': 1,
      'at': DateTime.now().toIso8601String(),
      'name': _name,
      'favs': favs.toList(),
      'recent': recent,
    };
    await Clipboard.setData(ClipboardData(text: jsonEncode(data)));
    _snack('存档已复制，粘到记事本或发给自己保存');
  }

  Future<void> _import() async {
    final clip = await Clipboard.getData(Clipboard.kTextPlain);
    final txt = clip?.text ?? '';
    try {
      final d = jsonDecode(txt) as Map<String, dynamic>;
      if (d['app'] != 'tsinho-gamebox') {
        _snack('剪贴板里不是本应用的存档');
        return;
      }
      final favs = ((d['favs'] as List?) ?? const []).map((e) => (e as num).toInt()).toSet();
      final recent = ((d['recent'] as List?) ?? const []).map((e) => (e as num).toInt()).toList();
      await Store.saveFavs(favs);
      await Store.setRecent(recent);
      if (d['name'] is String) await Store.setName(d['name'] as String);
      setState(() {
        _name = (d['name'] is String) ? d['name'] as String : _name;
        _favCount = favs.length;
        _recentCount = recent.length;
      });
      _snack('已恢复 ${favs.length} 个收藏');
    } catch (e) {
      _snack('导入失败：剪贴板内容不是有效存档');
    }
  }

  Future<void> _clearCache() async {
    await Cache.clear();
    _snack('缓存已清除，下次打开会重新拉取数据');
  }

  @override
  Widget build(BuildContext context) {
    final groups = (_links?['groups'] as List?) ?? const [];
    final contacts = (_links?['contacts'] as List?) ?? const [];
    return Scaffold(
      backgroundColor: T.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
          children: [
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _avatar == null
                        ? const LinearGradient(colors: [Color(0xFFFF9F0A), Color(0xFFFF375F)])
                        : null,
                    image: _avatar == null
                        ? null
                        : DecorationImage(image: FileImage(File(_avatar!)), fit: BoxFit.cover),
                  ),
                  alignment: Alignment.center,
                  child: _avatar == null ? const Icon(Icons.pets, size: 34, color: Colors.white) : null,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: _rename,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 6),
                    const Icon(Icons.edit, size: 13, color: T.tx3),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            Center(
              child: Text('已收藏 $_favCount 款 · 看过 $_recentCount 款',
                  style: const TextStyle(fontSize: 12.5, color: T.tx3)),
            ),
            const SizedBox(height: 26),
            _group([
              _row(Icons.notifications_none, const Color(0xFFFF9F0A), '公告',
                  value: _annCount > 0 ? '$_annCount 条' : '暂无', onTap: _showAnn),
              _row(Icons.history, const Color(0xFF5E5CE6), '最近浏览',
                  value: _recentCount > 0 ? '$_recentCount 款' : '暂无', onTap: _showRecent),
            ]),
            const SizedBox(height: 16),
            _group([
              _row(Icons.save_alt, const Color(0xFF30D158), '导出存档', onTap: _export),
              _row(Icons.file_download_outlined, const Color(0xFF0A84FF), '导入存档', onTap: _import),
              _row(Icons.cleaning_services_outlined, const Color(0xFFFF375F), '清除缓存', onTap: _clearCache),
              _row(Icons.info_outline, const Color(0xFF8E8E93), '关于',
                  value: _newVersion == null ? 'v1.0.0' : 'v1.0.0 → v$_newVersion'),
            ]),
            if (groups.isNotEmpty) ...[
              const SizedBox(height: 16),
              _group([
                for (final g in groups)
                  _row(Icons.groups_outlined, const Color(0xFF0A84FF), (g['name'] ?? '').toString(),
                      value: (g['qq'] ?? '').toString(), onTap: () => _open(g['url']?.toString())),
                for (final c in contacts)
                  _row(Icons.chat_bubble_outline, const Color(0xFF0A84FF), (c['name'] ?? '').toString(),
                      onTap: () => _open(c['url']?.toString())),
              ]),
            ],
            const SizedBox(height: 22),
            Center(
              child: GestureDetector(
                onTap: () => _open('https://tkporl.github.io/mrhyfx/'),
                child: const Text('访问网页版', style: TextStyle(fontSize: 12.5, color: T.tx3)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _group(List<Widget> children) => Container(
        decoration: BoxDecoration(color: T.card, borderRadius: BorderRadius.circular(14)),
        child: Column(children: children),
      );

  Widget _row(IconData ic, Color tint, String label, {String? value, VoidCallback? onTap}) => InkWell(
        onTap: onTap ?? () => _snack('$label：开发中'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 27,
                height: 27,
                decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(8)),
                child: Icon(ic, size: 15, color: Colors.white),
              ),
              const SizedBox(width: 11),
              Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
              if (value != null && value.isNotEmpty)
                Text(value, style: const TextStyle(fontSize: 12.5, color: T.tx3)),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, size: 16, color: T.tx3),
            ],
          ),
        ),
      );

  Future<void> _showAnn() async {
    final ann = await Api.json(Api.appRepo, 'announcements.json');
    final items = (ann?['items'] as List?) ?? const [];
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: T.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: ListView(
            shrinkWrap: true,
            children: [
              const Text('公告', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              if (items.isEmpty) const Text('暂无公告', style: TextStyle(color: T.tx3)),
              for (final a in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text((a['title'] ?? '').toString(),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 5),
                      Text((a['body'] ?? '').toString(),
                          style: const TextStyle(fontSize: 13, height: 1.6, color: T.tx2)),
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
    final ids = await Store.recent();
    final data = await Api.rawJson(Api.repo, 'app-games.json');
    final all = Game.listFrom(data);
    if (!mounted) return;
    final list = ids.map((i) => all.where((g) => g.id == i)).expand((e) => e).toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: T.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (c) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          children: [
            const Text('最近浏览', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            if (list.isEmpty) const Text('还没有记录', style: TextStyle(color: T.tx3)),
            for (final g in list)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(g.cover,
                      width: 42, height: 52, fit: BoxFit.cover,
                      errorBuilder: (a, b, c2) => const SizedBox(width: 42, height: 52)),
                ),
                title: Text(g.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13)),
                onTap: () {
                  Navigator.pop(c);
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailPage(game: g)));
                },
              ),
          ],
        ),
      ),
    );
  }
}
