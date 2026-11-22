import '../models/game.dart';
import 'api.dart';
import 'store.dart';

/// 全应用共用的游戏列表。
/// 启动时只拉几百字节的 app-version.json，内容变了才下载完整清单（约 8MB，磁盘缓存）。
class GamesRepo {
  static List<Game> _all = [];
  static bool _loading = false;
  static String? _error;

  static List<Game> get all => _all;
  static bool get isEmpty => _all.isEmpty;
  static String? get error => _error;

  static Future<List<Game>> load({bool force = false}) async {
    if (!force && _all.isNotEmpty) return _all;
    if (_loading) {
      while (_loading) {
        await Future.delayed(const Duration(milliseconds: 120));
      }
      return _all;
    }
    _loading = true;
    _error = null;
    try {
      // 1) 先问线上：数据有没有变
      final ver = await Api.json(Api.repo, 'app-version.json');
      final remote = ver == null ? null : '${ver['updated']}|${ver['count']}';
      final local = await Store.stamp();
      final changed = remote != null && remote != local;

      // 2) 决定要不要重新下载
      var data = await Api.cachedRawJson(Api.repo, 'app-games.json',
          force: force || changed, ttl: const Duration(days: 30));
      if (data == null && _all.isNotEmpty) return _all;

      final list = Game.listFrom(data);
      if (list.isNotEmpty) {
        _all = list;
        if (remote != null) await Store.setStamp(remote);
      } else if (_all.isEmpty) {
        _error = '没有拿到数据，检查网络后重试';
      }
    } catch (e) {
      _error = '加载失败：$e';
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
