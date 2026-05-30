// Power Slide implementation
let isSliding = false;

function activatePowerSlide() {
    if (!isSliding) {
        isSliding = true;
        player.y += 20; // Adjust player position for sliding effect
        setTimeout(() => {
            isSliding = false; // Reset sliding state after duration
        }, 1000); // Duration of slide
    }
}