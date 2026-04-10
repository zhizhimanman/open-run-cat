# OpenRunCat

macOS 菜单栏跑步动画应用 - Runcat 的开源实现

## 功能

- 菜单栏动画角色，速度随系统负载变化
- 实时显示 CPU、内存、磁盘、网络指标
- 支持自定义角色（PNG 序列帧）
- Light/Dark/System 主题支持
- FPS 限制配置
- 开机启动

## 构建

需要 macOS 12.0+ 和 Xcode 14+

```
xcodebuild -scheme OpenRunCat build
```

## 自定义角色

将角色包放入 `~/Library/Application Support/OpenRunCat/Runners/`

角色包结构：
```
MyRunner/
├── frame_00.png
├── frame_01.png
├── ...
```

建议帧数: 5-12帧，尺寸: 16x16 或 22x22

## License

MIT