#!/usr/bin/env python3
"""
Claude Code CLI螃蟹像素动画生成器
基于真实logo形状 - 极简像素风格
"""

from PIL import Image
import os
import json

# 颜色定义
COLORS = {
    'transparent': (0, 0, 0, 0),
    'body': (214, 124, 90, 255),      # #D67C5A 螃蟹身体色
    'eye': (17, 17, 17, 255),         # #111111 眼睛黑色
}

SIZE = 22

def create_pixel_image():
    """创建22x22透明背景图片"""
    return Image.new('RGBA', (SIZE, SIZE), COLORS['transparent'])

def set_pixels(img, pixel_data):
    """设置像素"""
    pixels = img.load()
    for x, y, color_key in pixel_data:
        if 0 <= x < SIZE and 0 <= y < SIZE:
            pixels[x, y] = COLORS[color_key]

def draw_crab_base(offset_y=0, claw_left_offset=0, claw_right_offset=0, leg_offset=0):
    """
    绘制基础螃蟹形状
    原始logo是100x100，我们缩放到22x22大约是0.22倍
    """
    pixels = []

    # 身体 - 大矩形 (原15-85 x, 20-65 y -> 缩放后)
    # 中心化处理: 身体宽度约 70*0.22 ≈ 15, 高度 45*0.22 ≈ 10
    body_left = 3
    body_right = 18
    body_top = 4 + offset_y
    body_bottom = 13 + offset_y

    for x in range(body_left, body_right + 1):
        for y in range(body_top, body_bottom + 1):
            pixels.append((x, y, 'body'))

    # 眼睛 - 两个黑色小矩形
    # 原位置: 左35-41, 右59-65, y30-42
    # 缩放后大约: 左眼在x=7-8, 右眼在x=13-14, y=5-7
    eye_width = 2
    eye_height = 4

    # 左眼
    left_eye_x = 7
    left_eye_y = 5 + offset_y
    for x in range(left_eye_x, left_eye_x + eye_width):
        for y in range(left_eye_y, left_eye_y + eye_height):
            pixels.append((x, y, 'eye'))

    # 右眼
    right_eye_x = 13
    right_eye_y = 5 + offset_y
    for x in range(right_eye_x, right_eye_x + eye_width):
        for y in range(right_eye_y, right_eye_y + eye_height):
            pixels.append((x, y, 'eye'))

    # 钳子 - 两侧小方块
    # 原位置: 左5-15 x, 35-45 y -> 缩放后
    claw_size = 2

    # 左钳子
    left_claw_x = 1 + claw_left_offset
    left_claw_y = 8 + offset_y
    for x in range(left_claw_x, left_claw_x + claw_size):
        for y in range(left_claw_y, left_claw_y + claw_size):
            pixels.append((x, y, 'body'))

    # 右钳子
    right_claw_x = 19 + claw_right_offset
    right_claw_y = 8 + offset_y
    for x in range(right_claw_x, right_claw_x + claw_size):
        for y in range(right_claw_y, right_claw_y + claw_size):
            pixels.append((x, y, 'body'))

    # 腿 - 4条小矩形
    # 原位置: 左25-31, 37-43, 右57-63, 69-75, y70-80
    # 缩放后: 每条腿宽度约1-2像素
    leg_width = 1
    leg_height = 3

    # 左边两条腿
    leg1_x = 5 + leg_offset
    leg1_y = 14
    for x in range(leg1_x, leg1_x + leg_width):
        for y in range(leg1_y, leg1_y + leg_height):
            pixels.append((x, y, 'body'))

    leg2_x = 8 + leg_offset
    leg2_y = 14
    for x in range(leg2_x, leg2_x + leg_width):
        for y in range(leg2_y, leg2_y + leg_height):
            pixels.append((x, y, 'body'))

    # 右边两条腿
    leg3_x = 13 - leg_offset
    leg3_y = 14
    for x in range(leg3_x, leg3_x + leg_width):
        for y in range(leg3_y, leg3_y + leg_height):
            pixels.append((x, y, 'body'))

    leg4_x = 16 - leg_offset
    leg4_y = 14
    for x in range(leg4_x, leg4_x + leg_width):
        for y in range(leg4_y, leg4_y + leg_height):
            pixels.append((x, y, 'body'))

    return pixels


