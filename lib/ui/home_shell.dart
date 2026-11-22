import 'package:flutter/material.dart';
import 'library_page.dart';
import '../services/store.dart';
import 'me_page.dart';
import 'theme.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _i = 0;
  Set<int> _favs = {};

  @override
  void initState() {
    super.initState();
    Store.favs().then((v) => setState(() => _favs = v));
  }

  Future<void> reloadFavs() async {
    final v = await Store.favs();
    setState(() => _favs = v);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      LibraryPage(favs: _favs, onFavChanged: reloadFavs),
      LibraryPage(favs: _favs, onFavChanged: reloadFavs, onlyFav: true),
      MePage(),
    ];
    return Scaffold(
      backgroundColor: T.bg,
      extendBody: true,
      body: IndexedStack(index: _i, children: pages),
      bottomNavigationBar: _PillNav(index: _i, onTap: (i) => setState(() => _i = i)),
    );
  }
}

class _PillNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _PillNav({required this.index, required this.onTap});

  static final _items = [
    (Icons.grid_view_rounded, '游戏库'),
    (Icons.favorite_rounded, '收藏'),
    (Icons.person_rounded, '我的'),
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final itemW = 78.0;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: 14),
        child: Center(
          heightFactor: 1,
          child: Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: T.glass.withOpacity(0.94),
              borderRadius: BorderRadius.circular(27),
              border: Border.all(color: T.line, width: 0.5),
              boxShadow: [BoxShadow(color: Color(0x99000000), blurRadius: 26, offset: Offset(0, 10))],
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: Duration(milliseconds: 320),
                  curve: Curves.easeOutBack,
                  left: index * itemW,
                  top: 0,
                  bottom: 0,
                  width: itemW,
                  child: Container(
                    decoration: BoxDecoration(
                      color: T.light ? Colors.black.withOpacity(0.06) : Colors.white.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: T.light ? Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.06), width: 0.5),
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_items.length, (i) {
                    final on = i == index;
                    return SizedBox(
                      width: itemW,
                      height: 50,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () => onTap(i),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_items[i].$1, size: 21, color: on ? T.ac : T.tx3),
                            SizedBox(height: 2),
                            Text(_items[i].$2,
                                style: TextStyle(fontSize: 10, color: on ? T.ac : T.tx3)),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
