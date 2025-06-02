import sys
from datetime import datetime

def main():
    # 获取所有传递的参数
    args = sys.argv[1:]
    
    # 获取当前时间并格式化为字符串
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    # 将时间戳和参数追加到 args.txt 文件中，并在每次写入时换行
    with open("args.txt", "a", encoding="utf-8") as f:
        f.write(f"{timestamp} ffmpeg: {str(args)}\n")
    
    print("参数已追加到 args.txt")

if __name__ == "__main__":
    main()

