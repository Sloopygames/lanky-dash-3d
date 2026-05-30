// Environmental hazards implementation
const hazards = [];

function createHazard() {
    const hazard = {
        x: Math.random() * canvas.width,
        y: Math.random() * canvas.height,
        width: 50,
        height: 50,
        type: 'spike' // Example type
    };
    hazards.push(hazard);
}

function drawHazards() {
    hazards.forEach(hazard => {
        context.fillStyle = 'orange'; // Color for hazards
        context.fillRect(hazard.x, hazard.y, hazard.width, hazard.height);
    });
}