#!/usr/bin/env python3
"""
Claude Code螃蟹关键帧动画生成器
生成三种动画类型各8帧的22x22像素PNG图片
"""

from PIL import Image, ImageDraw
import os

# 颜色定义 - Claude橙红色 + 深色轮廓(自适应主题)
FILL_COLOR = (217, 119, 6)    # Claude橙红色 #D97706
OUTLINE_COLOR = (60, 60, 60)   # 深灰轮廓，确保在Light/Dark背景可见
TRANSPARENT = (0, 0, 0, 0)

SIZE = 22

def create_base_image():
    """创建透明背景的22x22图片"""
    return Image.new('RGBA', (SIZE, SIZE), TRANSPARENT)

def draw_crab_body(draw, center_x, center_y, scale=1.0):
    """绘制螃蟹身体（椭圆蟹壳）"""
    # 身体椭圆
    body_width = int(10 * scale)
    body_height = int(7 * scale)
    body_coords = [
        center_x - body_width//2, center_y - body_height//2,
        center_x + body_width//2, center_y + body_height//2
    ]
    draw.ellipse(body_coords, fill=FILL_COLOR, outline=OUTLINE_COLOR)

def draw_crab_claw(draw, claw_x, claw_y, angle=0, size='normal', side='left'):
    """绘制蟹钳"""
    # 蟹钳由两部分组成：钳臂和钳尖
    claw_scale = 1.0 if size == 'normal' else (1.2 if size == 'large' else 0.8)

    # 钳臂 (矩形)
    arm_width = int(3 * claw_scale)
    arm_height = int(4 * claw_scale)

    if side == 'left':
        arm_coords = [claw_x - arm_width, claw_y, claw_x, claw_y + arm_height]
    else:
        arm_coords = [claw_x, claw_y, claw_x + arm_width, claw_y + arm_height]

    draw.rectangle(arm_coords, fill=FILL_COLOR, outline=OUTLINE_COLOR)

    # 钳尖 (小椭圆)
    tip_x = claw_x if side == 'left' else claw_x + arm_width
    tip_coords = [tip_x - 2, claw_y - 1, tip_x + 2, claw_y + 2]
    draw.ellipse(tip_coords, fill=FILL_COLOR, outline=OUTLINE_COLOR)

def draw_crab_legs(draw, body_center_x, body_center_y, leg_state='down'):
    """绘制腿部 - 4条简化腿"""
    # 腿从身体两侧延伸
    leg_y_positions = [body_center_y - 2, body_center_y, body_center_y + 2]

    for i, y in enumerate(leg_y_positions):
        # 左腿
        leg_left_x = body_center_x - 6
        # 右腿
        leg_right_x = body_center_x + 6

        # 根据leg_state调整腿的位置
        if leg_state == 'left_up':
            # 左腿抬起
            draw.line([(leg_left_x, y), (leg_left_x - 3, y - 2)], fill=OUTLINE_COLOR, width=1)
            draw.line([(leg_right_x, y), (leg_right_x + 3, y)], fill=OUTLINE_COLOR, width=1)
        elif leg_state == 'right_up':
            # 右腿抬起
            draw.line([(leg_left_x, y), (leg_left_x - 3, y)], fill=OUTLINE_COLOR, width=1)
            draw.line([(leg_right_x, y), (leg_right_x + 3, y - 2)], fill=OUTLINE_COLOR, width=1)
        else:
            # 所有腿着地
            draw.line([(leg_left_x, y), (leg_left_x - 3, y)], fill=OUTLINE_COLOR, width=1)
            draw.line([(leg_right_x, y), (leg_right_x + 3, y)], fill=OUTLINE_COLOR, width=1)

def draw_crab_eye(draw, eye_x, eye_y):
    """绘制眼睛 - 小圆点"""
    draw.ellipse([eye_x - 1, eye_y - 1, eye_x + 1, eye_y + 1], fill=OUTLINE_COLOR)

def draw_full_crab(draw, center_x, center_y, claw_state='normal', leg_state='down', body_offset_y=0):
    """绘制完整的螃蟹"""
    # 身体
    draw_crab_body(draw, center_x, center_y + body_offset_y)

    # 眼睛
    draw_crab_eye(draw, center_x - 3, center_y + body_offset_y - 4)
    draw_crab_eye(draw, center_x + 3, center_y + body_offset_y - 4)

    # 蟹钳
    if claw_state == 'left_up':
        draw_crab_claw(draw, center_x - 8, center_y + body_offset_y - 2, size='large', side='left')
        draw_crab_claw(draw, center_x + 8, center_y + body_offset_y, size='normal', side='right')
    elif claw_state == 'right_up':
        draw_crab_claw(draw, center_x - 8, center_y + body_offset_y, size='normal', side='left')
        draw_crab_claw(draw, center_x + 8, center_y + body_offset_y - 2, size='large', side='right')
    elif claw_state == 'both_up':
        draw_crab_claw(draw, center_x - 8, center_y + body_offset_y - 2, size='large', side='left')
        draw_crab_claw(draw, center_x + 8, center_y + body_offset_y - 2, size='large', side='right')
    else:
        draw_crab_claw(draw, center_x - 8, center_y + body_offset_y, size='normal', side='left')
        draw_crab_claw(draw, center_x + 8, center_y + body_offset_y, size='normal', side='right')

    # 腿
    draw_crab_legs(draw, center_x, center_y + body_offset_y, leg_state)


