import queue
import tkinter as tk
from tkinter import ttk
from tkinter import messagebox
import tcp_net_cfg
import threading
import sys
import json

tcp_server_address = '192.168.4.1'
tcp_server_port = 8080
threads = []  # 跟踪所有线程

def check_ap_update_queue():
    try:
        while not ap_update_queue.empty():
            ap_data = ap_update_queue.get_nowait()
            json_data = json.loads(ap_data)
            print(ap_data)
            if json_data.get("cmd") == "ap_info":
                update_ap_list(ap_data)  # 调用原有的更新GUI的函数
            elif json_data.get("cmd") == "ap_cfg_start":
                messagebox.showinfo("配网通知", "配网开始")
                net_cfg_status_button.config(text="配网状态: 等待下发配网信息", fg="blue")
            elif json_data.get("cmd") == "ap_connect_success":

                cur_wifi_ssid = ssid_entry.get()
                messagebox.showinfo("配网通知", f"{cur_wifi_ssid}连接成功")
                net_cfg_status_button.config(text="配网状态: 配网成功", fg="green")
            elif json_data.get("cmd") == "ap_connect_fail":
                cur_wifi_ssid = ssid_entry.get()
                messagebox.showerror("配网通知", f"{cur_wifi_ssid}连接失败")
                net_cfg_status_button.config(text="配网状态: 配网失败", fg="red")
    except queue.Empty:
        pass
    root.after(100, check_ap_update_queue)  # 每100ms检查一次队列

def update_ap_list(ap_data):
    """更新AP信息列表到表格"""
    try:
        ap_list = json.loads(ap_data).get("apList", [])
        sorted_ap_list = sorted(ap_list, key=lambda x: x["rssi"], reverse=True)  # 按RSSI值排序
        
        # 清空当前表格内容
        for item in ap_treeview.get_children():
            ap_treeview.delete(item)
        
        # 填充表格
        for ap in sorted_ap_list:
            ap_treeview.insert('', tk.END, values=(ap['ssid'], ap['rssi']))
        
        # 如果不足20个，用空项填充（可选，根据需要决定是否需要）
        for _ in range(20 - len(sorted_ap_list)):
            ap_treeview.insert('', tk.END, values=("", ""))
            
    except json.JSONDecodeError:
        print("解析AP信息失败")
        print("无法解析的数据:", ap_data)  # 添加的调试信息

def disconnect_server():
    """断开与TCP服务器的连接"""
    global server_socket
    if server_socket:
        server_socket.close()  # 假设这是断开连接的方法
        server_socket = None
        messagebox.showinfo("连接结果", "已断开连接")
        status_button.config(text="TCP服务器状态: 未连接", fg="red")
    else:
        messagebox.showerror("断开结果", "当前无连接")

def connect_server():
    global server_socket
    server_socket = tcp_net_cfg.connect_to_server(tcp_server_address, tcp_server_port)
    if server_socket:
        messagebox.showinfo("连接结果", "连接成功")
        status_button.config(text="TCP服务器状态: 已连接", fg="green")
        # 启动一个线程来发送周期性命令
        send_thread = threading.Thread(target=tcp_net_cfg.send_periodic_commands, args=(server_socket,), daemon=True)
        send_thread.start()
        threads.append(send_thread)
        # 启动另一个线程来接收服务器的信息
        # 启动接收线程时传递队列
        receive_thread = threading.Thread(target=tcp_net_cfg.receive_from_server, args=(server_socket, ap_update_queue), daemon=True)
        receive_thread.start()
        threads.append(receive_thread)
    else:
        messagebox.showerror("连接结果", "连接失败")

def send_wifi_info():
    global ssid_entry, pwd_entry
    ssid = ssid_entry.get()
    pwd = pwd_entry.get()
    if server_socket and ssid and pwd:
        tcp_net_cfg.send_wifi_info(server_socket, ssid, pwd)
        messagebox.showinfo("发送结果", "WiFi信息已发送")
    else:
        messagebox.showerror("发送结果", "发送失败，请确保已连接服务器且输入有效")

