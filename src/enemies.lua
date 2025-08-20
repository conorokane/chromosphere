function initEnemies()
	enemies = {}
	spawnEnemy(400, 135)
	spawnEnemy(300, 130)
	spawnEnemy(250, 200)
	spawnEnemy(350, 180)
end

function spawnEnemy(_x, _y)
	newEnemy = { pos = { x = _x, y = _y }, radius = rndrange(6, 12), randomOffset = rnd(100) }
	add(enemies, newEnemy)
end

function updateEnemies()
	for e in all(enemies) do
		e.pos.x += sin((t() + e.randomOffset) * 0.3) * 0.1
		e.pos.y += cos((t() + e.randomOffset) * 0.3) * 0.2
	end
end

function drawEnemies()
	for e in all(enemies) do
		circfill(e.pos.x, e.pos.y, e.radius, 24)
	end
end