# ==================== 动画生成 ====================

def generate_side_run_frames():
    """横行跑动动画 - 腿交替移动"""
    frames = []

    for i in range(8):
        img = create_pixel_image()

        # 根据帧决定腿和钳子的偏移
        if i in [0, 3, 6, 7]:  # 静止帧
            pixels = draw_crab_base(offset_y=0, claw_left_offset=0, claw_right_offset=0, leg_offset=0)
        elif i in [1, 2]:  # 右腿向前
            pixels = draw_crab_base(offset_y=0, claw_left_offset=0, claw_right_offset=-1, leg_offset=1)
        elif i in [4, 5]:  # 左腿向前
            pixels = draw_crab_base(offset_y=0, claw_left_offset=1, claw_right_offset=0, leg_offset=-1)

        set_pixels(img, pixels)
        frames.append(img)

    return frames


def generate_bounce_hop_frames():
    """弹跳小跑动画"""
    frames = []

    # 弹跳高度曲线
    bounce_y = [0, -1, -2, -3, -2, -1, 0, 1]  # 1是压缩

    for i in range(8):
        img = create_pixel_image()
        offset_y = bounce_y[i]

        # 弹跳时钳子略微张开（向外移动）
        claw_offset = 0 if bounce_y[i] >= 0 else -1

        pixels = draw_crab_base(offset_y=offset_y, claw_left_offset=claw_offset, claw_right_offset=-claw_offset)
        set_pixels(img, pixels)
        frames.append(img)

    return frames


def generate_claw_wave_frames():
    """原地摆动钳子动画"""
    frames = []

    claw_states = [
        (0, 0),      # F0: 静止
        (0, -1),     # F1: 右钳抬起
        (0, -2),     # F2: 右钳挥动
        (0, -1),     # F3: 右钳落下
        (-1, 0),     # F4: 左钳抬起
        (-2, 0),     # F5: 左钳挥动
        (-1, 0),     # F6: 左钳落下
        (0, 0),      # F7: 静止
    ]

    # 身体轻微晃动
    body_offsets = [0, 0, -1, 0, 0, 1, 0, 0]

    for i in range(8):
        img = create_pixel_image()
        left_offset, right_offset = claw_states[i]
        pixels = draw_crab_base(offset_y=body_offsets[i], claw_left_offset=left_offset, claw_right_offset=right_offset)
        set_pixels(img, pixels)
        frames.append(img)

    return frames


def save_frames(frames, output_dir, animation_name):
    """保存帧序列"""
    for i, frame in enumerate(frames):
        filename = f"frame_{i:02d}.png"
        filepath = os.path.join(output_dir, filename)
        frame.save(filepath)
        print(f"Saved: {filepath}")

    manifest = {
        "name": animation_name,
        "frameCount": len(frames),
        "author": "Claude Code Logo Style",
        "version": "3.0",
        "style": "pixel-art",
        "color": "#D67C5A"
    }
    manifest_path = os.path.join(output_dir, "manifest.json")
    with open(manifest_path, 'w') as f:
        json.dump(manifest, f, indent=2)
    print(f"Saved: {manifest_path}")


def main():
    base_dir = "/Users/dengzhixiang/code/open-run-cat/frame-animation"

    # 清空旧文件
    for subdir in ["side-run", "bounce-hop", "claw-wave"]:
        subdir_path = os.path.join(base_dir, subdir)
        for f in os.listdir(subdir_path):
            os.remove(os.path.join(subdir_path, f))

    print("=" * 50)
    print("生成Claude Code Logo风格螃蟹动画")
    print("颜色: #D67C5A")
    print("=" * 50)

    print("\n[1/3] 横行跑动...")
    frames = generate_side_run_frames()
    save_frames(frames, os.path.join(base_dir, "side-run"), "Claude Code Crab - Side Run")

    print("\n[2/3] 弹跳小跑...")
    frames = generate_bounce_hop_frames()
    save_frames(frames, os.path.join(base_dir, "bounce-hop"), "Claude Code Crab - Bounce Hop")

    print("\n[3/3] 原地摆动...")
    frames = generate_claw_wave_frames()
    save_frames(frames, os.path.join(base_dir, "claw-wave"), "Claude Code Crab - Claw Wave")

    print("\n完成! 共24帧")


if __name__ == "__main__":
    main()