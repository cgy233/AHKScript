import ffmpeg

# 输入视频文件名
input_file = 'D:/Tools/AHKScript/Video_proess/backlight.mp4'
# 输出视频文件名
output_file = 'D:/Tools/AHKScript/Video_proess/backlight_resized.mp4'
# 目标分辨率
width = 1024
height = 600

# 使用ffmpeg缩放视频
(
    ffmpeg
    .input(input_file)
    .filter('scale', width, height)
    .output(output_file)
    .run()
)
