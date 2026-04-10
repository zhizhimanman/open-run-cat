#!/usr/bin/env python3
"""
Claude Code螃蟹像素风关键帧动画生成器
真正的像素艺术风格 - 22x22像素
"""

from PIL import Image
import os
import json

# 颜色定义 - 像素艺术使用有限的颜色
# Claude橙红色系列 + 深色轮廓 + 高光
COLORS = {
    'transparent': (0, 0, 0, 0),
    'outline': (50, 50, 50, 255),        # 深色轮廓
    'main': (217, 119, 6, 255),          # Claude橙红 #D97706
    'light': (251, 146, 60, 255),        # 高光橙色 #FB923C
    'dark': (180, 83, 9, 255),           # 阴影橙色 #B45309
    'eye': (30, 30, 30, 255),            # 眼睛深色
}

SIZE = 22

def create_pixel_image():
    """创建22x22像素透明背景图片"""
    return Image.new('RGBA', (SIZE, SIZE), COLORS['transparent'])

def set_pixels(img, pixel_data):
    """根据像素坐标数据设置像素颜色"""
    pixels = img.load()
    for x, y, color_key in pixel_data:
        if 0 <= x < SIZE and 0 <= y < SIZE:
            pixels[x, y] = COLORS[color_key]

# ==================== 像素螃蟹基础形状 ====================

# 基础螃蟹像素数据 (正面视角, 坐标系统: 左上角为(0,0))
# 身体是椭圆蟹壳, 两侧有钳子, 下面有腿

BASE_CRAB_BODY = [
    # 身体顶部轮廓
    (8, 4, 'outline'), (9, 4, 'outline'), (10, 4, 'outline'), (11, 4, 'outline'), (12, 4, 'outline'), (13, 4, 'outline'),
    # 身体上部填充
    (7, 5, 'outline'), (8, 5, 'main'), (9, 5, 'light'), (10, 5, 'main'), (11, 5, 'main'), (12, 5, 'light'), (13, 5, 'main'), (14, 5, 'outline'),
    # 身体中部
    (6, 6, 'outline'), (7, 6, 'main'), (8, 6, 'main'), (9, 6, 'main'), (10, 6, 'main'), (11, 6, 'main'), (12, 6, 'main'), (13, 6, 'main'), (14, 6, 'main'), (15, 6, 'outline'),
    # 身体下部
    (7, 7, 'outline'), (8, 7, 'main'), (9, 7, 'dark'), (10, 7, 'main'), (11, 7, 'main'), (12, 7, 'dark'), (13, 7, 'main'), (14, 7, 'outline'),
    # 身体底部轮廓
    (8, 8, 'outline'), (9, 8, 'outline'), (10, 8, 'outline'), (11, 8, 'outline'), (12, 8, 'outline'), (13, 8, 'outline'),
]

# 眼睛像素 (两个小黑点在身体上方)
EYES_NORMAL = [
    (8, 3, 'eye'), (9, 3, 'eye'),
    (12, 3, 'eye'), (13, 3, 'eye'),
]

# 钳子像素 (左侧)
CLAW_LEFT_NORMAL = [
    # 钳臂
    (3, 6, 'outline'), (4, 6, 'main'), (5, 6, 'main'), (6, 6, 'main'),
    (3, 7, 'outline'), (4, 7, 'main'), (5, 7, 'dark'),
    # 钳尖
    (1, 5, 'outline'), (2, 5, 'main'), (3, 5, 'main'),
    (0, 4, 'outline'), (1, 4, 'main'),
]

# 钳子像素 (右侧)
CLAW_RIGHT_NORMAL = [
    # 钳臂
    (15, 6, 'main'), (16, 6, 'main'), (17, 6, 'main'), (18, 6, 'outline'),
    (15, 7, 'dark'), (16, 7, 'main'), (17, 7, 'outline'),
    # 钳尖
    (18, 5, 'main'), (19, 5, 'main'), (20, 5, 'outline'),
    (20, 4, 'main'), (21, 4, 'outline'),
]

# 钳子抬起状态 (左侧)
CLAW_LEFT_UP = [
    # 钳臂向上
    (3, 4, 'outline'), (4, 4, 'main'), (5, 4, 'main'), (6, 4, 'main'),
    (3, 5, 'outline'), (4, 5, 'main'), (5, 5, 'light'),
    # 钩尖更向上
    (1, 2, 'outline'), (2, 2, 'main'), (3, 2, 'main'),
    (0, 1, 'outline'), (1, 1, 'main'),
]

