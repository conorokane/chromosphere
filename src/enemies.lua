function initEnemies()
	enemies = {}
	spawnEnemy(400, 135)
	spawnEnemy(300, 130)
	spawnEnemy(250, 200)
	spawnEnemy(350, 180)
end

function spawnEnemy(_x, _y)
	newEnemy = { 
		pos = { x = _x, y = _y }, 
		radius = 16, 
		randomOffset = rnd(100),
		hitPoints = 10,
		damaged = false,
		frames = { 9, 10, 11, 12 },
		currentFrame = 1,
		playSpeed = 0.1
	}

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
		if e.damaged then 
			-- palette swap to damaged color
			e.damaged = false
		end
		animate(e)
		spr(e.frames[flr(e.currentFrame)], e.pos.x - e.radius, e.pos.y - e.radius)
	end
end

function takeDamage(e, value, push)
	e.hitPoints -= value
	if e.hitPoints == 0 then
		del(enemies, e)
		-- TODO: enemy death animation
	else
		e.pos.x += push
		e.damaged = true -- makes it flash white
	end
end