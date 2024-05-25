import shutil
import os
import math

from moviepy.video.io.ffmpeg_tools import ffmpeg_extract_subclip # type: ignore
from moviepy.editor import concatenate_videoclips, VideoFileClip # type: ignore
from moviepy.editor import VideoFileClip, concatenate_videoclips # type: ignore
from moviepy.video.io.ImageSequenceClip import ImageSequenceClip # type: ignore
from moviepy.editor import VideoFileClip, concatenate_videoclips, AudioFileClip, CompositeAudioClip, ImageSequenceClip # type: ignore
from moviepy.video.compositing.concatenate import concatenate_videoclips


import time
from datetime import timedelta

def process_video_save_origin_fps(file_path, frame_rate):
    # 加载视频
    clip = VideoFileClip(file_path)

    # 计算要保留帧之间的时间间隔
    interval = 1 / frame_rate
    print(f"原始帧率: {clip.fps}, 帧间隔: {interval}")

    # 创建一个列表来保存子剪辑
    subclips = []

    # 按时间间隔遍历视频时长
    for t in range(0, int(clip.duration), interval):
        # 提取子剪辑，确保结束时间不超过视频时长
        subclip = clip.subclip(t, min(t + interval, clip.duration))
        subclips.append(subclip)

    # 如果子剪辑列表长度大于1，则连接子剪辑
    if len(subclips) > 1:
        final_clip = concatenate_videoclips(subclips)
    else:
        final_clip = subclips[0]

    # 写入结果到文件
    new_file_path = file_path.rsplit('.', 1)[0] + '_afe.' + file_path.rsplit('.', 1)[1]
    final_clip.write_videofile(new_file_path, codec='libx264')
    print(f"处理后的视频保存到: {new_file_path}")


def process_video_target_fps(file_path, target_frame_rate):
    # 加载视频
    clip = VideoFileClip(file_path)
    
    # 计算帧间隔时间
    frame_interval = 1.0 / target_frame_rate
    print(f"原始帧率: {clip.fps}, 目标帧率: {target_frame_rate}, 帧间隔: {frame_interval}")
    
    # 创建一个列表来保存保留的帧
    frames = []
    timestamps = []
    t = 0.0
    while t < clip.duration:
        frames.append(clip.get_frame(t))
        timestamps.append(t)
        t += frame_interval
    
    # 创建一个新的视频剪辑，使用保留的帧
    new_clip = ImageSequenceClip(frames, fps=target_frame_rate)
    
    # 将原视频的音频裁剪到新视频的时长
    audio = clip.audio.subclip(0, new_clip.duration)
    
    # 将音频添加到新视频剪辑中
    final_clip = new_clip.set_audio(audio)
    
    # 生成新文件名
    new_file_path = file_path.rsplit('.', 1)[0] + '_changed_fps_with_audio.' + file_path.rsplit('.', 1)[1]
    
    # 写入新文件
    final_clip.write_videofile(new_file_path, codec='libx264', audio_codec='aac')
    print(f"处理后的视频保存到: {new_file_path}")

def process_single_video(file_path, reduce_frames):
    start_time = time.time()  # 记录开始时间

    # 加载视频
    clip = VideoFileClip(file_path)
    
    # 计算目标帧率
    target_frame_rate = clip.fps - reduce_frames
    if target_frame_rate <= 0:
        raise ValueError("减少的帧数太多，目标帧率必须大于0")
    
    # 计算帧间隔时间
    frame_interval = 1.0 / target_frame_rate
    print(f"原始帧率: {clip.fps}, 目标帧率: {target_frame_rate}, 帧间隔: {frame_interval}")
    
    # 创建一个列表来保存保留的帧
    frames = []
    t = 0.0
    while t < clip.duration:
        frames.append(clip.get_frame(t))
        t += frame_interval
    
    # 创建一个新的视频剪辑，使用保留的帧
    new_clip = ImageSequenceClip(frames, fps=target_frame_rate)
    
    # 将原视频的音频裁剪到新视频的时长
    audio = clip.audio.subclip(0, new_clip.duration)
    
    # 将音频添加到新视频剪辑中
    final_clip = new_clip.set_audio(audio)
    
    # 生成新文件名
    new_file_path = file_path.rsplit('.', 1)[0] + '_changed_fps_with_audio.' + file_path.rsplit('.', 1)[1]
    
    # 写入新文件
    final_clip.write_videofile(new_file_path, codec='libx264', audio_codec='aac')
    end_time = time.time()  # 记录结束时间
    elapsed_time = end_time - start_time  # 计算执行时间
    elapsed_time_str = str(timedelta(seconds=elapsed_time))  # 将秒数转换为时分秒的格式
    print(f"处理后的视频保存到: {new_file_path}")
    print(f"处理时间: {elapsed_time_str}")