# 钳子抬起状态 (右侧)
CLAW_RIGHT_UP = [
    # 钩臂向上
    (15, 4, 'main'), (16, 4, 'main'), (17, 4, 'main'), (18, 4, 'outline'),
    (15, 5, 'light'), (16, 5, 'main'), (17, 5, 'outline'),
    # 钩尖更向上
    (18, 2, 'main'), (19, 2, 'main'), (20, 2, 'outline'),
    (20, 1, 'main'), (21, 1, 'outline'),
]

# 腿像素 (正常状态)
LEGS_NORMAL = [
    # 左侧腿
    (5, 9, 'outline'), (6, 9, 'main'),
    (4, 10, 'outline'), (5, 10, 'main'), (6, 10, 'main'),
    (5, 11, 'outline'), (6, 11, 'main'),
    # 右侧腿
    (15, 9, 'main'), (16, 9, 'outline'),
    (15, 10, 'main'), (16, 10, 'main'), (17, 10, 'outline'),
    (15, 11, 'main'), (16, 11, 'outline'),
]

# 腿像素 (左侧抬起)
LEGS_LEFT_UP = [
    # 左侧腿抬起
    (4, 8, 'outline'), (5, 8, 'main'), (6, 8, 'main'),
    (3, 9, 'outline'), (4, 9, 'main'),
    (4, 10, 'outline'), (5, 10, 'main'),
    # 右侧腿正常
    (15, 9, 'main'), (16, 9, 'outline'),
    (15, 10, 'main'), (16, 10, 'main'), (17, 10, 'outline'),
    (15, 11, 'main'), (16, 11, 'outline'),
]

# 腿像素 (右侧抬起)
LEGS_RIGHT_UP = [
    # 左侧腿正常
    (5, 9, 'outline'), (6, 9, 'main'),
    (4, 10, 'outline'), (5, 10, 'main'), (6, 10, 'main'),
    (5, 11, 'outline'), (6, 11, 'main'),
    # 右侧腿抬起
    (15, 8, 'main'), (16, 8, 'main'), (17, 8, 'outline'),
    (17, 9, 'outline'), (18, 9, 'main'),
    (15, 10, 'main'), (16, 10, 'outline'),
]


def draw_pixel_crab(claw_left='normal', claw_right='normal', legs='normal', body_offset_y=0):
    """
    绘制像素风螃蟹
    claw_left/right: 'normal' 或 'up'
    legs: 'normal', 'left_up', 'right_up'
    body_offset_y: 身体Y轴偏移
    """
    img = create_pixel_image()

    pixel_data = []

    # 添加身体像素 (带偏移)
    for x, y, color in BASE_CRAB_BODY:
        pixel_data.append((x, y + body_offset_y, color))

    # 添加眼睛像素
    for x, y, color in EYES_NORMAL:
        pixel_data.append((x, y + body_offset_y, color))

    # 添加左侧钳子
    if claw_left == 'up':
        for x, y, color in CLAW_LEFT_UP:
            pixel_data.append((x, y + body_offset_y, color))
    else:
        for x, y, color in CLAW_LEFT_NORMAL:
            pixel_data.append((x, y + body_offset_y, color))

    # 添加右侧钳子
    if claw_right == 'up':
        for x, y, color in CLAW_RIGHT_UP:
            pixel_data.append((x, y + body_offset_y, color))
    else:
        for x, y, color in CLAW_RIGHT_NORMAL:
            pixel_data.append((x, y + body_offset_y, color))

    # 添加腿部
    if legs == 'left_up':
        pixel_data.extend(LEGS_LEFT_UP)
    elif legs == 'right_up':
        pixel_data.extend(LEGS_RIGHT_UP)
    else:
        pixel_data.extend(LEGS_NORMAL)

    # 应用偏移到腿
    final_data = []
    for x, y, color in pixel_data:
        # 腿不受body_offset影响,保持在地面上
        if (x, y, color) in LEGS_NORMAL or (x, y, color) in LEGS_LEFT_UP or (x, y, color) in LEGS_RIGHT_UP:
            final_data.append((x, y, color))
        else:
            final_data.append((x, y, color))

    set_pixels(img, final_data)
    return img


# ==================== 动画生成 ====================

def generate_side_run_frames():
    """横行跑动动画 - 螃蟹横向移动"""
    frames = []

    # 8帧循环: 右腿抬起 -> 右腿前移 -> 右腿落地 -> 左腿抬起 -> 左腿前移 -> 左腿落地 -> 过渡
    states = [
        ('normal', 'normal', 'normal', 0),      # 0: 起始
        ('normal', 'up', 'right_up', 0),        # 1: 右钳右腿抬起
        ('normal', 'up', 'right_up', 1),        # 2: 右侧前移
        ('normal', 'normal', 'normal', 2),      # 3: 右侧落地
        ('up', 'normal', 'left_up', 2),         # 4: 左钳左腿抬起
        ('up', 'normal', 'left_up', 3),         # 5: 左侧前移
        ('normal', 'normal', 'normal', 4),      # 6: 左侧落地
        ('normal', 'normal', 'normal', 2),      # 7: 过渡回中间
    ]

    for claw_left, claw_right, legs, offset_x in states:
        # 注意: 横行跑动不改变body_offset_y,只改变腿的状态
        img = draw_pixel_crab(claw_left, claw_right, legs, 0)
        frames.append(img)

    return frames


