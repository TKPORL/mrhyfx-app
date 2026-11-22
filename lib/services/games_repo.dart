import '../models/game.dart';
import 'api.dart';

/// 全应用共用的游戏列表：只下载一次，页面之间复用
class GamesRepo {
  static List<Game> _all = [];
  static bool _loading = false;
  static DateTime? _loadedAt;

  static List<Game> get all => _all;
  static bool get isEmpty => _all.isEmpty;
  static DateTime? get loadedAt => _loadedAt;

  static Future<List<Game>> load({bool force = false}) async {
    if (!force && _all.isNotEmpty) return _all;
    if (_loading) {
      while (_loading) {
        await Future.delayed(const Duration(milliseconds: 120));
      }
      return _all;
    }
    _loading = true;
    try {
      final data = await Api.cachedRawJson(Api.repo, 'app-games.json', force: force);
      final list = Game.listFrom(data);
      if (list.isNotEmpty) {
        _all = list;
        _loadedAt = DateTime.now();
      }
    } finally {
      _loading = false;
    }
    return _all;
  }

  static Game? byId(int id) {
    for (final g in _all) {
      if (g.id == id) return g;
    }
    return null;
  }
}
