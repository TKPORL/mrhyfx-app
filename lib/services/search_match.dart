/// 搜索容错：归一化（空格/全角/标点/罗马数字/中文数字）+ 变体 + 子序列
class SearchMatch {
  static const _punct = '·・_-—－:：,，。.、!！?？"\'“”‘’（）()[]【】《》<>~～/\\|';

  static String norm(String s) {
    final buf = StringBuffer();
    final t = s.toLowerCase();
    for (var i = 0; i < t.length; i++) {
      final c = t.codeUnitAt(i);
      if (c >= 0xFF01 && c <= 0xFF5E) {
        buf.writeCharCode(c - 0xFEE0);
        continue;
      }
      if (c >= 0x2160 && c <= 0x216B) {
        buf.write(c - 0x215F); // Ⅰ-Ⅻ → 1-12
        continue;
      }
      final ch = t[i];
      if (ch.trim().isEmpty) continue;
      if (_punct.contains(ch)) continue;
      buf.write(ch);
    }
    return buf.toString();
  }

  static const _cn = {'零': 0, '一': 1, '二': 2, '两': 2, '三': 3, '四': 4, '五': 5, '六': 6, '七': 7, '八': 8, '九': 9};

  static String cnNum(String s) {
    final out = StringBuffer();
    var i = 0;
    while (i < s.length) {
      final ch = s[i];
      if (!_cn.containsKey(ch) && ch != '十') {
        out.write(ch);
        i++;
        continue;
      }
      var j = i;
      while (j < s.length && (_cn.containsKey(s[j]) || s[j] == '十')) {
        j++;
      }
      final seg = s.substring(i, j);
      final p10 = seg.indexOf('十');
      if (p10 >= 0) {
        final ten = p10 == 0 ? 1 : (_cn[seg[0]] ?? 0);
        final one = seg.length > p10 + 1 ? (_cn[seg[p10 + 1]] ?? 0) : 0;
        out.write(ten * 10 + one);
      } else {
        for (final c in seg.split('')) {
          out.write(_cn[c] ?? 0);
        }
      }
      i = j;
    }
    return out.toString();
  }

  static String romanTail(String s) {
    const map = {'viii': '8', 'vii': '7', 'iii': '3', 'iv': '4', 'vi': '6', 'ix': '9', 'ii': '2', 'xi': '11', 'x': '10', 'v': '5', 'i': '1'};
    for (final k in map.keys) {
      if (s.endsWith(k)) return s.substring(0, s.length - k.length) + map[k]!;
    }
    return s;
  }

  static List<String> variants(String q) {
    final b = norm(q);
    final out = <String>[b];
    final r = romanTail(b);
    if (r != b) out.add(r);
    final c = cnNum(b);
    if (c != b && !out.contains(c)) out.add(c);
    return out;
  }

  /// 0 精确 / 1 标题包含 / 2 其他字段包含 / 3 子序列 / 9 不匹配
  static int score(String title, String extra, List<String> vs) {
    final t0 = norm(title);
    final tv = <String>[t0];
    final rt = romanTail(t0);
    if (rt != t0) tv.add(rt);
    final ct = cnNum(t0);
    if (ct != t0) tv.add(ct);
    final e = norm(extra);

    for (final v in vs) {
      for (final t in tv) {
        if (t == v) return 0;
        if (t.contains(v)) return 1;
      }
      if (e.contains(v)) return 2;
    }
    for (final v in vs) {
      if (v.length < 3) continue;
      var pi = 0;
      for (var ti = 0; ti < t0.length && pi < v.length; ti++) {
        if (t0[ti] == v[pi]) pi++;
      }
      if (pi == v.length) return 3;
    }
    return 9;
  }
}