def scan_nearby_ap_info():
    tcp_net_cfg.send_scan_ap_info(server_socket)

def on_closing():
    """关闭所有线程然后退出程序"""
    root.destroy()  # 关闭窗口
    sys.exit()  # 完全退出程序

# 创建GUI界面
root = tk.Tk()
root.title("植生机网络配置工具")

ap_update_queue = queue.Queue()

# Set window size and position
window_width = 900
window_height = 300
screen_width = root.winfo_screenwidth()
screen_height = root.winfo_screenheight()
center_x = int(screen_width/2 - window_width / 2)
center_y = int(screen_height/2 - window_height / 2)
root.geometry(f'{window_width}x{window_height}+{center_x}+{center_y}')

# AP信息列表区域
ap_info_frame = tk.Frame(root)
ap_info_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=10)

# 创建表格
columns = ('ssid', 'rssi')
ap_treeview = ttk.Treeview(ap_info_frame, columns=columns, show='headings')
ap_treeview.heading('ssid', text='SSID')
ap_treeview.heading('rssi', text='RSSI')

ap_treeview.column('ssid', anchor='center')
ap_treeview.column('rssi', anchor='center')

# 添加勾选框列
ap_treeview.column("#0", width=20, anchor='center')
ap_treeview.heading("#0", text='')

# 单选逻辑
def on_item_checked(event):
    for item in ap_treeview.get_children():
        ap_treeview.item(item, tags=())
    ssid = ap_treeview.item(ap_treeview.focus())['values'][0]
    ssid_entry.delete(0, tk.END)
    ssid_entry.insert(0, ssid)
    ap_treeview.item(ap_treeview.focus(), tags=('checked',))

ap_treeview.tag_configure('checked', background='lightgray')
ap_treeview.bind('<ButtonRelease-1>', on_item_checked)

ap_treeview.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

# 添加滚动条
scrollbar = tk.Scrollbar(ap_info_frame, orient=tk.VERTICAL, command=ap_treeview.yview)
ap_treeview.configure(yscroll=scrollbar.set)
scrollbar.pack(side=tk.RIGHT, fill=tk.Y)

# WiFi信息输入区域
ssid_label = tk.Label(root, text="SSID:")
ssid_label.pack()
ssid_entry = tk.Entry(root)
ssid_entry.pack()

pwd_label = tk.Label(root, text="密码:")
pwd_label.pack()
pwd_entry = tk.Entry(root, show="*")
pwd_entry.pack()

# 创建按钮容器
button_frame = tk.Frame(root)
button_frame.pack(pady=10)

# 连接服务器按钮
connect_button = tk.Button(button_frame, text="连接TCP服务器", command=connect_server)
connect_button.pack(side=tk.LEFT, padx=5)

# 创建状态显示按钮的容器
status_frame = tk.Frame(root)
status_frame.pack(pady=5)

# TCP服务器状态按钮
status_button = tk.Button(status_frame, text="TCP服务器状态: 未连接", fg="red")
status_button.pack(side=tk.LEFT, padx=5)

# 配网状态按钮
net_cfg_status_button = tk.Button(status_frame, text="配网状态: 未连接", fg="red")
net_cfg_status_button.pack(side=tk.LEFT, padx=5)

disconnect_button = tk.Button(button_frame, text="断开TCP服务器", command=disconnect_server)
disconnect_button.pack(side=tk.LEFT, padx=5)

# 发送扫描指令按钮
wifi_button = tk.Button(button_frame, text="扫描附近的AP", command=scan_nearby_ap_info)
wifi_button.pack(side=tk.LEFT, padx=5)

# 发送WiFi信息按钮
send_button = tk.Button(button_frame, text="发送WiFi信息", command=send_wifi_info)
send_button.pack(side=tk.LEFT, padx=5)

root.protocol("WM_DELETE_WINDOW", on_closing)
root.after(100, check_ap_update_queue)

if __name__ == "__main__":
    root.mainloop()