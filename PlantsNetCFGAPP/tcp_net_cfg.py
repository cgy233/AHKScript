import socket
import json
import threading
import time

# 线程安全的标志，用来控制是否继续发送周期性命令
continue_sending_commands = threading.Event()
continue_sending_commands.set()  # 默认设置为True，继续发送命令

def receive_from_server(sock: socket.socket, ap_update_queue):
    """接收来自TCP服务器的信息并打印"""
    try:
        data_fragments = []  # 用于累积接收到的数据片段
        while True:
            data = sock.recv(1024).decode('utf-8')  # 假设数据是utf-8编码的
            if not data:
                print("服务器关闭连接")
                break  # 如果没有数据，意味着服务器关闭了连接

            data_fragments.append(data)
            buffer = ''.join(data_fragments)  # 将数据片段连接起来
            while "\n" in buffer:  # 检查是否收到了完整的消息
                message, _, buffer = buffer.partition("\n")  # 分离出完整的消息和剩余的片段
                data_fragments = [buffer]  # 重置数据片段列表，仅包含未处理的片段
                # 清理控制字符
                cleaned_message = message.strip().replace('\t', ' ')
                try:
                    message_json = json.loads(cleaned_message)
                    cmd = message_json.get("cmd")
                    if cmd == "ap_connect_success":
                        continue_sending_commands.clear()  # 收到特定命令，停止发送周期性命令
                        ap_update_queue.put(cleaned_message)  # 将AP信息放入队列
                        print("停止发送周期性命令")
                    elif cmd == "ap_info":
                        continue_sending_commands.clear()  # 收到特定命令，停止发送周期性命令
                        ap_update_queue.put(cleaned_message)  # 将AP信息放入队列
                    elif cmd == "ap_connect_fail":
                        continue_sending_commands.set()
                        ap_update_queue.put(cleaned_message)  # 将AP信息放入队列
                    elif cmd == "ap_cfg_start":
                        continue_sending_commands.set()
                        print("接收到的数据:", cleaned_message)
                        ap_update_queue.put(cleaned_message)  # 将AP信息放入队列
                except json.JSONDecodeError as e:
                    print(f"JSON解析错误: {e}")
    except Exception as e:
        print(f"接收数据时发生错误: {e}")

def connect_to_server(address, port, timeout=5):
    """连接到TCP服务器，并设置超时时间"""
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(timeout)  # 设置超时时间
        s.connect((address, port))
        s.settimeout(None)  # 连接成功后，清除超时设置，恢复到阻塞模式
        print("连接成功")
        return s
    except socket.timeout:
        print("连接超时")
        return None
    except Exception as e:
        print(f"连接失败: {e}")
        return None

def receive_command(s):
    """接收并解析命令"""
    try:
        data = s.recv(1024).decode('utf-8')
        command = json.loads(data)
        if command.get("cmd") == "ap_cfg_start":
            print("配网开始")
            return True
    except Exception as e:
        print(f"接收数据失败: {e}")
    return False

def send_scan_ap_info(s):
    """发送WiFi信息"""
    try:
        command = json.dumps({"cmd": "get_nearby_ap_info"})
        s.sendall(command.encode('utf-8'))
    except Exception as e:
        print(f"发送扫描AP指令失败: {e}")

def send_wifi_info(s, ssid, pwd):
    """发送WiFi信息"""
    try:
        wifi_info = json.dumps({"cmd": "ap_info", "ssid": ssid, "pwd": pwd})
        s.sendall(wifi_info.encode('utf-8'))
    except Exception as e:
        print(f"发送WiFi信息失败: {e}")

def main():
    server_address = '192.168.4.1'
    server_port = 8080

    # 连接服务器
    s = connect_to_server(server_address, server_port)
    if s is None:
        return

    # 接收命令并解析
    if receive_command(s):
        # 用户输入WiFi信息
        ssid = input("请输入WiFi的SSID: ")
        pwd = input("请输入WiFi密码: ")
        # 发送WiFi信息
        send_wifi_info(s, ssid, pwd)

    s.close()

def send_periodic_commands(s):
    """每隔6秒发送一次命令"""
    command = json.dumps({"cmd": "get_nearby_ap_info"})
    while continue_sending_commands.is_set():
        try:
            s.sendall(command.encode('utf-8'))
            print("命令发送成功")
        except Exception as e:
            print(f"发送命令失败: {e}")
            break
        time.sleep(10)

def main():
    server_address = '192.168.4.1'
    server_port = 8080

    # 连接服务器
    s = connect_to_server(server_address, server_port)
    if s is None:
        return

    # 启动线程发送命令
    thread = threading.Thread(target=send_periodic_commands, args=(s,))
    thread.start()

    # 接收命令并解析
    if receive_command(s):
        # 用户输入WiFi信息
        ssid = input("请输入WiFi的SSID: ")
        pwd = input("请输入WiFi密码: ")
        # 发送WiFi信息
        send_wifi_info(s, ssid, pwd)

    s.close()

if __name__ == "__main__":
    main()