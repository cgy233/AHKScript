import os
from PIL import Image
from reportlab.pdfgen import canvas

def png_to_pdf(input_dir, output_dir=None):
    # 如果没有指定输出目录，就使用输入目录
    if output_dir is None:
        output_dir = input_dir
    
    # 确保输出目录存在
    os.makedirs(output_dir, exist_ok=True)
    
    # 获取目录下所有png文件
    png_files = [f for f in os.listdir(input_dir) if f.lower().endswith('.png')]
    
    for png_file in png_files:
        try:
            # 构建输入和输出文件路径
            input_path = os.path.join(input_dir, png_file)
            # 去掉.png扩展名，添加.pdf
            output_filename = os.path.splitext(png_file)[0] + '.pdf'
            output_path = os.path.join(output_dir, output_filename)
            
            # 打开PNG图片
            img = Image.open(input_path)
            
            # 如果图片是RGBA模式，转换为RGB
            if img.mode == 'RGBA':
                img = img.convert('RGB')
            
            # 获取图片尺寸
            width, height = img.size
            
            # 创建PDF文件
            c = canvas.Canvas(output_path)
            # 设置PDF页面大小为图片大小
            c.setPageSize((width, height))
            
            # 将图片添加到PDF
            c.drawImage(input_path, 0, 0, width, height)
            c.showPage()
            c.save()
            
            print(f"已转换: {png_file} -> {output_filename}")
            
        except Exception as e:
            print(f"转换 {png_file} 时出错: {str(e)}")

# 使用示例
if __name__ == "__main__":
    # 指定输入目录
    input_directory = r"D:\Docs\个人资料\入职资料"  # 替换为你的输入目录路径
    # 可选：指定输出目录，如果不指定则使用输入目录
    output_directory = r"D:\Docs\个人资料\入职资料\PDF"  # 替换为你的输出目录路径
    
    # 执行转换
    png_to_pdf(input_directory, output_directory)
    # 如果只想在输入目录中转换和保存，可以只传入一个参数
    # png_to_pdf(input_directory)