function initEffects()
	particles = {}
	heatParticlesRate = 4
	lastLaserHit = { pos = v2make(0, 0), time = -5 }
end

function updateEffects()
	if (frame % heatParticlesRate == 0) then
		-- spawn heat particles around player and payload
		-- local spawnPoint = v2add(player.pos, v2scale(scrollDirection, - 0.06))
		-- local offset = v2scale(v2rotate(scrollDirection, 90), rndrange(-0.01, 0.01))
		-- spawnParticleWithForce(v2add(spawnPoint, offset), offset, 1, rndrange(10, 40), { 7, 10, 25 }, v2scale(scrollDirection, 0.002))

		spawnPoint = v2add(payload.pos, v2scale(scrollDirection, - 0.25))
		offset = v2scale(v2rotate(scrollDirection, 90), rndrange(-0.03, 0.03))
		spawnParticleWithForce(v2add(spawnPoint, offset), offset, 1, rndrange(10, 40), { 7, 10, 25 }, 2, v2scale(scrollDirection, 0.002))
	end

	for p in all(particles) do
		v2simulate(p)
		if (p.life > p.lifespan) del(particles, p)
	end

	-- rotate scroll direction
	scrollDirection = v2rotate(scrollDirection, sin(frame * scrollRotationRate) * scrollRotationScale)
end

-- this gets called twice, once with layer = "lower" for effects that merge with the background plasma
-- then with layer = "upper" for effects that draw on top of sprites
function drawEffects(layer)
	-- both upper and lower
	for p in all(particles) do
		local pcolor = p.colors[1]
		if p.life > p.lifespan * 0.66 then
			pcolor = p.colors[3]
		elseif p.life > p.lifespan * 0.33 then
			pcolor = p.colors[2]
		end

		-- flash on first particle draw
		if layer == "lower" and p.life == 1 then
			circfill(p.pos.x, p.pos.y, rndrange(1, 2), pcolor)
		end
			
		line(p.pos.x, p.pos.y, p.pos.x - p.vel.x * p.tail, p.pos.y - p.vel.y * p.tail, pcolor)
		line(p.pos.x, p.pos.y, p.pos.x + rndrange(-2, 2) - p.vel.x * p.tail, p.pos.y + rndrange(-2, 2) - p.vel.y * p.tail, pcolor)
	end

	if layer == "upper" then
		-- laser flash
		local hitTime = frame - lastLaserHit.time
		if hitTime == 1 or hitTime == 2 then
			circfill(lastLaserHit.pos.x, lastLaserHit.pos.y, 6, 7)
			for i = 1, 6 do
				pset(lastLaserHit.pos.x + rndrange(-10, 10), lastLaserHit.pos.y + rndrange(-10, 10), rndrange(32, 37))
			end
		elseif hitTime == 3 or hitTime == 4 then
			circfill(lastLaserHit.pos.x, lastLaserHit.pos.y, 5, 37)
		elseif hitTime == 5 or hitTime == 6 then
			circfill(lastLaserHit.pos.x, lastLaserHit.pos.y, 4, 36)
		elseif hitTime == 7 or hitTime == 8 then
			circfill(lastLaserHit.pos.x, lastLaserHit.pos.y, 2, 35)
		end
	end
end

function spawnParticleWithForce(_pos, _vel, _drag, _lifespan, _colors, _tail, _force )
	p = { life = 0, lifespan = _lifespan, pos = _pos, vel = _vel, colors = _colors, force = _force, drag = _drag, tail = _tail }
	add(particles, p)
end

function spawnParticle(_pos, _vel, _drag, _lifespan, _colors, _tail)
	p = { life = 0, lifespan = _lifespan, pos = _pos, vel = _vel, colors = _colors, drag = _drag, tail = _tail }
	add(particles, p)
end

function calculateLaserPosition()
	local laserResolution = 4
	laserStart = { x = player.pos.x + 18, y = player.pos.y - 1 + rndrange(-1, 2)}
	laserEnd = 480
	local laserHit = false
	-- raycast forward from laser start to find laser end
	if (laserStart.x < 480) then
		for i = 0, (480 - laserStart.x) \ laserResolution do
			for e in all(enemies) do
				if not laserHit then
					if v2proximity(e.pos, v2make(laserStart.x + i * laserResolution, laserStart.y), 8) then
						laserHit = true
						laserEnd = (e.pos.x - e.radius / 2) + rndrange( -3, 3)
						lastLaserHit = { pos = { x = laserEnd, y = laserStart.y + rndrange(-2, 2) }, time = frame }

						-- hit effect
						for j = 0, 8 do
							local randomVector = v2rotate( { x = 6, y = 0 }, rndrange(-30, 30))
							local initialVector = v2scale(v2right, rndrange(2, 5))
							if j == 0 then
								local sign = 1
								if (rnd() < 0.5) sign = -1
								randomVector = v2rotate( { x = 6, y = 0 }, rndrange(30, 120) * sign) -- two stray sparks, the rest go behind
								initialVector = v2make(0, 0)
							end
							spawnParticle( { x = laserEnd + 5, y = laserStart.y + rndrange(-3, 3) }, v2add(initialVector, randomVector), 0.9, rndrange(3, 10), { 37, 35, 33 }, 1)
						end
					end
				end
			end
		end
	end
end

function drawLaserInBackground()
	local laserColor = rndrange(33, 36)
	line(laserStart.x, laserStart.y, laserEnd, laserStart.y, laserColor)
	circfill(laserStart.x + 4, laserStart.y, rndrange(3, 6), laserColor + 2)
end

function drawLaserInForeground()
	line(laserStart.x, laserStart.y, laserEnd, laserStart.y, 7)
end