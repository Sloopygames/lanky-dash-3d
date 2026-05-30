// JavaScript to trigger visual feedback
function triggerFeedback(element) {
    element.classList.add('active');
    setTimeout(() => {
        element.classList.remove('active');
    }, 300);
}

// Example usage on scoring
function onScore() {
    triggerFeedback(document.querySelector('.score-display'));
    // Other scoring logic...
}