# ==================== 动画1: 横行跑动 (Side Run) ====================

def generate_side_run_frames():
    """生成横行跑动动画8帧"""
    frames = []

    for i in range(8):
        img = create_base_image()
        draw = ImageDraw.Draw(img)

        # 确定蟹钳和腿的状态
        if i == 0:
            claw_state = 'normal'
            leg_state = 'down'
            offset_x = 0
        elif i == 1 or i == 2:
            claw_state = 'right_up'
            leg_state = 'right_up'
            offset_x = 1
        elif i == 3:
            claw_state = 'normal'
            leg_state = 'down'
            offset_x = 2
        elif i == 4 or i == 5:
            claw_state = 'left_up'
            leg_state = 'left_up'
            offset_x = 3
        elif i == 6:
            claw_state = 'normal'
            leg_state = 'down'
            offset_x = 4
        else:  # i == 7
            claw_state = 'normal'
            leg_state = 'down'
            offset_x = 2

        center_x = 11 + offset_x
        center_y = 11

        draw_full_crab(draw, center_x, center_y, claw_state, leg_state)
        frames.append(img)

    return frames


# ==================== 动画2: 弹跳小跑 (Bounce Hop) ====================

def generate_bounce_hop_frames():
    """生成弹跳小跑动画8帧"""
    frames = []

    # 弹跳高度曲线
    bounce_heights = [0, 1, 2, 3, 2, 1, 0, -1]  # -1表示压缩

    for i in range(8):
        img = create_base_image()
        draw = ImageDraw.Draw(img)

        offset_y = -bounce_heights[i]  # 向上是负值

        # 弹跳时蟹钳略微张开
        claw_state = 'both_up' if bounce_heights[i] > 1 else 'normal'

        center_x = 11
        center_y = 11 + offset_y

        draw_full_crab(draw, center_x, center_y, claw_state, 'down', offset_y)
        frames.append(img)

    return frames


# ==================== 动画3: 原地摆动蟹钳 (Claw Wave) ====================

def generate_claw_wave_frames():
    """生成原地摆动蟹钳动画8帧"""
    frames = []

    claw_states = ['normal', 'right_up', 'right_up', 'normal',
                   'left_up', 'left_up', 'normal', 'normal']

    # 身体轻微晃动
    body_offsets = [0, -1, -1, 0, 1, 1, 0, 0]

    for i in range(8):
        img = create_base_image()
        draw = ImageDraw.Draw(img)

        center_x = 11
        center_y = 11

        draw_full_crab(draw, center_x, center_y,
                       claw_states[i], 'down', body_offsets[i])
        frames.append(img)

    return frames


# ==================== 保存帧 ====================

def save_frames(frames, output_dir, animation_name):
    """保存帧序列到指定目录"""
    for i, frame in enumerate(frames):
        filename = f"frame_{i:02d}.png"
        filepath = os.path.join(output_dir, filename)
        frame.save(filepath)
        print(f"Saved: {filepath}")

    # 创建manifest.json
    manifest = {
        "name": animation_name,
        "frameCount": len(frames),
        "author": "Claude Code Generator",
        "version": "1.0"
    }

    import json
    manifest_path = os.path.join(output_dir, "manifest.json")
    with open(manifest_path, 'w') as f:
        json.dump(manifest, f, indent=2)
    print(f"Saved: {manifest_path}")


# ==================== 主程序 ====================

def main():
    base_dir = "/Users/dengzhixiang/code/open-run-cat/frame-animation"

    print("=" * 50)
    print("生成Claude Code螃蟹关键帧动画")
    print("=" * 50)

    # 动画1: 横行跑动
    print("\n[1/3] 生成横行跑动动画...")
    side_run_frames = generate_side_run_frames()
    save_frames(side_run_frames, os.path.join(base_dir, "side-run"), "Claude Crab - Side Run")

    # 动画2: 弹跳小跑
    print("\n[2/3] 生成弹跳小跑动画...")
    bounce_hop_frames = generate_bounce_hop_frames()
    save_frames(bounce_hop_frames, os.path.join(base_dir, "bounce-hop"), "Claude Crab - Bounce Hop")

    # 动画3: 原地摆动蟹钳
    print("\n[3/3] 生成原地摆动蟹钳动画...")
    claw_wave_frames = generate_claw_wave_frames()
    save_frames(claw_wave_frames, os.path.join(base_dir, "claw-wave"), "Claude Crab - Claw Wave")

    print("\n" + "=" * 50)
    print("完成! 共生成24帧PNG图片")
    print("=" * 50)


if __name__ == "__main__":
    main()