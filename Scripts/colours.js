// Scripts/colours.js
export const colourMap = {
    black: [0, 0, 0, 1],
    brown: [0.235, 0.129, 0, 0.8],
    white: [1, 1, 1, 1],
    red: [0.8, 0.1, 0.1, 1],
    orange: [1, 0.561, 0.024, 0.8],
    green: [0.1, 0.5, 0.1, 1],
    blue: [0.1, 0.3, 0.8, 1],
    purple: [0.6, 0.2, 0.8, 1],
    pink: [1, 0.4, 0.7, 1],
    gold: [0.85, 0.7, 0.3, 1],
    silver: [0.75, 0.75, 0.75, 1]
};

/**
 * Get RGBA array from colour name.
 * Defaults to black if not found.
 * @param {string} name 
 * @returns {number[]}
 */
export function getColour(name) {
    return colourMap[name.toLowerCase()] || colourMap.black;
}

// Attach to window so existing code using window.colourMap works
window.colourMap = colourMap;
