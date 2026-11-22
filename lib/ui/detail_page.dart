import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/game.dart';
import '../services/store.dart';
import 'theme.dart';

class DetailPage extends StatefulWidget {
  final Game game;
  const DetailPage({super.key, required this.game});
  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _fav = false;
  double _sx = 999;
  String? _codeShown;

  @override
  void initState() {
    super.initState();
    Store.favs().then((v) {
      if (mounted) setState(() => _fav = v.contains(widget.game.id));
    });
    Store.pushRecent(widget.game.id);
  }

  Future<void> _toggleFav() async {
    final v = await Store.favs();
    if (v.contains(widget.game.id)) {
      v.remove(widget.game.id);
    } else {
      v.add(widget.game.id);
    }
    await Store.saveFavs(v);
    if (mounted) setState(() => _fav = v.contains(widget.game.id));
  }

  Future<void> _copyCode() async {
    final code = widget.game.code;
    if (code.trim().isEmpty) {
      _snack('这条记录没有解压码');
      return;
    }
    await Clipboard.setData(ClipboardData(text: code));
    if (mounted) setState(() => _codeShown = code);
  }

  Future<void> _open(String url) async {
    if (url.isEmpty) {
      _snack('没有可用的下载链接');
      return;
    }
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!ok) _snack('打开失败，请检查链接');
  }

  void _snack(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.game;
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
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Image.network(g.cover, fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const ColoredBox(color: T.card2)),
                  ),
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xF20B0B0C)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Transform.translate(
                offset: const Offset(0, -46),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(g.title,
                          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w700, height: 1.22)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (g.platform.isNotEmpty) _tag(g.platform, hot: true),
                          ...g.tags.map((t) => _tag(t)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _fact(g.size, '体积'),
                          _fact(g.platform, '平台'),
                          _fact(g.tags.isNotEmpty ? g.tags.first : '—', '类型'),
                        ],
                      ),
                      const SizedBox(height: 18),
                      if (g.intro.isNotEmpty) ...[
                        const Text('说明', style: TextStyle(fontSize: 13, color: T.tx3)),
                        const SizedBox(height: 8),
                        Text(g.intro, style: const TextStyle(fontSize: 14, height: 1.7, color: T.tx2)),
                      ],
                      if (_codeShown != null) ...[
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: T.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: T.ac.withOpacity(0.3), width: 0.5),
                          ),
                          child: Row(
                            children: [
                              const Text('解压码 ', style: TextStyle(fontSize: 12, color: T.tx3)),
                              Expanded(
                                child: SelectableText(_codeShown!,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: T.ac)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 12,
            right: 12,
            top: MediaQuery.of(context).padding.top + 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circle(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
                _circle(_fav ? Icons.favorite : Icons.favorite_border, _toggleFav,
                    color: _fav ? const Color(0xFFFF375F) : T.tx),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
              decoration: const BoxDecoration(
                color: Color(0xF2161618),
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
                          side: const BorderSide(color: T.line),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                        ),
                        child: const Text('解压码', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
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
                        child: const Text('获取下载', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _tag(String t, {bool hot = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
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
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 3),
            Text(label, style: const TextStyle(fontSize: 11, color: T.tx3)),
          ],
        ),
      );

  Widget _circle(IconData ic, VoidCallback onTap, {Color color = T.tx}) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.42),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white12, width: 0.5),
          ),
          child: Icon(ic, size: 16, color: color),
        ),
      );
}
