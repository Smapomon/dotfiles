// **Script Info**
// This script is for highlighting the anime cards on anichart.net
// It will highlight the cards based on the color of the highlighter selected
// It will also provide a button to toggle the visibility of non-highlighted cards
//
// to use the script, install tampermonkey extension in your browser
//
// go to extenstions settings, click tampermonkey details, click allow access to file URLs
//
// create a new script amd add the commented line below as the last line in UserScript section
// @require        file:///path/to/anichart_highlighter.js
// **/Script Info**

(function() {
    'use strict';

    // Limit rapid calls
    function debounce(func, timeout = 100) {
        let timer;
        return (...args) => {
            clearTimeout(timer);
            timer = setTimeout(() => { func.apply(this, args); }, timeout);
        };
    }

    // Toggle visibility of cards without highlights
    let toggleState = false; // default state

    function toggleCardsVisibility() {
        document.querySelectorAll('.media-card').forEach(card => {
            const hasHighlight = card.querySelector('.highlighter.active');
            if (toggleState) {
                card.style.display = hasHighlight ? '' : 'none'; // Hide if no highlight
            } else {
                card.style.display = ''; // Show all cards
            }
        });
    }

    // Highlighting wrapped in a debouncer to make less useless changes
    const applyHighlightColorDebounced = debounce(function() {
        document.querySelectorAll('.highlighter.active').forEach(innerDiv => {
            let currentElement = innerDiv.closest('.media-card');

            if (currentElement) {
                const highlightColor = getComputedStyle(innerDiv).getPropertyValue('--highlight-color').trim();
                currentElement.style.border = `2px solid ${highlightColor}`;
                console.log('media card updated');
            }
        });
        toggleCardsVisibility(); // Ensure visibility is updated after applying highlights
    });

    // Observer changes to DOM for catching the media cards
    const callback = (mutationsList, observer) => {
        let relevantMutation = mutationsList.some(mutation => mutation.type === 'childList' || mutation.type === 'attributes');
        if (relevantMutation) {
            applyHighlightColorDebounced();
        }
    };

    const observer = new MutationObserver(callback);
    observer.observe(document.body, { childList: true, attributes: true, subtree: true, attributeFilter: ['class', 'style'] });

    // Button for toggling visibility of non-highlighted cards
    function createToggleVisibilityButton() {
        const button = document.createElement('button');

        function updateButtonText() {
            button.textContent = toggleState ? 'Toggle Visibility (Hiding Crap)' : 'Toggle Visibility (Showing Crap)';
        }

        updateButtonText(); // Initial update based on the current state

        button.style.padding = '10px 20px';
        button.style.marginTop = '20px';
        button.style.fontSize = '16px';
        button.style.color = 'white';
        button.style.backgroundColor = '#007bff';
        button.style.border = 'none';
        button.style.borderRadius = '5px';
        button.style.cursor = 'pointer';
        button.style.boxShadow = '0 2px 4px rgba(0,0,0,0.2)';
        button.style.transition = 'background-color 0.3s';

        button.onmouseover = () => button.style.backgroundColor = '#0056b3';
        button.onmouseleave = () => button.style.backgroundColor = '#007bff';

        button.addEventListener('click', () => {
            toggleState = !toggleState; // Toggle the state
            toggleCardsVisibility(); // Apply the toggle
            updateButtonText();
        });

        const buttonParent = document.querySelector('.wrap');
        console.log('wrap:', buttonParent.toString());
        if (buttonParent) {
            buttonParent.appendChild(button);
        }
    }

    document.addEventListener('DOMContentLoaded', () => {
        createToggleVisibilityButton();
        toggleCardsVisibility(); // Apply the initial state based on stored preference
    });
})();
