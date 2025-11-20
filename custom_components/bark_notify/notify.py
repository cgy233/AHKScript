"""Bark Notify platform for Home Assistant.

参考 dingtalk_robot 的 notify.py 风格实现：
- 使用 PLATFORM_SCHEMA.extend
- 使用同步 get_service
- 通过 CONF_RESOURCE 配置推送 URL
"""

import logging
import json

import requests
import voluptuous as vol
import homeassistant.helpers.config_validation as cv
from homeassistant.components.notify import BaseNotificationService, PLATFORM_SCHEMA
from homeassistant.const import CONF_RESOURCE


_LOGGER = logging.getLogger(__name__)

headers = {"Content-Type": "application/json"}

CONF_KEY = "key"  # Bark 设备 key（device_key）

# Optional data keys supported by Bark
DATA_ICON = "icon"
DATA_SOUND = "sound"
DATA_LEVEL = "level"  # active | timeSensitive | passive
DATA_GROUP = "group"
DATA_URL = "url"


PLATFORM_SCHEMA = PLATFORM_SCHEMA.extend({
    vol.Required(CONF_RESOURCE): cv.url,  # 例如 https://api.day.app/push
    vol.Required(CONF_KEY): cv.string,
})


def get_service(hass, config, discovery_info=None):
    resource = config.get(CONF_RESOURCE)
    key = config.get(CONF_KEY)
    return BarkNotificationService(resource, key)


class BarkNotificationService(BaseNotificationService):

    def __init__(self, resource, key):
        self._resource = resource
        self._key = key

    def send_message(self, message="", **kwargs):
        title = kwargs.get('title')
        data = kwargs.get('data') or {}

        payload = {
            'device_key': self._key,
            'body': message,
        }
        if title:
            payload['title'] = title

        # Map optional Bark parameters
        if DATA_ICON in data:
            payload[DATA_ICON] = data[DATA_ICON]
        if DATA_SOUND in data:
            payload[DATA_SOUND] = data[DATA_SOUND]
        if DATA_LEVEL in data:
            payload[DATA_LEVEL] = data[DATA_LEVEL]
        if DATA_GROUP in data:
            payload[DATA_GROUP] = data[DATA_GROUP]
        if DATA_URL in data:
            payload[DATA_URL] = data[DATA_URL]

        to_send = json.dumps(payload)

        try:
            response = requests.post(self._resource, data=to_send, headers=headers)
        except requests.RequestException as exc:
            _LOGGER.exception("Error sending message to Bark: %s", exc)
            return

        if response.status_code not in (200, 201):
            _LOGGER.exception(
                "Error sending message. Response %d: %s:",
                response.status_code, response.reason)
        else:
            _LOGGER.info("Bark Notify success: %s", response.text)


# ------------------------------------------------------------
# 扩展说明（非执行代码，仅为维护者指引）
# 1) 如何添加 ciphertext 加密参数：
#    - 在 payload 中增加 'ciphertext' 字段即可（或根据你的服务端实现），
#      可在 send_message 中从 data.get('ciphertext') 并赋值到 payload。
#    - 若需 AES-GCM 等本地加密，可引入加密库，将 message/title 加密为 ciphertext。
#
# 2) 如何扩展为多 Key 支持：
#    - __init__ 接收 List[str] keys，或在配置允许 'keys: [k1, k2]'。
#    - send_message 中循环发送并记录结果。
#
# 3) 如何添加批量推送逻辑：
#    - 在 data 中允许 'targets: [{key, resource}, ...]'。
#    - 遍历 targets 逐一构造 payload 并 POST，汇总日志。
# ------------------------------------------------------------


