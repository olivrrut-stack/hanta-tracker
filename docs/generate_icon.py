from PIL import Image, ImageDraw, ImageFilter
import math

SIZE = 1024
cx, cy = SIZE // 2, SIZE // 2

img = Image.new("RGB", (SIZE, SIZE), "#0A0A0A")
draw = ImageDraw.Draw(img)

GLOBE_R = 370
GRID_COLOR = "#1C1C1C"
GRID_COLOR2 = "#161616"
RED = (255, 59, 48)

# --- Atmosphere glow behind globe ---
glow = Image.new("RGB", (SIZE, SIZE), "#0A0A0A")
glow_draw = ImageDraw.Draw(glow)
for i in range(40, 0, -1):
    alpha_val = int(18 * (1 - i / 40))
    r_outer = GLOBE_R + i * 1.8
    glow_draw.ellipse(
        [cx - r_outer, cy - r_outer, cx + r_outer, cy + r_outer],
        fill=(18 + i // 4, 18 + i // 4, 18 + i // 4),
    )
img = Image.blend(img, glow, 0.4)
draw = ImageDraw.Draw(img)

# --- Globe base ---
draw.ellipse(
    [cx - GLOBE_R, cy - GLOBE_R, cx + GLOBE_R, cy + GLOBE_R],
    fill="#0F0F0F",
)

# --- Latitude lines ---
for lat_deg in range(-75, 90, 15):
    lat = math.radians(lat_deg)
    y = cy + GLOBE_R * math.sin(lat)
    r_lat = GLOBE_R * math.cos(lat)
    if r_lat < 5:
        continue
    color = GRID_COLOR if lat_deg % 30 == 0 else GRID_COLOR2
    draw.ellipse(
        [cx - r_lat, y - r_lat * 0.28, cx + r_lat, y + r_lat * 0.28],
        outline=color,
        width=1,
    )

# --- Longitude lines (as vertical ellipses, rotated via math) ---
for lon_deg in range(0, 180, 15):
    lon = math.radians(lon_deg)
    color = GRID_COLOR if lon_deg % 30 == 0 else GRID_COLOR2
    # Draw as points along the meridian arc
    points = []
    for step in range(0, 361, 3):
        t = math.radians(step)
        x = cx + GLOBE_R * math.sin(t) * math.cos(lon)
        y = cy - GLOBE_R * math.cos(t)
        # Only draw points on the front hemisphere (rough clipping)
        points.append((x, y))
    for i in range(len(points) - 1):
        x1, y1 = points[i]
        x2, y2 = points[i + 1]
        draw.line([x1, y1, x2, y2], fill=color, width=1)

# --- Globe edge highlight (thin bright rim) ---
for w in range(3, 0, -1):
    rim_alpha = 40 - w * 10
    draw.ellipse(
        [cx - GLOBE_R, cy - GLOBE_R, cx + GLOBE_R, cy + GLOBE_R],
        outline=(30, 30, 30),
        width=w,
    )
draw.ellipse(
    [cx - GLOBE_R, cy - GLOBE_R, cx + GLOBE_R, cy + GLOBE_R],
    outline=(45, 45, 45),
    width=1,
)

# --- Subtle pole caps ---
pole_r = 28
draw.ellipse(
    [cx - pole_r, cy - GLOBE_R - 6, cx + pole_r, cy - GLOBE_R + 6],
    fill="#161616", outline=GRID_COLOR, width=1,
)
draw.ellipse(
    [cx - pole_r, cy + GLOBE_R - 6, cx + pole_r, cy + GLOBE_R + 6],
    fill="#161616", outline=GRID_COLOR2, width=1,
)

# --- Alert marker position (placed in East Asia / China area on globe) ---
marker_lon = math.radians(40)   # rotated 40 deg right of center
marker_lat = math.radians(-20)  # slightly below equator (Southeast Asia vibe)
mx = cx + GLOBE_R * math.sin(marker_lon) * math.cos(marker_lat)
my = cy - GLOBE_R * math.sin(marker_lat)

# Pulse rings (RGBA via separate layer)
pulse_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
pulse_draw = ImageDraw.Draw(pulse_layer)
ring_radii = [72, 50, 32]
ring_alphas = [22, 40, 65]
for rad, alpha in zip(ring_radii, ring_alphas):
    pulse_draw.ellipse(
        [mx - rad, my - rad, mx + rad, my + rad],
        outline=(*RED, alpha),
        width=2,
    )

img_rgba = img.convert("RGBA")
img_rgba = Image.alpha_composite(img_rgba, pulse_layer)
img = img_rgba.convert("RGB")
draw = ImageDraw.Draw(img)

# Solid red dot
dot_r = 14
draw.ellipse(
    [mx - dot_r, my - dot_r, mx + dot_r, my + dot_r],
    fill=RED,
)
# White core highlight
draw.ellipse(
    [mx - 5, my - 7, mx + 5, my - 1],
    fill=(255, 120, 110),
)

# --- Subtle vignette ---
vignette = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
vd = ImageDraw.Draw(vignette)
for i in range(80, 0, -1):
    a = int(120 * (1 - (i / 80) ** 2))
    vd.rectangle([i, i, SIZE - i, SIZE - i], outline=(0, 0, 0, 3))
img_rgba2 = img.convert("RGBA")
img_final = Image.alpha_composite(img_rgba2, vignette).convert("RGB")

# --- Save ---
out_path = "C:/Users/Oliver/Desktop/Main Crsr Prjcts/hanta app/HantaTracker/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"
img_final.save(out_path, "PNG", quality=100)
print(f"Saved: {out_path}")
