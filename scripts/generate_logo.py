import os
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter

def draw_rounded_rect(draw, bounds, radius, fill, outline=None, width=1):
    x0, y0, x1, y1 = bounds
    draw.rounded_rectangle([x0, y0, x1, y1], radius=radius, fill=fill, outline=outline, width=width)

def generate_together_logo(size=1024):
    scale = 2
    canvas_size = size * scale
    img = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    margin = int(canvas_size * 0.05)
    rect_box = [margin, margin, canvas_size - margin, canvas_size - margin]
    corner_radius = int(canvas_size * 0.22)

    # 1. Subtle drop shadow for squircle
    shadow_offset = int(canvas_size * 0.02)
    shadow_box = [margin, margin + shadow_offset, canvas_size - margin, canvas_size - margin + shadow_offset]
    draw.rounded_rectangle(shadow_box, radius=corner_radius, fill=(0, 0, 0, 35))

    # 2. Main squircle background - Sage green gradient fill
    bg_color = (205, 222, 208, 255) # Light sage #CDDED0
    border_color = (175, 198, 178, 255)
    draw.rounded_rectangle(rect_box, radius=corner_radius, fill=bg_color, outline=border_color, width=int(8 * scale))

    # Inner soft highlight glow
    inner_margin = margin + int(10 * scale)
    inner_box = [inner_margin, inner_margin, canvas_size - inner_margin, canvas_size - inner_margin]
    draw.rounded_rectangle(inner_box, radius=corner_radius - int(10 * scale), outline=(255, 255, 255, 90), width=int(6 * scale))

    cx = canvas_size // 2
    cy = int(canvas_size * 0.52)
    head_w = int(canvas_size * 0.35)
    head_h = int(canvas_size * 0.29)

    outline_color = (48, 54, 50, 255) # Charcoal #303632
    cream_color = (255, 252, 244, 255) # Soft warm cream #FFFCF4
    sage_accent = (106, 134, 112, 255) # Sage green #6A8670
    dark_sage = (82, 107, 88, 255)
    blush_color = (248, 175, 168, 200) # Soft peach pink

    line_w = int(8 * scale)

    # 3. Ears
    ear_w = int(canvas_size * 0.12)
    ear_h = int(canvas_size * 0.18)

    # Left ear outer
    left_ear = [(cx - int(head_w * 0.72), cy - int(head_h * 0.5)),
                (cx - int(head_w * 0.65), cy - int(head_h * 1.15)),
                (cx - int(head_w * 0.18), cy - int(head_h * 0.8))]
    draw.polygon(left_ear, fill=cream_color)
    # Left ear inner sage
    left_ear_inner = [(cx - int(head_w * 0.65), cy - int(head_h * 0.55)),
                      (cx - int(head_w * 0.60), cy - int(head_h * 1.05)),
                      (cx - int(head_w * 0.25), cy - int(head_h * 0.78))]
    draw.polygon(left_ear_inner, fill=sage_accent)
    draw.line(left_ear + [left_ear[0]], fill=outline_color, width=line_w, joint="curve")

    # Right ear outer
    right_ear = [(cx + int(head_w * 0.18), cy - int(head_h * 0.8)),
                 (cx + int(head_w * 0.65), cy - int(head_h * 1.15)),
                 (cx + int(head_w * 0.72), cy - int(head_h * 0.5))]
    draw.polygon(right_ear, fill=cream_color)
    # Right ear inner sage
    right_ear_inner = [(cx + int(head_w * 0.25), cy - int(head_h * 0.78)),
                       (cx + int(head_w * 0.60), cy - int(head_h * 1.05)),
                       (cx + int(head_w * 0.65), cy - int(head_h * 0.55))]
    draw.polygon(right_ear_inner, fill=sage_accent)
    draw.line(right_ear + [right_ear[0]], fill=outline_color, width=line_w, joint="curve")

    # 4. Scarf / Bandana around neck
    scarf_y = cy + int(head_h * 0.65)
    scarf_pts = [
        (cx - int(head_w * 0.62), scarf_y - int(25 * scale)),
        (cx + int(head_w * 0.62), scarf_y - int(25 * scale)),
        (cx + int(head_w * 0.35), scarf_y + int(70 * scale)),
        (cx, scarf_y + int(105 * scale)),
        (cx - int(head_w * 0.35), scarf_y + int(70 * scale)),
    ]
    draw.polygon(scarf_pts, fill=sage_accent)
    draw.line(scarf_pts + [scarf_pts[0]], fill=outline_color, width=line_w, joint="curve")

    # Together Emblem on Scarf (Two twin white figures / circles)
    emblem_y = scarf_y + int(38 * scale)
    emb_r = int(14 * scale)
    draw.ellipse([cx - int(26 * scale) - emb_r, emblem_y - emb_r, cx - int(26 * scale) + emb_r, emblem_y + emb_r], fill=(255, 255, 255, 240))
    draw.ellipse([cx + int(26 * scale) - emb_r, emblem_y - emb_r, cx + int(26 * scale) + emb_r, emblem_y + emb_r], fill=(255, 255, 255, 240))
    # Body arc under each head for twin figure
    draw.pieslice([cx - int(26 * scale) - emb_r*2, emblem_y + int(2 * scale), cx - int(26 * scale) + emb_r*2, emblem_y + emb_r*4], 180, 360, fill=(255, 255, 255, 240))
    draw.pieslice([cx + int(26 * scale) - emb_r*2, emblem_y + int(2 * scale), cx + int(26 * scale) + emb_r*2, emblem_y + emb_r*4], 180, 360, fill=(255, 255, 255, 240))

    # 5. Head (Plump rounded cat head)
    head_box = [cx - head_w, cy - head_h, cx + head_w, cy + head_h]
    draw.ellipse(head_box, fill=cream_color, outline=outline_color, width=line_w)

    # 6. Cheeks Blush
    blush_r_x = int(24 * scale)
    blush_r_y = int(14 * scale)
    blush_y = cy + int(head_h * 0.22)
    draw.ellipse([cx - int(head_w * 0.58) - blush_r_x, blush_y - blush_r_y, cx - int(head_w * 0.58) + blush_r_x, blush_y + blush_r_y], fill=blush_color)
    draw.ellipse([cx + int(head_w * 0.58) - blush_r_x, blush_y - blush_r_y, cx + int(head_w * 0.58) + blush_r_x, blush_y + blush_r_y], fill=blush_color)

    # 7. Eyes (Round dark sparkling eyes)
    eye_r = int(16 * scale)
    eye_y = cy + int(head_h * 0.05)
    left_eye_x = cx - int(head_w * 0.38)
    right_eye_x = cx + int(head_w * 0.38)

    draw.ellipse([left_eye_x - eye_r, eye_y - eye_r, left_eye_x + eye_r, eye_y + eye_r], fill=outline_color)
    draw.ellipse([right_eye_x - eye_r, eye_y - eye_r, right_eye_x + eye_r, eye_y + eye_r], fill=outline_color)

    # Eye catchlights
    highlight_r = int(5 * scale)
    draw.ellipse([left_eye_x - int(5 * scale), eye_y - int(6 * scale), left_eye_x - int(5 * scale) + highlight_r*2, eye_y - int(6 * scale) + highlight_r*2], fill=(255, 255, 255, 255))
    draw.ellipse([right_eye_x - int(5 * scale), eye_y - int(6 * scale), right_eye_x - int(5 * scale) + highlight_r*2, eye_y - int(6 * scale) + highlight_r*2], fill=(255, 255, 255, 255))

    # 8. Nose
    nose_y = cy + int(head_h * 0.2)
    nose_pts = [(cx - int(7 * scale), nose_y), (cx + int(7 * scale), nose_y), (cx, nose_y + int(7 * scale))]
    draw.polygon(nose_pts, fill=outline_color)

    # 9. Cute cat mouth (ω shape)
    mouth_y = nose_y + int(7 * scale)
    draw.arc([cx - int(18 * scale), mouth_y, cx, mouth_y + int(14 * scale)], 0, 180, fill=outline_color, width=int(5 * scale))
    draw.arc([cx, mouth_y, cx + int(18 * scale), mouth_y + int(14 * scale)], 0, 180, fill=outline_color, width=int(5 * scale))

    # 10. Whiskers (Subtle hand-drawn lines on sides)
    w_len = int(32 * scale)
    whisker_w = int(4 * scale)
    # Left whiskers
    draw.line([(cx - int(head_w * 0.75), cy + int(head_h * 0.15)), (cx - int(head_w * 0.75) - w_len, cy + int(head_h * 0.08))], fill=outline_color, width=whisker_w)
    draw.line([(cx - int(head_w * 0.75), cy + int(head_h * 0.3)), (cx - int(head_w * 0.75) - w_len, cy + int(head_h * 0.35))], fill=outline_color, width=whisker_w)
    # Right whiskers
    draw.line([(cx + int(head_w * 0.75), cy + int(head_h * 0.15)), (cx + int(head_w * 0.75) + w_len, cy + int(head_h * 0.08))], fill=outline_color, width=whisker_w)
    draw.line([(cx + int(head_w * 0.75), cy + int(head_h * 0.3)), (cx + int(head_w * 0.75) + w_len, cy + int(head_h * 0.35))], fill=outline_color, width=whisker_w)

    # Downsample with high-quality Lanczos for crisp antialiasing
    final_img = img.resize((size, size), Image.Resampling.LANCZOS)
    return final_img

def main():
    os.makedirs("assets/logo", exist_ok=True)

    # 1. 1024x1024 Master Logo
    logo_1024 = generate_together_logo(1024)
    logo_1024.save("assets/logo/together_logo.png", "PNG")
    print("✅ Created assets/logo/together_logo.png (1024x1024)")

    # 2. 512x512 Icon
    logo_512 = logo_1024.resize((512, 512), Image.Resampling.LANCZOS)
    logo_512.save("assets/logo/together_icon.png", "PNG")
    print("✅ Created assets/logo/together_icon.png (512x512)")

    # 3. Android Mipmap Launcher Icons
    mipmaps = {
        "android/app/src/main/res/mipmap-mdpi/ic_launcher.png": 48,
        "android/app/src/main/res/mipmap-hdpi/ic_launcher.png": 72,
        "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png": 96,
        "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png": 144,
        "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png": 192,
    }

    for path, sz in mipmaps.items():
        os.makedirs(os.path.dirname(path), exist_ok=True)
        res_icon = logo_1024.resize((sz, sz), Image.Resampling.LANCZOS)
        res_icon.save(path, "PNG")
        print(f"✅ Generated launcher icon: {path} ({sz}x{sz})")

if __name__ == "__main__":
    main()

