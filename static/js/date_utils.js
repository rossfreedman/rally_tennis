/**
 * Date utilities for consistent client-side date handling
 * Addresses timezone issues with JavaScript Date constructor
 */

/**
 * Parse a YYYY-MM-DD string to a Date object without timezone issues
 * @param {string} dateStr - Date string in YYYY-MM-DD format
 * @returns {Date} Date object representing the correct local date
 */
function parseDateSafe(dateStr) {
    if (!dateStr) return null;
    
    // Split the date string and create Date object safely
    const [year, month, day] = dateStr.split('-').map(Number);
    
    // Use Date constructor with individual components
    // Note: month is 0-indexed in JavaScript
    return new Date(year, month - 1, day);
}

/**
 * Format a date string for display with day of week
 * @param {string} dateStr - Date string in YYYY-MM-DD format
 * @returns {string} Formatted date like "Monday, 5/26/25"
 */
function formatDateForDisplay(dateStr) {
    if (!dateStr) return '';
    
    try {
        const date = parseDateSafe(dateStr);
        if (!date || isNaN(date.getTime())) return dateStr;
        
        const weekday = date.toLocaleDateString('en-US', { weekday: 'long' });
        const month = date.getMonth() + 1; // Convert back to 1-indexed
        const day = date.getDate();
        const year = date.getFullYear().toString().slice(-2);
        
        return `${weekday} ${month}/${day}/${year}`;
    } catch (error) {
        console.error('Error formatting date:', error);
        return dateStr;
    }
}

/**
 * Compare two date strings for equality
 * @param {string} date1 - First date string (YYYY-MM-DD)
 * @param {string} date2 - Second date string (YYYY-MM-DD)
 * @returns {boolean} True if dates are the same
 */
function isSameDate(date1, date2) {
    if (!date1 || !date2) return false;
    
    // Normalize both dates to YYYY-MM-DD format
    const normalized1 = normalizeDate(date1);
    const normalized2 = normalizeDate(date2);
    
    return normalized1 === normalized2;
}

/**
 * Normalize various date formats to YYYY-MM-DD
 * @param {string} dateStr - Date string in various formats
 * @returns {string} Date string in YYYY-MM-DD format
 */
function normalizeDate(dateStr) {
    if (!dateStr) return null;
    
    // If already in YYYY-MM-DD format, return as-is
    if (/^\d{4}-\d{2}-\d{2}$/.test(dateStr)) {
        return dateStr;
    }
    
    // Handle MM/DD/YYYY or MM/DD/YY formats
    if (dateStr.includes('/')) {
        const parts = dateStr.split('/');
        if (parts.length === 3) {
            let [month, day, year] = parts;
            
            // Convert 2-digit year to 4-digit
            if (year.length === 2) {
                year = '20' + year;
            }
            
            // Pad month and day with leading zeros
            month = month.padStart(2, '0');
            day = day.padStart(2, '0');
            
            return `${year}-${month}-${day}`;
        }
    }
    
    // If we can't parse it, return as-is
    return dateStr;
}

/**
 * Get today's date in YYYY-MM-DD format
 * @returns {string} Today's date
 */
function getTodayString() {
    const today = new Date();
    const year = today.getFullYear();
    const month = (today.getMonth() + 1).toString().padStart(2, '0');
    const day = today.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
}

/**
 * Check if a date is in the past
 * @param {string} dateStr - Date string to check
 * @returns {boolean} True if date is before today
 */
function isDateInPast(dateStr) {
    if (!dateStr) return false;
    
    const today = getTodayString();
    return normalizeDate(dateStr) < today;
}

// Export functions for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        parseDateSafe,
        formatDateForDisplay,
        isSameDate,
        normalizeDate,
        getTodayString,
        isDateInPast
    };
} 