def generate_bounce_hop_frames():
    """弹跳小跑动画 - 上下弹跳"""
    frames = []

    # 8帧循环: 弹跳高度曲线
    bounce_data = [
        ('normal', 'normal', 'normal', 0),   # 0: 落地准备
        ('normal', 'normal', 'normal', -1),  # 1: 开始上升
        ('up', 'up', 'normal', -2),          # 2: 继续上升,钳子张开
        ('up', 'up', 'normal', -3),          # 3: 最高点
        ('up', 'up', 'normal', -2),          # 4: 开始下落
        ('normal', 'normal', 'normal', -1),  # 5: 继续下落
        ('normal', 'normal', 'normal', 0),   # 6: 落地
        ('normal', 'normal', 'normal', 1),   # 7: 压缩(身体略向下)
    ]

    for claw_left, claw_right, legs, offset_y in bounce_data:
        img = draw_pixel_crab(claw_left, claw_right, legs, offset_y)
        frames.append(img)

    return frames


def generate_claw_wave_frames():
    """原地摆动蟹钳动画"""
    frames = []

    # 8帧循环: 左钳抬起 -> 挥动 -> 落下 -> 右钳抬起 -> 挥动 -> 落下
    states = [
        ('normal', 'normal', 'normal', 0),   # 0: 静止
        ('normal', 'up', 'normal', 0),       # 1: 右钳抬起
        ('normal', 'up', 'normal', -1),      # 2: 右钳挥动,身体略左倾
        ('normal', 'normal', 'normal', 0),   # 3: 右钳落下
        ('up', 'normal', 'normal', 0),       # 4: 左钳抬起
        ('up', 'normal', 'normal', 1),       # 5: 左钳挥动,身体略右倾
        ('normal', 'normal', 'normal', 0),   # 6: 左钳落下
        ('normal', 'normal', 'normal', 0),   # 7: 短暂静止
    ]

    for claw_left, claw_right, legs, offset_y in states:
        img = draw_pixel_crab(claw_left, claw_right, legs, offset_y)
        frames.append(img)

    return frames


def save_frames(frames, output_dir, animation_name):
    """保存帧序列"""
    for i, frame in enumerate(frames):
        filename = f"frame_{i:02d}.png"
        filepath = os.path.join(output_dir, filename)
        frame.save(filepath)
        print(f"Saved: {filepath}")

    # manifest.json
    manifest = {
        "name": animation_name,
        "frameCount": len(frames),
        "author": "Claude Code Pixel Generator",
        "version": "2.0",
        "style": "pixel-art"
    }
    manifest_path = os.path.join(output_dir, "manifest.json")
    with open(manifest_path, 'w') as f:
        json.dump(manifest, f, indent=2)
    print(f"Saved: {manifest_path}")


def main():
    base_dir = "/Users/dengzhixiang/code/open-run-cat/frame-animation"

    print("=" * 50)
    print("生成像素风Claude螃蟹关键帧动画")
    print("=" * 50)

    # 清空旧文件并重新生成
    for subdir in ["side-run", "bounce-hop", "claw-wave"]:
        subdir_path = os.path.join(base_dir, subdir)
        # 清空目录
        for f in os.listdir(subdir_path):
            os.remove(os.path.join(subdir_path, f))

    # 动画1: 横行跑动
    print("\n[1/3] 生成横行跑动动画...")
    frames = generate_side_run_frames()
    save_frames(frames, os.path.join(base_dir, "side-run"), "Claude Crab Pixel - Side Run")

    # 动画2: 弹跳小跑
    print("\n[2/3] 生成弹跳小跑动画...")
    frames = generate_bounce_hop_frames()
    save_frames(frames, os.path.join(base_dir, "bounce-hop"), "Claude Crab Pixel - Bounce Hop")

    # 动画3: 原地摆动
    print("\n[3/3] 生成原地摆动动画...")
    frames = generate_claw_wave_frames()
    save_frames(frames, os.path.join(base_dir, "claw-wave"), "Claude Crab Pixel - Claw Wave")

    print("\n" + "=" * 50)
    print("完成! 像素风动画共24帧")
    print("=" * 50)


if __name__ == "__main__":
    main()