function initEffects()
	particles = {}
	heatParticlesRate = 6
end

function updateEffects()
	if (frame % heatParticlesRate == 0) then
		-- spawn heat particles around player and payload
		-- local spawnPoint = v2add(player.pos, v2scale(scrollDirection, - 0.06))
		-- local offset = v2scale(v2rotate(scrollDirection, 90), rndrange(-0.01, 0.01))
		-- spawnParticleWithForce(v2add(spawnPoint, offset), offset, 1, rndrange(10, 40), { 7, 10, 25 }, v2scale(scrollDirection, 0.002))

		spawnPoint = v2add(payload.pos, v2scale(scrollDirection, - 0.2))
		offset = v2scale(v2rotate(scrollDirection, 90), rndrange(-0.025, 0.025))
		spawnParticleWithForce(v2add(spawnPoint, offset), offset, 1, rndrange(10, 40), { 7, 10, 25 }, v2scale(scrollDirection, 0.002))
	end

	for p in all(particles) do
		v2simulate(p)
		if (p.life > p.lifespan) del(particles, p)
	end
end

-- this gets called twice, once with layer = "lower" for effects that merge with the background plasma
-- then with layer = "upper" for effects that draw on top of sprites
function drawEffects(layer)
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
	
		line(p.pos.x, p.pos.y, p.pos.x - p.vel.x * 2, p.pos.y - p.vel.y * 2, pcolor)
		line(p.pos.x, p.pos.y, p.pos.x + rndrange(-2, 2) - p.vel.x * 2, p.pos.y + rndrange(-2, 2) - p.vel.y * 2, pcolor)
	end
end

function spawnParticleWithForce(_pos, _vel, _drag, _lifespan, _colors, _force)
	p = { life = 0, lifespan = _lifespan, pos = _pos, vel = _vel, colors = _colors, force = _force, drag = _drag }
	add(particles, p)
end

function spawnParticle(_pos, _vel, _drag, _lifespan, _colors)
	p = { life = 0, lifespan = _lifespan, pos = _pos, vel = _vel, colors = _colors, drag = _drag }
	add(particles, p)
end