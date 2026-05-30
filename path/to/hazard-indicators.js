// Visual indicators for hazards implementation
function drawHazardIndicators() {
    hazards.forEach(hazard => {
        context.fillStyle = 'yellow'; // Color for indicators
        context.fillText('!', hazard.x + 15, hazard.y - 10); // Warning sign above hazard
    });
}