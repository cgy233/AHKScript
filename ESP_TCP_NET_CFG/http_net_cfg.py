import requests

# 定义基础URL
base_url = "http://192.168.4.1:80"

# 发送GET请求
def send_get_request(endpoint):
	url = f"{base_url}/{endpoint}"
	try:
		response = requests.get(url, timeout=30)  # 设置超时时间为5秒
		return response
	except requests.exceptions.RequestException as e:
		print(f"GET request failed: {e}")
		return None

# 发送POST请求
def send_post_request(endpoint, data):
	url = f"{base_url}/{endpoint}"
	try:
		response = requests.post(url, data=data, timeout=30)  # 设置超时时间为5秒
		return response
	except requests.exceptions.RequestException as e:
		print(f"POST request failed: {e}")
		return None

# 示例调用
if __name__ == "__main__":
	print("Sending GET request...")
	get_response = send_get_request("get_nearby_ap_info")
	if get_response:
		print("GET Response:", get_response.text)
	else:
		print("GET request failed.")

	# print("Sending POST request...")
	# post_data = {"EthanHome": "cgy233.."}
	# post_response = send_post_request("ap_info", post_data)
	# if post_response:
	#     print("POST Response:", post_response.text)
	# else:
	#     print("POST request failed.")