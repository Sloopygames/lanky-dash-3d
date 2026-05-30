// Power-up system implementation
const powerUps = [
    { type: 'speed', duration: 5000 }, // Speed boost for 5 seconds
    { type: 'invincibility', duration: 5000 } // Invincibility for 5 seconds
];

function spawnPowerUp() {
    const powerUp = powerUps[Math.floor(Math.random() * powerUps.length)];
    // Logic to spawn power-up at a random location on the map
}

function collectPowerUp(player, powerUp) {
    if (powerUp.type === 'speed') {
        player.speed *= 1.5; // Increase speed
        setTimeout(() => {
            player.speed /= 1.5; // Reset speed after duration
        }, powerUp.duration);
    } else if (powerUp.type === 'invincibility') {
        player.invincible = true; // Set invincibility
        setTimeout(() => {
            player.invincible = false; // Reset invincibility after duration
        }, powerUp.duration);
    }
}