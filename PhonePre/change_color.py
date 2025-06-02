from PIL import Image
import os

def change_background_color(image_path, output_color):
    # 打开图片
    img = Image.open(image_path).convert('RGBA')
    
    # 创建新图片
    width, height = img.size
    new_img = Image.new('RGBA', (width, height))
    
    # 定义目标颜色 (RGB)
    colors = {
        'white': (255, 255, 255, 255),
        'red': (255, 0, 0, 255)
    }
    
    # 获取目标颜色
    target_color = colors[output_color]
    
    # 处理每个像素
    pixels = img.load()
    new_pixels = new_img.load()
    
    for x in range(width):
        for y in range(height):
            r, g, b, a = pixels[x, y]
            # 判断是否为蓝色背景 (可以调整阈值)
            if (r < 100 and g < 50 and b > 100 and a > 0):  # 蓝色背景检测
                new_pixels[x, y] = target_color
            else:
                new_pixels[x, y] = (r, g, b, a)
    
    # 保存路径
    output_dir = os.path.dirname(image_path)
    filename = os.path.splitext(os.path.basename(image_path))[0]
    output_path = os.path.join(output_dir, f"{filename}-{output_color}.png")
    
    # 保存新图片
    new_img.save(output_path, 'PNG')
    print(f"已保存: {output_path}")

# 输入图片路径
input_path = r"D:\Docs\个人资料\入职资料\证件照2023-蓝底.jpg"

# 生成白底和红底图片
change_background_color(input_path, 'white')
change_background_color(input_path, 'red')