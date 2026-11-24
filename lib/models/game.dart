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
  final List<String> shots;
  final String page;
  final String source;
  final int qztRank;
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
    this.shots = const [],
    this.page = '',
    this.source = 'post',
    this.qztRank = 0,
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
        shots: ((j['shots'] as List?) ?? const []).map((e) => e.toString()).toList(),
        page: (j['page'] ?? '').toString(),
        source: (j['source'] ?? 'post').toString(),
        qztRank: (j['qztRank'] is num) ? (j['qztRank'] as num).toInt() : 0,
        date: (j['date'] ?? '').toString(),
      );

  /// 详情分片回填（列表接口不再带长文本）
  Game withDetail(Map d) => Game(
        id: id,
        title: title,
        cover: cover,
        platform: platform,
        size: size,
        tags: tags,
        intro: (d['intro'] ?? intro).toString(),
        linkPc: (d['linkPc'] ?? '').toString(),
        linkMobile: (d['linkMobile'] ?? '').toString(),
        code: (d['code'] ?? code).toString(),
        shots: ((d['shots'] as List?) ?? const []).map((e) => e.toString()).toList(),
        page: page,
        source: source,
        qztRank: qztRank,
        date: date,
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
