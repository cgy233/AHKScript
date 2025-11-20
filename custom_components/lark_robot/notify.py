"""Dintalkrobot"""
import logging
import json

import requests
import voluptuous as vol

headers = {"Content-Type": "application/json"}
from homeassistant.components.notify import (
    BaseNotificationService, PLATFORM_SCHEMA)
from homeassistant.const import CONF_RESOURCE
import homeassistant.helpers.config_validation as cv


PLATFORM_SCHEMA = PLATFORM_SCHEMA.extend({
    vol.Required(CONF_RESOURCE): cv.url,
})

_LOGGER = logging.getLogger(__name__)


def get_service(hass, config, discovery_info=None):
 
    resource = config.get(CONF_RESOURCE)

    return LarkNotificationService(resource)


class LarkNotificationService(BaseNotificationService):
    

    def __init__(self, resource):
      
        self._resource = resource

    def send_message(self, message="", **kwargs):
       
        data = {
            'title': kwargs.get('title'),
            'text': message
        }

        to_send = json.dumps(data)

        response = requests.post(self._resource, data=to_send, headers = headers)

        if response.status_code not in (200, 201):
            _LOGGER.exception(
                "Error sending message. Response %d: %s:",
                response.status_code, response.reason)
