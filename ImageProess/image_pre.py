from PIL import Image, ImageDraw
import os

# Open the hass.png image
hass_img = Image.open('D:\\Tools\\AHKScript\\images\\hass.png')

# Resize to 128x128 pixels using LANCZOS resampling for high quality
hass_128 = hass_img.resize((128, 128), Image.Resampling.LANCZOS)

# Save as hass128.png
output_path_128 = 'D:\\Tools\\AHKScript\\images\\hass128.png'
hass_128.save(output_path_128)
print(f'已将图片调整为 128x128 像素，保存至: {output_path_128}')

# ========== iOS Bark 适配版本 ==========
# iOS 通知图标推荐尺寸为 40x40，并且需要处理透明背景和内边距

# 1. 创建白色背景的画布（44x44，留出2像素内边距）
ios_size = 40
canvas_size = 44  # 40 + 2*2 内边距
ios_icon = Image.new('RGBA', (canvas_size, canvas_size), (255, 255, 255, 0))

# 2. 将图片缩放到 36x36（留出4像素内边距）
logo_size = 36  # 40 - 4 内边距
if hass_img.mode == 'RGBA':
    # 如果是透明背景，先合成到白色背景
    white_bg = Image.new('RGB', hass_img.size, (255, 255, 255))
    white_bg.paste(hass_img, mask=hass_img.split()[3])  # 使用alpha通道作为mask
    hass_resized = white_bg.resize((logo_size, logo_size), Image.Resampling.LANCZOS)
else:
    hass_resized = hass_img.resize((logo_size, logo_size), Image.Resampling.LANCZOS)

# 3. 将缩放后的图片居中放置到画布上
x_offset = (canvas_size - logo_size) // 2
y_offset = (canvas_size - logo_size) // 2
ios_icon.paste(hass_resized, (x_offset, y_offset))

# 4. 最后缩放到 40x40（iOS推荐尺寸）
ios_icon_final = ios_icon.resize((ios_size, ios_size), Image.Resampling.LANCZOS)

# 5. 转换为RGB模式（iOS通知图标建议使用不透明背景）
ios_icon_rgb = Image.new('RGB', ios_icon_final.size, (255, 255, 255))
if ios_icon_final.mode == 'RGBA':
    ios_icon_rgb.paste(ios_icon_final, mask=ios_icon_final.split()[3])

# 保存iOS版本
output_path_ios = 'D:\\Tools\\AHKScript\\images\\hass_ios_bark.png'
ios_icon_rgb.save(output_path_ios, 'PNG')
print(f'已生成iOS Bark适配图标 (40x40，白色背景)，保存至: {output_path_ios}')

# 可选：生成带透明背景的版本（某些情况下可能也需要）
output_path_ios_trans = 'D:\\Tools\\AHKScript\\images\\hass_ios_bark_trans.png'
ios_icon_final.save(output_path_ios_trans, 'PNG')
print(f'已生成iOS Bark适配图标 (40x40，透明背景)，保存至: {output_path_ios_trans}')

# ========== Hass 图标 400x400 圆形版本（iOS完整显示） ==========
print('\n--- 开始处理 Hass 400x400 圆形图标 ---')

# 目标尺寸 400x400
target_size = 400
# 为了确保 iOS 完整显示，图标内容区域留出边距，实际内容区域为 360x360
content_size = 360  # 400 - 40 内边距（每边20像素）

# 1. 处理原始图片，如果透明背景则先合成到白色背景
if hass_img.mode == 'RGBA':
    # 转换为白色背景
    white_bg_hass = Image.new('RGB', hass_img.size, (255, 255, 255))
    white_bg_hass.paste(hass_img, mask=hass_img.split()[3])
    hass_processed = white_bg_hass
else:
    hass_processed = hass_img

# 2. 将图标缩放到内容区域大小（360x360），保持比例并居中裁剪
# 计算缩放比例，确保图片能完整放入
ratio_w = content_size / hass_processed.width
ratio_h = content_size / hass_processed.height
ratio = min(ratio_w, ratio_h)  # 使用较小的比例，确保完整显示

# 先按比例缩放
scaled_size = (int(hass_processed.width * ratio), int(hass_processed.height * ratio))
hass_scaled = hass_processed.resize(scaled_size, Image.Resampling.LANCZOS)

# 创建 400x400 的白色背景画布
canvas_400 = Image.new('RGB', (target_size, target_size), (255, 255, 255))

# 居中放置缩放后的图标
x_offset = (target_size - hass_scaled.width) // 2
y_offset = (target_size - hass_scaled.height) // 2
canvas_400.paste(hass_scaled, (x_offset, y_offset))

# 3. 创建圆形遮罩
mask_400 = Image.new('L', (target_size, target_size), 0)
draw = ImageDraw.Draw(mask_400)
# 圆形在画布中，留出边距（半径190，中心在200,200）
draw.ellipse((10, 10, target_size - 10, target_size - 10), fill=255)

# 4. 应用圆形遮罩，创建圆形图标
hass_circle = Image.new('RGBA', (target_size, target_size), (255, 255, 255, 0))
hass_circle.paste(canvas_400, (0, 0))
hass_circle.putalpha(mask_400)

# 5. 转换为RGB模式（白色背景，确保iOS显示正常）
hass_circle_rgb = Image.new('RGB', (target_size, target_size), (255, 255, 255))
hass_circle_rgb.paste(hass_circle, mask=hass_circle.split()[3])

# 保存 400x400 圆形图标
output_path_400 = 'D:\\Tools\\AHKScript\\images\\hass400_circle.png'
hass_circle_rgb.save(output_path_400, 'PNG')
print(f'已生成 Hass 圆形图标 (400x400，iOS完整显示)，保存至: {output_path_400}')

# 可选：保存带透明背景的版本
output_path_400_trans = 'D:\\Tools\\AHKScript\\images\\hass400_circle_trans.png'
hass_circle.save(output_path_400_trans, 'PNG')
print(f'已生成 Hass 圆形图标 (400x400，透明背景)，保存至: {output_path_400_trans}')

# ========== 处理 home-assistant-social-media-logo-round.png ==========
print('\n--- 开始处理 round 版本图标 ---')
round_img = Image.open('D:\\Tools\\AHKScript\\ImageProess\\hass-logo\\home-assistant-social-media-logo-round.png')

# 直接缩放为 400x400 像素
round_400 = round_img.resize((400, 400), Image.Resampling.LANCZOS)

# 保存为 hass_ios.png
output_path_ios = 'D:\\Tools\\AHKScript\\images\\hass_ios.png'
round_400.save(output_path_ios, 'PNG')
print(f'已生成 hass_ios.png (400x400)，保存至: {output_path_ios}')