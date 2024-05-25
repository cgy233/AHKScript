import os
import logging
from datetime import datetime
import paho.mqtt.client as mqtt
import threading
import json
import psutil
from time import sleep

# MQTT 服务器的地址和端口
broker = "cyupi.top"
port = 1883
sub_topic = "hass/ethanpc"
user_name = "hass"
passwd = "cgy233.."

# Set up logging
logging.basicConfig(
	filename='D:/Tools/AHKScript/MQ_Control/mqtt_client.log',
	level=logging.INFO,
	format='%(asctime)s: %(message)s',
	datefmt='%Y-%m-%d %H:%M:%S'
)

def is_process_running(process_name):
	for proc in psutil.process_iter():
		if proc.name() == process_name:
			return True
	return False

def hass_event(cmd):
	if cmd == "shutdown":
		logging.info("Shutting down the computer...")
		os.system("shutdown -s -t 0")
	if cmd == "apex":
		logging.info("Starting Apex Legends...")
		if not is_process_running("uu.exe"):
			os.system("start D:/Program/NetEase/UU/uu.exe")
		sleep(10)
		os.system("start steam://rungameid/1172470")
	if cmd == "csgo":
		logging.info("Starting CS:GO...")
		if not is_process_running("steam.exe"):
			os.system("start D:\Tools\AHKScript\steam_silent.lnk")
		os.system("start D:/Program/perfectworldarena/完美世界竞技平台.exe")

def parse_message(message):
	data = json.loads(message)
	cmd = data.get('cmd', None)
	return cmd

# 当接收到服务器发来的 CONNACK 响应时被调用
def on_connect(client, userdata, flags, rc):
	logging.info(f"Connected with result code {rc}")
	client.subscribe(sub_topic)

# 当接收到服务器发来的 PUBLISH 消息时被调用
def on_message(client, userdata, msg):
	logging.info(f"{msg.topic} {msg.payload}")
	hass_event(parse_message(msg.payload))

def start_mqtt_client():
	client = mqtt.Client()
	client.username_pw_set(user_name, password=passwd)
	client.on_connect = on_connect
	client.on_message = on_message

	client.connect(broker, port, 60)

	# 循环处理网络流量、调度回调函数、处理重新连接等任务
	client.loop_start()
	while True:
		pass

if __name__ == '__main__':
	start_mqtt_client()