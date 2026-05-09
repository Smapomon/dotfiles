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
    const MOVED_ATTR = `data-${TAG}-moved`;

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

    function buildStat(label, value) {
        const stat = document.createElement('div');
        stat.style.cssText = 'flex: 1; text-align: center; min-width: 0;';
        const labelEl = document.createElement('div');
        labelEl.textContent = label;
        labelEl.style.cssText =
            'font-size: 12px; color: rgb(146, 160, 173); text-transform: uppercase; letter-spacing: 1.5px;';
        const valueEl = document.createElement('div');
        valueEl.textContent = value;
        valueEl.style.cssText =
            'font-size: 36px; font-weight: 700; color: rgb(61, 180, 242); margin-top: 4px; line-height: 1;';
        stat.appendChild(labelEl);
        stat.appendChild(valueEl);
        return stat;
    }

    function injectScoreBanner(overview) {
        if (overview.querySelector(`#${BANNER_ID}`)) return;

        const avgScore = getSidebarValue('Average Score');
        const meanScore = getSidebarValue('Mean Score');
        if (!avgScore && !meanScore) return;

        const banner = document.createElement('div');
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
        `;

        if (avgScore) banner.appendChild(buildStat('Average Score', avgScore));
        if (meanScore) banner.appendChild(buildStat('Mean Score', meanScore));

        overview.prepend(banner);
    }

    function findFollowingContainer(overview) {
        const headings = overview.querySelectorAll('h2');
        for (const h of headings) {
            if (h.textContent.trim() === 'Following') {
                return h.parentElement;
            }
        }
        return null;
    }

    function moveFollowingUp(overview) {
        const followingContainer = findFollowingContainer(overview);
        if (!followingContainer) return;

        const banner = overview.querySelector(`#${BANNER_ID}`);
        const expectedPrev = banner || null;

        if (followingContainer.previousElementSibling === expectedPrev) return;

        followingContainer.setAttribute(MOVED_ATTR, '1');
        if (banner) {
            banner.after(followingContainer);
        } else {
            overview.prepend(followingContainer);
        }
    }

    function apply() {
        const overview = document.querySelector('.overview');
        if (!overview) return;
        injectScoreBanner(overview);
        moveFollowingUp(overview);
    }

    let timer;
    function debouncedApply() {
        clearTimeout(timer);
        timer = setTimeout(apply, 250);
    }

    const observer = new MutationObserver(debouncedApply);
    observer.observe(document.body, { childList: true, subtree: true });

    debouncedApply();
})();
