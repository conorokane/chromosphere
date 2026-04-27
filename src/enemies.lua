function initEnemies()
	enemies = {}
	spawnEnemy(320, 100)
	spawnEnemy(350, 130)
	spawnEnemy(300, 150)
	spawnEnemy(350, 180)
	spawnEnemy(220, 100)
	spawnEnemy(250, 130)
	spawnEnemy(200, 150)
	spawnEnemy(250, 180)
end

function spawnEnemy(_x, _y)
	newEnemy = { 
		pos = { x = _x, y = _y }, 
		radius = 16, 
		randomOffset = rnd(100),
		hitPoints = 6,
		damaged = false,
		frames = { 9, 10, 11, 12, 17, 18, 19, 20 },
		playSpeed = 0.2,
		centerOffset = { x = 0, y = 5}
	}
	newEnemy.currentFrame = rnd(#newEnemy.frames - 1),

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
		spr(e.frames[flr(e.currentFrame)], e.pos.x + e.centerOffset.x - e.radius, e.pos.y + e.centerOffset.y - e.radius)
	end
end

function takeDamage(e, value, push)
	e.hitPoints -= value
	if e.hitPoints == 0 then
		explode(e)
		del(enemies, e)
	else
		e.pos.x += push
		e.damaged = true -- makes it flash white
	end
end

function explode(e)
	for i = 0, 16 do
		local randomVector = v2rotate( { x = 4, y = 0 }, rndrange(-120, 120))
		local initialVector = v2scale(v2right, rndrange(2, 4))
		spawnParticle( e.pos, v2add(initialVector, randomVector), 0.95, rndrange(6, 20), { 36, 35, 34 }, 1)
	end
	for i = 1, 5 do
		circfill(e.pos.x + rndrange(0, e.radius * 3), e.pos.y + rndrange(-e.radius / 2, e.radius / 2), rndrange(10, e.radius), rndrange(33, 37))
	end
	-- camera splats
	for i = 0, rndrange(2, 5) do
		local splatVel = v2rotate( v2scale({ x = 4, y = 0 }, rndrange(0.5, 1.5)), rndrange(-45, 45))
		spawnCameraSplat(e.pos, splatVel, 0.9, rndrange(20, 60), rndrange(5, 30))
	end
end