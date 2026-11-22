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

  static List<Game> listFrom(dynamic data) {
    final items = (data is Map && data['games'] is List) ? data['games'] as List : (data is List ? data : const []);
    return items.whereType<Map>().map((e) => Game.fromJson(e.cast<String, dynamic>())).toList();
  }
}
