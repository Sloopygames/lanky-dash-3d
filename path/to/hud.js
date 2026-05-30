// Dynamic HUD implementation
function updateHUD() {
    const healthDisplay = document.getElementById('health-display');
    healthDisplay.innerText = `Health: ${player.health}`;
    
    const speedDisplay = document.getElementById('speed-display');
    speedDisplay.innerText = `Speed: ${player.speed}`;
    // Additional HUD elements can be added here
}