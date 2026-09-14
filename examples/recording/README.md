# 本案例的 Godot 录制与检查

**简体中文** | [English](README.en.md)

本目录记录展示页媒体的制作方法。录像来自 Godot 4.6 的真实场景与角色控制器，使用脚本调用 `Input.action_press()` / `Input.action_release()` 模拟操作，再通过 Movie Maker 输出；按标题切换展示片段时重置角色位置。

- `record_github_showcase.gd`：逐一展示 8 个方向 × 5 种动作，再演示走／跑接翻滚、跳跃的 4 种组合。
- `capture_github_gallery.gd`：用相同角色与着色器渲染八方向 GIF 所需帧，保留当前版本的头部稳定与待机呼吸。
- `verification.json`：录像媒体参数、40 组覆盖记录、移动衔接使用的源姿势、GIF 帧数、原图 SHA-256 与章节时间。

这些脚本是**本案例工程的录制示例**，依赖 `scenes/main.tscn`、`scenes/player.tscn` 和工程中的角色／精灵接口；完整角色工程与模型未放入 Skill 仓库。其他工程需要按实际节点和输入动作适配。

## 录制同结构工程

将两个 `.gd` 文件放入对应 Godot 工程的 `tests/` 目录，替换下方的 `<project>`，使用支持图形渲染的环境执行：

```sh
godot --path <project> --fixed-fps 30 --write-movie ../ShowcaseRecording/godot-showcase.avi --script tests/record_github_showcase.gd
godot --path <project> --script tests/capture_github_gallery.gd
```

提前创建与工程并列的 `ShowcaseRecording` 目录。让脚本正常退出以完成 AVI 封装。具体视频分辨率由实际渲染窗口决定；本次成片为 **1152 × 720，30 FPS，3154 帧，105.13 秒**。

转为网页播放的 MP4：

```sh
ffmpeg -i godot-showcase.avi -c:v libx264 -preset medium -crf 20 -pix_fmt yuv420p -movflags +faststart -an godot-eight-directions.mp4
```

将每种动作的 PNG 序列转成 GIF，例如 idle：

```sh
ffmpeg -framerate 30 -i gallery/idle/%03d.png -filter_complex "[0:v]split[a][b];[a]palettegen=stats_mode=diff[p];[b][p]paletteuse=dither=sierra2_4a:diff_mode=rectangle" -loop 0 idle-8-directions.gif
```

GIF 使用百分之一秒计时，30 FPS 会以 30/40 ms 的帧延时近似；本案例保持整个动作周期的时长。GIF 自带观看背景，正式素材使用透明 PNG 和图集。

## 本次检查范围

1. 40 组动作与方向均有实际运行帧；走、跑、翻滚和跳跃覆盖全部 12 个源姿势。
2. 各方向待机均覆盖一个呼吸周期，胸口变形参数约 0–2.4 像素。
3. 走／跑接翻滚使用源姿势 2–8，接跳跃使用 3–8（从 0 编号），并回到对应移动状态。
4. 检查录制日志、录像截帧、八方向预览，验证 GIF 帧数与时长、MP4 编码和完整帧数。
5. 用户提供的 GPT 原图按原文件上传，SHA-256 写入检查记录。

数值与覆盖检查用于辅助视觉复检，不代表可以自动证明每一帧的美术效果。本站展示的是最终 Godot 渲染效果，其中待机呼吸和头部稳定包含运行时着色器修正。

参考：[Godot 官方 Movie Maker 文档](https://docs.godotengine.org/en/4.6/tutorials/animation/creating_movies.html)。
