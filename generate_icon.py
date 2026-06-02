#!/usr/bin/env python3
"""Generate Purgify app icon - dark fire theme."""

import math
from PIL import Image, ImageDraw, ImageFilter
import os

SIZE = 1024

def lerp_color(c1, c2, t):
    return tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(3))

def make_gradient_bg(size):
    img = Image.new("RGBA", (size, size))
    draw = ImageDraw.Draw(img)
    top = (8, 9, 15)
    bot = (20, 14, 8)
    for y in range(size):
        t = y / size
        r, g, b = lerp_color(top, bot, t)
        draw.line([(0, y), (size, y)], fill=(r, g, b, 255))
    return img

def draw_flame(draw, cx, cy, w, h, alpha=255):
    """Draw a stylized flame using bezier-like curves with polygons."""
    # Outer flame - red/orange
    flame_outer = [
        (cx, cy - h * 0.50),            # tip
        (cx + w * 0.22, cy - h * 0.35),
        (cx + w * 0.48, cy - h * 0.10),
        (cx + w * 0.48, cy + h * 0.50),
        (cx - w * 0.48, cy + h * 0.50),
        (cx - w * 0.48, cy - h * 0.10),
        (cx - w * 0.22, cy - h * 0.35),
    ]
    draw.polygon(flame_outer, fill=(255, 69, 0, alpha))

    # Middle flame - orange/gold
    flame_mid = [
        (cx, cy - h * 0.36),
        (cx + w * 0.16, cy - h * 0.22),
        (cx + w * 0.32, cy + h * 0.04),
        (cx + w * 0.32, cy + h * 0.50),
        (cx - w * 0.32, cy + h * 0.50),
        (cx - w * 0.32, cy + h * 0.04),
        (cx - w * 0.16, cy - h * 0.22),
    ]
    draw.polygon(flame_mid, fill=(255, 140, 0, alpha))

    # Inner flame - yellow
    flame_inner = [
        (cx, cy - h * 0.22),
        (cx + w * 0.10, cy - h * 0.10),
        (cx + w * 0.18, cy + h * 0.14),
        (cx + w * 0.18, cy + h * 0.50),
        (cx - w * 0.18, cy + h * 0.50),
        (cx - w * 0.18, cy + h * 0.14),
        (cx - w * 0.10, cy - h * 0.10),
    ]
    draw.polygon(flame_inner, fill=(255, 215, 0, alpha))

    # Core white glow
    flame_core = [
        (cx, cy - h * 0.08),
        (cx + w * 0.05, cy + h * 0.10),
        (cx + w * 0.08, cy + h * 0.50),
        (cx - w * 0.08, cy + h * 0.50),
        (cx - w * 0.05, cy + h * 0.10),
    ]
    draw.polygon(flame_core, fill=(255, 255, 240, alpha))

