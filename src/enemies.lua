function initEnemies()
	enemies = {}
end

function spawnEnemy(_x, _y, _speed, _frequency, _amplitude, _delay)
	newEnemy = { 
		pos = { x = _x, y = _y }, 
		radius = 16, 
		hitPoints = 3,
		damaged = 0,
		frames = { 9, 10, 11, 12, 17, 18, 19, 20 },
		playSpeed = 0.2,
		centerOffset = { x = 0, y = 5},
		vel = v2make(_speed, 0),
		frequency = _frequency,
		amplitude = _amplitude,
		delay = _delay,
		life = 0
	}
	newEnemy.currentFrame = rnd(#newEnemy.frames - 1)
	add(enemies, newEnemy)
end

function updateEnemies()
	-- test spawn
	if (frame % 450 == 50) then
		local randomY = rndrange(50, 170) -- higher top value because they always start curving down
		local randomX = rndrange(520, 700) -- further off screen so they sometimes enter curving up
		for i = 6, 1, -1 do
			spawnEnemy(randomX, randomY, -0.8, 0.002, 0.4, i * 30)
		end
	end

	for e in all(enemies) do
		moveEnemy(e)
	end
end

function drawEnemies()
	for e in all(enemies) do
		if e.damaged > 0 then 
			setPaletteDamage(true)
			e.damaged -= 1
		end
		animate(e)
		spr(e.frames[flr(e.currentFrame)], e.pos.x + e.centerOffset.x - e.radius, e.pos.y + e.centerOffset.y - e.radius)
		setPaletteDamage(false)
	end
end

function moveEnemy(e)
	-- sine wave motion
	if e.delay < 0 then
		v2simulatefast(e)
		e.vel = v2rotate(e.vel, cos(e.life * e.frequency) * e.amplitude)
	else
		e.delay -= 1
	end
	if (e.pos.x < -30) del(enemies, e)
end

-- swap colors to flash damaged enemies
function setPaletteDamage(damaged)
	if damaged then
		pal(24, 7)
		pal(8, 7)
	else
		pal(24, 24)
		pal(8, 8)
	end
end

function takeDamage(e, value, push)
	e.hitPoints -= value
	if e.hitPoints == 0 then
		explode(e)
		del(enemies, e)
	else
		e.pos.x += push
		e.damaged = 5
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
	for i = 0, rndrange(1, 3) do
		local splatVel = v2rotate( v2scale({ x = 4, y = 0 }, rndrange(0.5, 1.5)), rndrange(-45, 45))
		spawnCameraSplat(e.pos, splatVel, 0.9, rndrange(20, 60), rndrange(5, 30))
	end
end