import os
import subprocess
import json

def find_video_files(directory, extensions=['.mp4', '.avi', '.mov', '.mkv']):
    video_files = []
    for root, _, files in os.walk(directory):
        for file in files:
            if any(file.lower().endswith(ext) for ext in extensions):
                video_files.append(os.path.join(root, file))
    return video_files

def get_video_info(file_path):
    cmd = [
        'ffprobe', '-v', 'quiet', '-print_format', 'json', '-show_streams', file_path
    ]
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    video_info = json.loads(result.stdout)

    # Find the first video stream and return its frame rate and bit rate
    for stream in video_info['streams']:
        if stream['codec_type'] == 'video':
            r_frame_rate = stream['r_frame_rate']
            frame_rate = eval(r_frame_rate)
            bit_rate = int(stream['bit_rate']) if 'bit_rate' in stream else None
            return frame_rate, bit_rate

    raise Exception('No video stream found')

def process_video_fixed_bit_rate(file_path, target_fps):
    output_file = file_path.rsplit('.', 1)[0] + f'_fps_{target_fps}.' + file_path.rsplit('.', 1)[1]
    ffmpeg_cmd = [
        'ffmpeg', '-y', '-i', file_path,
        '-vf', f'fps={target_fps}', '-c:v', 'h264_nvenc', '-b:v', '5M', '-c:a', 'aac', output_file
    ]
    subprocess.run(ffmpeg_cmd, check=True)
    print(f"Processed video saved to: {output_file}")

def process_video(file_path, target_fps_diff):
    frame_rate, bit_rate = get_video_info(file_path)
    target_fps = frame_rate - target_fps_diff

    # Check if the target frame rate is valid
    target_fps = frame_rate - target_fps_diff
    if target_fps <= 0:
        print(f"目标帧率必须大于0，但给定的目标帧率是: {target_fps}")
        return

    print(f"原视频帧率: {frame_rate}")
    print(f"目标帧率: {target_fps}")

    # Estimate processing time
    cmd = ['ffprobe', '-v', 'error', '-select_streams', 'v:0', '-show_entries', 'stream=nb_frames', '-of', 'default=nokey=1:noprint_wrappers=1', file_path]
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    total_frames = int(result.stdout or 0)
    estimated_time = total_frames / target_fps
    print(f"预计处理时间: {estimated_time} 秒")

    output_file = file_path.rsplit('.', 1)[0] + f'_fps_{target_fps}.' + file_path.rsplit('.', 1)[1]
    ffmpeg_cmd = [
        'ffmpeg', '-y', '-i', file_path,
        '-vf', f'fps={target_fps}', '-c:v', 'h264_nvenc', '-b:v', f'{bit_rate}k', '-c:a', 'aac', output_file
    ]

    import time
    start_time = time.time()
    subprocess.run(ffmpeg_cmd, check=True)
    end_time = time.time()

    print(f"实际处理完成时间: {end_time - start_time} 秒")
    print(f"处理后的视频保存在: {output_file}")

def process_directory(directory, target_fps):
    video_files = find_video_files(directory)
    for video_file in video_files:
        process_video(video_file, target_fps)

# Example usage
process_directory('.', 5)