def make_icon(size=1024):
    # Background
    img = make_gradient_bg(size)

    # Rounded rect mask
    mask = Image.new("L", (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    radius = int(size * 0.22)
    mask_draw.rounded_rectangle([0, 0, size, size], radius=radius, fill=255)

    # Glow layer
    glow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    cx, cy = size // 2, size // 2 + int(size * 0.04)
    w = int(size * 0.34)
    h = int(size * 0.56)

    # Outer glow rings
    for i in range(8, 0, -1):
        factor = i / 8
        glow_alpha = int(30 * factor)
        gd.ellipse([
            cx - w * 0.6 * (1 + factor * 0.5),
            cy - h * 0.6 * (1 + factor * 0.3),
            cx + w * 0.6 * (1 + factor * 0.5),
            cy + h * 0.3 * (1 + factor * 0.3),
        ], fill=(255, 100, 0, glow_alpha))

    glow_blurred = glow.filter(ImageFilter.GaussianBlur(radius=int(size * 0.06)))
    img = Image.alpha_composite(img, glow_blurred)

    # Draw flame layers (multiple passes for smooth look)
    flame_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    fd = ImageDraw.Draw(flame_layer)

    # Shadow flame (slight offset)
    draw_flame(fd, cx + int(size*0.01), cy + int(size*0.015),
               int(w*1.05), int(h*1.05), alpha=80)

    # Main flame
    draw_flame(fd, cx, cy, w, h, alpha=255)

    flame_blurred = flame_layer.filter(ImageFilter.GaussianBlur(radius=2))
    img = Image.alpha_composite(img, flame_blurred)

    # Sharp flame on top
    flame_sharp = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    fs = ImageDraw.Draw(flame_sharp)
    draw_flame(fs, cx, cy, w, h, alpha=255)
    img = Image.alpha_composite(img, flame_sharp)

    # Sparkles / particles
    spark = ImageDraw.Draw(img)
    import random
    random.seed(42)
    particles = [
        (cx - int(w*0.3), cy - int(h*0.55), 4, (255, 220, 80, 200)),
        (cx + int(w*0.25), cy - int(h*0.45), 3, (255, 180, 40, 180)),
        (cx - int(w*0.12), cy - int(h*0.62), 5, (255, 255, 100, 220)),
        (cx + int(w*0.08), cy - int(h*0.58), 3, (255, 200, 60, 160)),
        (cx + int(w*0.35), cy - int(h*0.30), 4, (255, 150, 30, 150)),
        (cx - int(w*0.38), cy - int(h*0.22), 3, (255, 120, 20, 140)),
    ]
    for px, py, pr, pc in particles:
        r = int(pr * size / 256)
        spark.ellipse([px-r, py-r, px+r, py+r], fill=pc)

    # "P" letter overlay (subtle branding)
    # Skip letter, keep it clean icon-only

    # Apply rounded mask
    result = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    result.paste(img, mask=mask)

    return result


def resize_and_save(img, path, size):
    resized = img.resize((size, size), Image.LANCZOS)
    resized.save(path, "PNG")
    print(f"  Saved {size}x{size} → {path}")


if __name__ == "__main__":
    print("Generating Purgify app icon...")
    icon = make_icon(SIZE)

    # Save master
    master_path = "/Users/apple/CleanDroid/assets/images/app_icon_1024.png"
    icon.save(master_path, "PNG")
    print(f"Master icon saved: {master_path}")

    # iOS sizes
    ios_dir = "/Users/apple/CleanDroid/ios/Runner/Assets.xcassets/AppIcon.appiconset"
    ios_sizes = {
        "Icon-App-1024x1024@1x.png": 1024,
        "Icon-App-20x20@1x.png": 20,
        "Icon-App-20x20@2x.png": 40,
        "Icon-App-20x20@3x.png": 60,
        "Icon-App-29x29@1x.png": 29,
        "Icon-App-29x29@2x.png": 58,
        "Icon-App-29x29@3x.png": 87,
        "Icon-App-40x40@1x.png": 40,
        "Icon-App-40x40@2x.png": 80,
        "Icon-App-40x40@3x.png": 120,
        "Icon-App-60x60@2x.png": 120,
        "Icon-App-60x60@3x.png": 180,
        "Icon-App-76x76@1x.png": 76,
        "Icon-App-76x76@2x.png": 152,
        "Icon-App-83.5x83.5@2x.png": 167,
    }
    print("\niOS icons:")
    for filename, size in ios_sizes.items():
        resize_and_save(icon, os.path.join(ios_dir, filename), size)

    # Android sizes
    android_sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    android_base = "/Users/apple/CleanDroid/android/app/src/main/res"
    print("\nAndroid icons:")
    for folder, size in android_sizes.items():
        for fname in ["ic_launcher.png", "ic_launcher_round.png"]:
            path = os.path.join(android_base, folder, fname)
            resize_and_save(icon, path, size)

    print("\nDone! All icons generated.")
