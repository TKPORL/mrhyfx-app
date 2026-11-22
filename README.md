# Tsinho 游戏库 · Android

Flutter 客户端。数据来自站点仓库自动生成的 `app-games.json`，
公告/版本/群链接来自本仓库的 `announcements.json` / `version.json` / `app-links.json`。

## 出包
推送到 main 后，GitHub Actions 会自动构建，产物在 Actions 页面的 Artifacts 里（`app-release.apk`）。
本地开发：`flutter pub get && flutter run`。

## 外观
支持 深色 / 浅色 / 跟随系统，入口在「我的 → 外观」。
颜色集中在 `lib/ui/theme.dart` 的 `T`，通过 `T.light` 切换；**新增控件请用 `T.xxx`，不要写死颜色**，否则浅色模式下会看不见。
