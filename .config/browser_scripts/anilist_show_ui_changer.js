// ==UserScript==
// @name         Better Anilist UI/UX
// @namespace    http://tampermonkey.net/
// @version      2026-05-09
// @description  Surface average/mean score and the Following list at the top of anime/manga pages.
// @author       You
// @match        https://anilist.co/anime/*
// @match        https://anilist.co/manga/*
// @icon         https://www.google.com/s2/favicons?sz=64&domain=anilist.co
// @grant        none
// ==/UserScript==

(function () {
    'use strict';

    const TAG = 'bauux'; // Better Anilist UI/UX
    const BANNER_ID = `${TAG}-banner`;
    const FOLLOWING_ATTR = `data-${TAG}-following`;

    function applyOverviewLayout(overview) {
        if (overview.style.display !== 'flex') overview.style.display = 'flex';
        if (overview.style.flexDirection !== 'column') overview.style.flexDirection = 'column';
    }

    function getSidebarValue(label) {
        const dataSets = document.querySelectorAll('.sidebar .data-set');
        for (const ds of dataSets) {
            const type = ds.querySelector('.type');
            const value = ds.querySelector('.value');
            if (type && value && type.textContent.trim() === label) {
                return value.textContent.trim();
            }
        }
        return null;
    }

    function getAuthUsername() {
        const link = document.querySelector('a.primary-link[href^="/user/"]');
        if (!link) return null;
        const m = link.getAttribute('href').match(/^\/user\/([^/]+)\/?$/);
        return m ? decodeURIComponent(m[1]) : null;
    }

    function getMyScore() {
        const name = getAuthUsername();
        if (!name) return null;
        const followList = document.querySelector('.overview .following');
        if (!followList) return null;
        const cards = followList.querySelectorAll('a.follow');
        for (const card of cards) {
            const nameEl = card.querySelector('.name');
            if (!nameEl || nameEl.textContent.trim() !== name) continue;
            const scoreSpan = card.querySelector(':scope > span');
            if (!scoreSpan) return null;
            const text = scoreSpan.textContent.trim();
            return text || null;
        }
        return null;
    }

    function ensureStat(banner, key, label, value) {
        const attr = `data-${TAG}-stat`;
        let tile = banner.querySelector(`[${attr}="${key}"]`);
        if (!tile) {
            tile = document.createElement('div');
            tile.setAttribute(attr, key);
            tile.style.cssText = 'flex: 1; text-align: center; min-width: 0;';
            const labelEl = document.createElement('div');
            labelEl.className = `${TAG}-stat-label`;
            labelEl.textContent = label;
            labelEl.style.cssText =
                'font-size: 12px; color: rgb(146, 160, 173); text-transform: uppercase; letter-spacing: 1.5px;';
            const valueEl = document.createElement('div');
            valueEl.className = `${TAG}-stat-value`;
            valueEl.style.cssText =
                'font-size: 36px; font-weight: 700; color: rgb(61, 180, 242); margin-top: 4px; line-height: 1;';
            tile.appendChild(labelEl);
            tile.appendChild(valueEl);
            banner.appendChild(tile);
        }
        const valueEl = tile.querySelector(`.${TAG}-stat-value`);
        if (valueEl.textContent !== value) valueEl.textContent = value;
    }

    function ensureBanner(overview) {
        let banner = overview.querySelector(`#${BANNER_ID}`);
        if (banner) return banner;
        banner = document.createElement('div');
        banner.id = BANNER_ID;
        banner.style.cssText = `
            display: flex;
            gap: 16px;
            margin-bottom: 24px;
            padding: 18px 20px;
            background: rgba(61, 180, 242, 0.08);
            border-radius: 8px;
            border-left: 4px solid rgb(61, 180, 242);
            align-items: center;
            order: -2;
        `;
        overview.prepend(banner);
        return banner;
    }

    function syncScoreBanner(overview) {
        const stats = [];
        const avgScore = getSidebarValue('Average Score');
        const meanScore = getSidebarValue('Mean Score');
        const myScore = getMyScore();
        if (avgScore) stats.push({ key: 'avg', label: 'Average Score', value: avgScore });
        if (meanScore) stats.push({ key: 'mean', label: 'Mean Score', value: meanScore });
        if (myScore) stats.push({ key: 'my', label: 'My Score', value: myScore });

        const existing = overview.querySelector(`#${BANNER_ID}`);
        if (stats.length === 0) {
            if (existing) existing.remove();
            return;
        }

        const banner = ensureBanner(overview);
        const wantedKeys = new Set(stats.map((s) => s.key));
        banner.querySelectorAll(`[data-${TAG}-stat]`).forEach((tile) => {
            if (!wantedKeys.has(tile.getAttribute(`data-${TAG}-stat`))) {
                tile.remove();
            }
        });
        stats.forEach((s) => ensureStat(banner, s.key, s.label, s.value));
    }

    function findFollowingDirectChild(overview) {
        const headings = overview.querySelectorAll('h2');
        for (const h of headings) {
            if (h.textContent.trim() !== 'Following') continue;
            // The Following Vue component lives inside <div class="grid-section-wrap">
            // which is the direct child of .overview that we can flex-order.
            return h.closest('.grid-section-wrap') || h.parentElement;
        }
        return null;
    }

    function markFollowingForReorder(overview) {
        const current = findFollowingDirectChild(overview);
        // Clear stale marker if Vue swapped the element
        const marked = overview.querySelector(`[${FOLLOWING_ATTR}]`);
        if (marked && marked !== current) {
            marked.removeAttribute(FOLLOWING_ATTR);
            marked.style.order = '';
        }
        if (current) {
            if (!current.hasAttribute(FOLLOWING_ATTR)) {
                current.setAttribute(FOLLOWING_ATTR, '');
            }
            if (current.style.order !== '-1') current.style.order = '-1';
        }
    }

    let lastUrl = location.href;

    function apply() {
        if (location.href !== lastUrl) {
            lastUrl = location.href;
            const oldBanner = document.getElementById(BANNER_ID);
            if (oldBanner) oldBanner.remove();
        }
        const overview = document.querySelector('.overview');
        if (!overview) return;
        applyOverviewLayout(overview);
        syncScoreBanner(overview);
        markFollowingForReorder(overview);
    }

    let timer;
    function debouncedApply() {
        clearTimeout(timer);
        timer = setTimeout(apply, 250);
    }

    const observer = new MutationObserver(debouncedApply);
    observer.observe(document.body, {
        childList: true,
        subtree: true,
        characterData: true,
    });

    // SPA navigation hook: history mutations don't fire popstate, so patch them.
    function onNavigate() {
        const oldBanner = document.getElementById(BANNER_ID);
        if (oldBanner) oldBanner.remove();
        // Poll for a few seconds in case new data loads after the observer settles.
        let attempts = 0;
        const poll = setInterval(() => {
            apply();
            if (++attempts >= 12) clearInterval(poll); // ~6s
        }, 500);
    }

    (function patchHistory() {
        const fire = () => window.dispatchEvent(new Event(`${TAG}:nav`));
        ['pushState', 'replaceState'].forEach((key) => {
            const orig = history[key];
            history[key] = function (...args) {
                const ret = orig.apply(this, args);
                fire();
                return ret;
            };
        });
        window.addEventListener('popstate', fire);
        window.addEventListener(`${TAG}:nav`, onNavigate);
    })();

    debouncedApply();
})();
