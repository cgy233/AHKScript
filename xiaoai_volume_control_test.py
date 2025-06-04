import paho.mqtt.publish as publish
import json
from pynput import keyboard
import time

server_address = ""
mqtt_topic = ""

# 上一次的旋钮值
last_knob_value = 0

# 上一次的音量值
last_volume_value = 0

# 定义每次变化的幅度
volume_change_step = 2

def set_xiaoai_volume(volume):
	# 检查volume的范围，确保在0.0到1.0之间
	volume = max(0, min(100, volume))/100

	# 构建消息内容
	message = {
		"volume": volume
	}

	# 将消息内容转换为JSON格式
	payload = json.dumps(message)

	# 发送MQTT消息
	try:
		publish.single(mqtt_topic, payload=payload, hostname=server_address, port=1883, qos=1)
		print(f"Send Msg Success: {payload}")
	except Exception as e:
		print(f"Err: {e}")

def on_press(key):
	global last_volume_value 

	print(f"Key pressed: {key}")
	try:
		if key == keyboard.Key.media_volume_up:
		# if key == keyboard.Key.up:
			if last_volume_value >= 100:
				last_volume_value = 100
			else:
				last_volume_value += volume_change_step
		elif key == keyboard.Key.media_volume_down:
		# elif key == keyboard.Key.down:
			if last_volume_value <= 0:
				last_volume_value = 0
			else:
				last_volume_value -= volume_change_step
		else:
			return

		# 发送音量消息
		set_xiaoai_volume(last_volume_value)
	except AttributeError:
		# 如果按键不是字符，输出完整的按键事件信息
		print(f"Other key pressed: {key}")

if __name__ == '__main__':
	# 启动监听
	with keyboard.Listener(on_press=on_press) as listener:
		listener.join()
	# while True:
	# 	on_press(keyboard.Key.up)
	# 	time.sleep(1)
	# 	on_press(keyboard.Key.down)
	# 	time.sleep(1)
	# set_xiaoai_volume(100)