def process_video(file_path, reduce_frames):
    start_time = time.time()  # 记录开始时间

    # 加载视频
    clip = VideoFileClip(file_path)
    
    # 计算目标帧率
    target_frame_rate = clip.fps - reduce_frames
    if target_frame_rate <= 0:
        raise ValueError("减少的帧数太多，目标帧率必须大于0")
    
    # 计算帧间隔时间
    frame_interval = 1.0 / target_frame_rate
    print(f"原始帧率: {clip.fps}, 目标帧率: {target_frame_rate}, 帧间隔: {frame_interval}")
    
    # 将视频分割成5秒的小段
    clip_duration = 5.0
    num_segments = int(clip.duration / clip_duration) + 1
    segments = [clip.subclip(i*clip_duration, min((i+1)*clip_duration, clip.duration)) for i in range(num_segments)]
    
    # 创建临时文件列表保存处理后的段落
    temp_files = []

    for i, segment in enumerate(segments):
        # 创建一个列表来保存保留的帧
        frames = []
        t = 0.0
        while t < segment.duration:
            frames.append(segment.get_frame(t))
            t += frame_interval
        
        # 创建一个新的视频剪辑，使用保留的帧
        new_segment = ImageSequenceClip(frames, fps=target_frame_rate)
        
        # 将原视频的音频裁剪到新视频的时长
        audio = segment.audio.subclip(0, new_segment.duration)
        
        # 将音频添加到新视频剪辑中
        final_segment = new_segment.set_audio(audio)
        
        # 临时保存处理后的段落
        temp_file_path = f"temp_segment_{i}.mp4"
        final_segment.write_videofile(temp_file_path, codec='libx264', audio_codec='aac')
        temp_files.append(temp_file_path)
    
    # 加载临时保存的段落并合并
    processed_segments = [VideoFileClip(temp_file) for temp_file in temp_files]
    final_clip = concatenate_videoclips(processed_segments)
    
    # 生成新文件名
    new_file_path = file_path.rsplit('.', 1)[0] + '_changed_fps_with_audio.' + file_path.rsplit('.', 1)[1]
    
    # 写入新文件
    final_clip.write_videofile(new_file_path, codec='libx264', audio_codec='aac')

    # 删除临时文件
    for temp_file in temp_files:
        os.remove(temp_file)

    end_time = time.time()  # 记录结束时间
    elapsed_time = end_time - start_time  # 计算执行时间
    elapsed_time_str = str(timedelta(seconds=elapsed_time))  # 将秒数转换为时分秒的格式
    print(f"处理后的视频保存到: {new_file_path}")
    print(f"处理时间: {elapsed_time_str}")

def process_directory(dir_path, target_reduce_frames):
    # 列出目录下的文件和子目录
    files = os.listdir(dir_path)
    num_videos = sum(1 for file_name in files if os.path.isfile(os.path.join(dir_path, file_name)) and file_name.lower().endswith(('.mp4', '.avi', '.mov', '.mkv')))
    
    # 如果根目录只有一个视频文件，则直接在原目录下处理，无需生成新目录
    if num_videos == 1:
        new_dir_path = dir_path
    else:
        # 否则，为处理后的视频创建一个新目录
        new_dir_path = dir_path + '_AFTER_FRAME_EXT'
        os.makedirs(new_dir_path, exist_ok=True)

    # 遍历目录中的文件和子目录
    for file_name in files:
        file_path = os.path.join(dir_path, file_name)
        if os.path.isfile(file_path):
            # 检查是否是视频文件
            if file_name.lower().endswith(('.mp4', '.avi', '.mov', '.mkv')):  
                # 处理视频文件
                try:
                    new_file_path = process_video(file_path, target_reduce_frames)
                    if new_file_path:
                        # 如果根目录只有一个视频文件，则将处理后的视频覆盖原视频文件
                        # 否则，将处理后的视频移动到新目录
                        if num_videos == 1:
                            shutil.move(new_file_path, file_path)
                        else:
                            shutil.move(new_file_path, new_dir_path)
                except MemoryError:
                    print(f"处理视频时内存不足: {file_name}")
            else:
                print(f"忽略非视频文件或已处理的视频: {file_name}")
        elif os.path.isdir(file_path):
            # 递归处理子目录
            process_directory(file_path, target_reduce_frames)

def process_directory(dir_path, target_reduce_frames):
    # 列出目录下的文件和子目录
    files = os.listdir(dir_path)
    num_videos = sum(1 for file_name in files if os.path.isfile(os.path.join(dir_path, file_name)) and file_name.lower().endswith(('.mp4', '.avi', '.mov', '.mkv')) and not file_name.endswith('_changed_fps_with_audio.mp4'))
    
    # 如果根目录只有一个视频文件，则直接在原目录下处理，无需生成新目录
    if num_videos == 1:
        new_dir_path = dir_path
    else:
        # 否则，为处理后的视频创建一个新目录
        new_dir_path = dir_path + '_AFTER_FRAME_EXT'
        os.makedirs(new_dir_path, exist_ok=True)

    # 遍历目录中的文件和子目录
    for file_name in files:
        file_path = os.path.join(dir_path, file_name)
        if os.path.isfile(file_path):
            # 检查是否是视频文件
            if file_name.lower().endswith(('.mp4', '.avi', '.mov', '.mkv')) and not file_name.endswith('_changed_fps_with_audio.mp4'):  
                # 处理视频文件
                new_file_path = process_video(file_path, target_reduce_frames)
                if new_file_path:
                    # 如果根目录只有一个视频文件，则将处理后的视频覆盖原视频文件
                    # 否则，将处理后的视频移动到新目录
                    if num_videos == 1:
                        shutil.move(new_file_path, file_path)
                    else:
                        shutil.move(new_file_path, new_dir_path)
            else:
                print(f"忽略非视频文件或已处理的视频: {file_name}")
        elif os.path.isdir(file_path):
            # 递归处理子目录
            process_directory(file_path, target_reduce_frames)

# Process the current directory
process_directory('.', 5)
# process_video("D:/Tools/AHKScript/VideoProess/test_video.mp4", 20)