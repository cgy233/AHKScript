import paramiko
import requests

def get_ipv6_public_address():
    try:
        # 发送HTTP请求获取IPv6地址
        response = requests.get("https://ipv6.ddnspod.com", timeout=10)
        if response.status_code == 200:
            ipv6_address = response.text.strip()
            return ipv6_address
        else:
            print("Failed to get IPv6 address - HTTP response code:", response.status_code)
            return None
    except Exception as e:
        print("Error:", e)
        return None

def update_remote_ipv6_file(ipv6_address):
    try:
        # SSH 连接参数
        ssh_host = '192.168.2.2'
        ssh_port = 22
        ssh_username = 'root'
        
        # 创建 SSH 客户端
        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        
        # 连接到远程服务器
        ssh_client.connect(ssh_host, ssh_port, ssh_username)
        
        # 执行命令将 IPv6 地址写入到文件中
        ssh_command = f"echo {ipv6_address} > /root/script/ipv6.txt"
        stdin, stdout, stderr = ssh_client.exec_command(ssh_command)
        
        # 关闭 SSH 连接
        ssh_client.close()
        
        print("IPv6 address updated on remote server:", ipv6_address)
    except Exception as e:
        print("Error updating IPv6 file on remote server:", e)

def main():
    # previous_ipv6 = None
    # while True:
    #     current_ipv6 = get_ipv6_public_address()
    #     if current_ipv6 and current_ipv6 != previous_ipv6:
    #         update_remote_ipv6_file(current_ipv6)
    #         previous_ipv6 = current_ipv6
    #     time.sleep(60)  # 每隔一分钟检查一次
	current_ipv6 = get_ipv6_public_address()
	update_remote_ipv6_file(current_ipv6)

if __name__ == "__main__":
    main()
