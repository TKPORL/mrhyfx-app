import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api.dart';
import 'theme.dart';

/// 公告弹层：首页铃铛和「我的 → 公告」共用
Future<void> showAnnouncements(BuildContext context) async {
  final ann = await Api.json(Api.appRepo, 'announcements.json');
  final items = ((ann?['items'] as List?) ?? const [])
      .whereType<Map>()
      .where((a) => a['visible'] != false)
      .toList();
  if (!context.mounted) return;
  showModalBottomSheet(
    context: context,
    backgroundColor: T.card,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (c) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(c).size.height * 0.78),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('公告', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: T.tx)),
              const SizedBox(height: 4),
              Text('长按正文可复制', style: TextStyle(fontSize: 11.5, color: T.tx3)),
              const SizedBox(height: 14),
              if (items.isEmpty) Text('暂无公告', style: TextStyle(color: T.tx3)),
              for (final a in items) _annItem(c, a),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _annItem(BuildContext c, Map a) {
  final title = (a['title'] ?? '').toString().trim();
  final body = (a['body'] ?? '').toString();
  final showTitle = title.isNotEmpty && title != '公告' && title != '📢 公告';
  final urls = RegExp(r'https?://[^\s\u4e00-\u9fa5]+')
      .allMatches(body)
      .map((m) => m.group(0)!)
      .toSet()
      .toList();
  final date = (a['date'] ?? '').toString();
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.only(bottom: 14),
    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: T.line, width: 0.5))),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Text(title, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: T.tx)),
          const SizedBox(height: 6),
        ],
        if (date.isNotEmpty) ...[
          Text(date, style: TextStyle(fontSize: 11, color: T.tx3)),
          const SizedBox(height: 8),
        ],
        SelectableText(body, style: TextStyle(fontSize: 13.5, height: 1.75, color: T.tx2)),
        if (urls.isNotEmpty) ...[
          const SizedBox(height: 10),
          for (final u in urls)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: GestureDetector(
                onTap: () => launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: T.ac.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.open_in_new, size: 13, color: T.ac),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(u,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: T.ac)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ],
    ),
  );
}
