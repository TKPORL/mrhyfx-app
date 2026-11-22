# Tsinho 游戏库 · Android

Flutter 客户端。数据来自站点仓库自动生成的 `app-games.json`，
公告/版本/群链接来自本仓库的 `announcements.json` / `version.json` / `app-links.json`。

## 出包
推送到 main 后，GitHub Actions 会自动构建，产物在 Actions 页面的 Artifacts 里（`app-release.apk`）。
本地开发：`flutter pub get && flutter run`。

## 外观
支持 深色 / 浅色 / 跟随系统，入口在「我的 → 外观」。
颜色集中在 `lib/ui/theme.dart` 的 `T`，通过 `T.light` 切换；**新增控件请用 `T.xxx`，不要写死颜色**，否则浅色模式下会看不见。

## 应用图标
源图 `assets/app_icon.png`（1024×1024），由 CI 里的 `flutter_launcher_icons` 生成各密度 mipmap（`android/` 不入库，所以不能在本地生成后提交）。
换图标 = 替换源图后推送。

## 详情页画幅（定稿）
统一 **3:4**（`AspectRatio(3/4)` + `BoxFit.cover`）：所有游戏封面同一比例、填满裁切，图片从状态栏下方开始。
这是站长 2026-11-23 确认的方案，别再改成 contain/原比例（会破坏列表整齐度）。
