class Game {
  final int id;
  final String title;
  final String cover;
  final String platform;
  final String size;
  final List<String> tags;
  final String intro;
  final String linkPc;
  final String linkMobile;
  final String code;
  final String date;

  const Game({
    required this.id,
    required this.title,
    required this.cover,
    this.platform = '',
    this.size = '',
    this.tags = const [],
    this.intro = '',
    this.linkPc = '',
    this.linkMobile = '',
    this.code = '',
    this.date = '',
  });

  factory Game.fromJson(Map<String, dynamic> j) => Game(
        id: (j['id'] is num) ? (j['id'] as num).toInt() : int.tryParse('${j['id']}') ?? 0,
        title: (j['title'] ?? '').toString(),
        cover: (j['cover'] ?? '').toString(),
        platform: (j['platform'] ?? '').toString(),
        size: (j['size'] ?? '').toString(),
        tags: ((j['tags'] as List?) ?? const []).map((e) => e.toString()).toList(),
        intro: (j['intro'] ?? '').toString(),
        linkPc: (j['linkPc'] ?? '').toString(),
        linkMobile: (j['linkMobile'] ?? '').toString(),
        code: (j['code'] ?? '').toString(),
        date: (j['date'] ?? '').toString(),
      );

  /// 体积：数据里没有就从简介里再抓一次
  String get sizeDisplay {
    if (size.isNotEmpty) return size;
    final m = RegExp(r'(\d+(?:\.\d+)?)\s*([GMT])B?(?![A-Za-z])', caseSensitive: false).firstMatch(intro);
    return m == null ? '—' : '${m.group(1)}${m.group(2)!.toUpperCase()}';
  }

  /// 类型：先用标签里的第一个非平台项，抓不到再从简介里的 【SLG/欧美…】 取英文缩写
  String get typeDisplay {
    for (final t in tags) {
      if (t == platform) continue;
      if (RegExp(r'^(PC|安卓|手机|双端)').hasMatch(t)) continue;
      return t;
    }
    final m = RegExp(r'【([A-Za-z]{2,5})\s*[/／]').firstMatch(intro);
    if (m != null) return m.group(1)!.toUpperCase();
    return '—';
  }

  static List<Game> listFrom(dynamic data) {
    final items = (data is Map && data['games'] is List) ? data['games'] as List : (data is List ? data : const []);
    return items.whereType<Map>().map((e) => Game.fromJson(e.cast<String, dynamic>())).toList();
  }
}
