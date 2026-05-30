// Obstacle course implementation
const obstacles = [];

function createObstacle() {
    const obstacle = {
        x: Math.random() * canvas.width,
        y: Math.random() * canvas.height,
        width: 50,
        height: 50,
        type: 'static' // Can be dynamic based on game design
    };
    obstacles.push(obstacle);
}

function drawObstacles() {
    obstacles.forEach(obstacle => {
        context.fillStyle = 'red'; // Color for obstacles
        context.fillRect(obstacle.x, obstacle.y, obstacle.width, obstacle.height);
    });
}