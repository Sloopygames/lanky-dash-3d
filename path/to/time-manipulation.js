// Time manipulation implementation
let isTimeSlowed = false;

function activateTimeManipulation() {
    if (!isTimeSlowed) {
        isTimeSlowed = true;
        gameSpeed = 0.5; // Slow down game speed
        setTimeout(() => {
            gameSpeed = 1; // Reset game speed after duration
            isTimeSlowed = false;
        }, 5000); // Duration of time manipulation
    }
}