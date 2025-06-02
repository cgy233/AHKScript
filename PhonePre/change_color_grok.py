import cv2
import numpy as np
import sys

# 定义常见背景颜色（BGR 格式）
colors = {
    'white': (255, 255, 255),
    'blue': (255, 0, 0),
    'green': (0, 255, 0),
    'red': (0, 0, 255),
    'black': (0, 0, 0)
}

def main():
    # 检查命令行参数
    if len(sys.argv) != 2:
        print("Usage: python script.py <image_path>")
        sys.exit(1)
    
    img_path = sys.argv[1]
    img = cv2.imread(img_path)
    if img is None:
        print("Error: Could not load image")
        sys.exit(1)
    
    # 使用 k-means 聚类识别背景颜色
    img_float = img.astype('float32')
    pixels = img_float.reshape(-1, 3)
    criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 10, 1.0)
    ret, labels, centers = cv2.kmeans(pixels, 2, None, criteria, 10, cv2.KMEANS_RANDOM_CENTERS)
    cluster_counts = np.bincount(labels[:, 0])
    background_cluster = np.argwhere(cluster_counts == np.max(cluster_counts))[0][0]
    background_color = centers[background_cluster]
    print(f"Identified background color: {background_color}")
    
    # 为 GrabCut 创建初始掩码
    mask = np.full(pixels.shape[0], cv2.GC_PR_FGD, dtype=np.int8)
    mask[labels[:,0] == background_cluster] = cv2.GC_BGD
    mask = mask.reshape(img.shape[:2])
    
    # 运行 GrabCut
    bgdModel = np.zeros((1, 65), np.float64)
    fgdModel = np.zeros((1, 65), np.float64)
    cv2.grabCut(img, mask, None, bgdModel, fgdModel, 5, cv2.GC_INIT_WITH_MASK)
    
    # 创建最终掩码
    final_mask = np.where((mask == cv2.GC_FGD) | (mask == cv2.GC_PR_FGD), 255, 0).astype(np.uint8)
    
    # 提供颜色选择
    print("Choose a new background color:")
    for i, color_name in enumerate(colors.keys()):
        print(f"{i+1}. {color_name}")
    while True:
        try:
            choice = int(input("Enter the number of your choice: "))
            if 1 <= choice <= len(colors):
                break
            else:
                print("Invalid choice. Please enter a number between 1 and", len(colors))
        except ValueError:
            print("Invalid input. Please enter a number.")
    chosen_color_name = list(colors.keys())[choice-1]
    chosen_color = colors[chosen_color_name]
    print(f"You have chosen {chosen_color_name}.")
    
    # 替换背景
    new_img = img.copy()
    background_pixels = np.where(final_mask == 0)
    new_img[background_pixels] = chosen_color
    
    # 转换为 RGB 格式以确保正确显示
    new_img = cv2.cvtColor(new_img, cv2.COLOR_BGR2RGB)
    
    # 保存新图像
    cv2.imwrite('new_id_photo.jpg', new_img)
    print("New image saved as new_id_photo.jpg")

if __name__ == "__main__":
    main()