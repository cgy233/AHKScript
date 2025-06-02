// ==UserScript==
// @name         Chat Auto Sender (DeepSeek)
// @namespace    http://tampermonkey.net/
// @version      1.2
// @description  从URL参数发送聊天，支持DeepSeek
// @match        https://chat.deepseek.com/*
// @grant        none
// ==/UserScript==

(function() {
    'use strict';

    function getQueryParam(name) {
        const urlParams = new URLSearchParams(window.location.search);
        return urlParams.get(name);
    }

    async function waitForElement(selector, timeout = 15000) {
        return new Promise((resolve, reject) => {
            const interval = 100;
            let elapsed = 0;
            const timer = setInterval(() => {
                const element = document.querySelector(selector);
                if (element) {
                    clearInterval(timer);
                    resolve(element);
                } else if (elapsed >= timeout) {
                    clearInterval(timer);
                    reject(new Error('元素超时未找到'));
                }
                elapsed += interval;
            }, interval);
        });
    }

    function setInputValueReactCompatible(inputElement, newValue) {
        const nativeInputValueSetter = Object.getOwnPropertyDescriptor(window.HTMLTextAreaElement.prototype, 'value').set;
        nativeInputValueSetter.call(inputElement, newValue);

        const event = new Event('input', { bubbles: true });
        inputElement.dispatchEvent(event);
    }

    async function autoSend() {
        const content = getQueryParam('content');
        if (!content) return;

        console.log('检测到content参数：', content);

        try {
            await sendDeepSeek(content);

            // 发送完清理参数
            const url = new URL(window.location);
            url.searchParams.delete('content');
            window.history.replaceState({}, document.title, url.toString());

        } catch (e) {
            console.error('自动发送失败', e);
        }
    }

    async function sendDeepSeek(content) {
        console.log('处理 DeepSeek...');
        const textarea = await waitForElement('textarea');
        setInputValueReactCompatible(textarea, content);

        await new Promise(r => setTimeout(r, 300));

        const sendButton = document.querySelector('button[type="submit"]');
        if (sendButton && !sendButton.disabled) {
            sendButton.click();
        } else {
            textarea.dispatchEvent(new KeyboardEvent('keydown', { key: 'Enter', code: 'Enter', bubbles: true }));
        }
    }

    window.addEventListener('load', autoSend);

})();
