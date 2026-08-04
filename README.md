# nia — nophenia 安卓移植

**nophenia**（v1.01，"a small dream explorer"，作者 lane (emiwa)）的 **Android 移植**工程。

> 原始 Windows 版游戏数据来自 `nia` 仓库 GitHub Release（`nop-v1.0` / `nop.zip`），通过 GDRE 恢复为完整 Godot 4.7 工程，再补充 Android 导出支持。

## 移植说明

- 引擎：**Godot 4.7.0**（GL Compatibility 渲染，Jolt Physics 内置）
- 分辨率：640×480 横屏（支持拉伸/宽屏）
- 目标：Android 手机/平板（arm64-v8a，Android 8.0+ / API 26+）
- 包名：`com.nophenia.game`

### 相对原版的改动（尽量原样，仅补充 Android 支持）

| 项 | 说明 |
|---|---|
| 移除 Steam | 删除 GodotSteam 插件与 `[steam]` 配置；`global_game.gd` 中 `steam_api.triggerScreenshot()` 增加判空；截图目录打开在 Android 上跳过 |
| 虚拟触控层 | 新增 `gdscript/ui/touch_controls.gd`（autoload `TouchControls`），通过模拟现有输入动作（`left/right/up/down`、`look_*`、`jump/interact/run/sit/howl/menu`）驱动游戏，不改动 `player.gd` 逻辑；仅移动端启用，桌面/手柄不受影响 |
| Android 导出 | `export_presets.cfg`：横屏、沉浸式全屏、屏幕常亮、arm64-v8a |
| 保留 | 原版全部玩法/场景/资源/多人模组目录结构，未改动游戏逻辑 |

### 操作方式（触屏）

- 左半屏：虚拟摇杆控制移动
- 右半屏：拖动控制视角
- 右侧按钮：J(跳) / E(交互) / RUN(跑) / SIT(坐) / HOWL(嚎叫) / MENU(菜单)
- 标题/开始界面：屏幕下方 "TAP TO START"
- 支持蓝牙手柄（原版手柄映射）

## 构建（CI）

推送到 `main` 或打 `v*` tag 自动触发 [GitHub Actions](.github/workflows/build-android.yml)：

1. 安装 Godot 4.7.0 + 导出模板 + Android SDK
2. 生成签名 keystore
3. 导出 debug/release APK
4. 上传构建产物，tag 或手动触发时发布到 Releases

手动触发：仓库 Actions → *Build Android APK* → *Run workflow*。

## 本地构建

需要：Godot 4.7.0（含 Android 导出模板）、JDK 17、Android SDK（platform-tools、build-tools）。

```bash
godot --headless --path . --import
godot --headless --path . --export-release "Android" build/nophenia-android.apk
```

## 版权

游戏版权归原作者 lane (emiwa) 所有。本工程仅用于原样移植研究。
