// ==UserScript==

// @name         Safari Video Auto Fullscreen

// @namespace    http://tampermonkey.net/

// @version      0.2

// @description  播放网页视频时自动调用系统播放器（Safari专用）

// @author       Ethan

// @match        *://*/*

// @grant        none

// ==/UserScript==

(function() {
    'use strict';

    // 配置选项
    const config = {
        autoFullscreen: true,        // 是否自动全屏
        retryTimes: 3,               // 全屏失败重试次数
        retryInterval: 1000,         // 重试间隔（毫秒）
        triggerEvents: ['play', 'click', 'dblclick'], // 触发全屏的事件
        excludeSelectors: [          // 排除的选择器
            '.no-fullscreen',
            '[data-no-fullscreen]'
        ]
    };

    function isExcluded(video) {
        return config.excludeSelectors.some(selector => 
            video.matches(selector) || video.closest(selector)
        );
    }

    function enableFullscreen(video, retryCount = 0) {
        if (isExcluded(video)) return;
        
        try {
            if (video.webkitEnterFullscreen) {
                video.webkitEnterFullscreen();
            } else if (video.requestFullscreen) {
                video.requestFullscreen();
            }
        } catch (error) {
            console.warn('全屏失败:', error);
            if (retryCount < config.retryTimes) {
                setTimeout(() => {
                    enableFullscreen(video, retryCount + 1);
                }, config.retryInterval);
            }
        }
    }

    function attachListener(video) {
        if (video._hasListener) return;
        video._hasListener = true;

        config.triggerEvents.forEach(eventType => {
            video.addEventListener(eventType, function() {
                if (config.autoFullscreen) {
                    enableFullscreen(video);
                }
            });
        });

        // 监听视频状态变化
        video.addEventListener('loadedmetadata', function() {
            if (config.autoFullscreen && video.readyState >= 2) {
                enableFullscreen(video);
            }
        });
    }

    function findVideos() {
        document.querySelectorAll('video').forEach(attachListener);
    }

    // 初始寻找
    findVideos();

    // 动态监听网页变化
    const observer = new MutationObserver(mutations => {
        for (const mutation of mutations) {
            for (const node of mutation.addedNodes) {
                if (node.tagName === 'VIDEO') {
                    attachListener(node);
                } else if (node.querySelectorAll) {
                    node.querySelectorAll('video').forEach(attachListener);
                }
            }
        }
    });

    observer.observe(document.body, { 
        childList: true, 
        subtree: true 
    });

    // 添加配置修改接口
    window.SafariAutoFullScreen = {
        setConfig: (newConfig) => {
            Object.assign(config, newConfig);
        },
        getConfig: () => ({...config}),
        enable: () => {
            config.autoFullscreen = true;
        },
        disable: () => {
            config.autoFullscreen = false;
        }
    };
})();


