// Dash Ability implementation
let isDashing = false;
const dashDistance = 100; // Distance to dash
const dashDuration = 300; // Duration of dash in milliseconds

function activateDash() {
    if (!isDashing) {
        isDashing = true;
        const originalX = player.x;
        const originalY = player.y;

        player.x += dashDistance * Math.cos(player.angle); // Move player in the direction they are facing
        player.y += dashDistance * Math.sin(player.angle);

        setTimeout(() => {
            player.x = originalX; // Reset to original position after dash
            player.y = originalY;
            isDashing = false; // Reset dashing state
        }, dashDuration);
    }
}