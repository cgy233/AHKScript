import paho.mqtt.publish as publish
import json
import sys

server_address = ""
mqtt_topic = ""

def set_xiaoai_volume(volume):
    # 检查volume的范围，确保在0.0到1.0之间
    volume = max(1, min(100, volume))/100

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

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python xiaomi_volume_control.py <volume>")
    else:
        try:
            volume_value = float(sys.argv[1])
            set_xiaoai_volume(volume_value)
        except ValueError:
            print("Error: Volume must be a number.")

