function initPlasma()
	plasmaField = {}
	streakFrequencyBackground = 8 -- frames between drawing a streak
	streakFrequencyForeground = 15	 -- was 15
	
	plasmaColorPositive = 52
	plasmaColorNegative = 48
	plasmaPushForce = 0.005
	bgColor = 56
	plasmaCap = 60 -- maximum number of plasma particles
end

function updatePlasma()
	if #plasmaField > plasmaCap then -- limit plasma count
		del(plasmaField, plasmaField[1]) -- remove oldest plasma
	end
	for p in all(plasmaField) do
		v2simulatefast(p)
		p.beingPushed -= 1 -- count down
		if (p.life > p.lifespan) del(plasmaField, p)

		if not p.onScreen then
			if p.pos.x < 480 and p.pos.x > 0 and p.pos.y > 0 and p.pos.y < 270 then
				p.onscreen = true
			end
		else -- cull plasma that has left the screen
			if p.pos.x < -10 or p.pos.x > 480 or p.pos.y < -10 or p.pos.y > 280 then
				del(plasmaField, p)
			end
		end

		-- magnetic field collisions
		if player.magfieldsActive then
			for i = 1, #magfield.colliders do
				if v2proximity(p.pos, magfield.colliders[i], magfield.colliderSize) then
					p.beingPushed = 10 -- counts down for a few frames
					p.vel = v2rotate(p.vel, p.charge * magfield.strength[i] / p.radius)
					-- push back on player
					local pushVector = v2rotate(v2normalize(p.vel), -90 * p.charge)
					player.target = v2add(player.target, v2scale(pushVector, p.radius * plasmaPushForce))
				end
			end
		end

		-- player collisions
		if v2proximity(p.pos, player.pos, player.hitRadius + p.radius - 3) then
			playerLoseHP(0.1)
		end

		-- payload collisions
		if v2proximity(p.pos, payload.pos, payload.radius) then
			payloadLoseHP(0.1)
		end
	end
end

function drawPlasmaLower()
	-- draw background streaks
	if frame % streakFrequencyBackground == 0 then
		local streakStart = { x = rnd(530), y = rndrange(-50, 330) }
		local streakEnd = v2add(streakStart, v2scale(scrollDirection, rndrange(0.5, 3)))
		-- double thick line
		line(streakStart.x, streakStart.y, streakEnd.x, streakEnd.y, 4)
		line(streakStart.x, streakStart.y + 1, streakEnd.x, streakEnd.y + 1, 4)
	end

	-- draw background plasma balls
	for p in all(plasmaField) do
		-- large outer circles fall behind with velocity with 2 smaller inner circles
		local plasmaColor = p.color + 1
		if p.beingPushed > 0 then -- change color when pushed
			plasmaColor = p.color
		end
		for i = 1, 3 do
			circfill(p.pos.x + rndrange(-3 - i, 3 + i), p.pos.y + rndrange(-3 - i, 3 + i), p.radius + 2 - i, plasmaColor)
		end
	end

	-- draw bright foreground plasma balls behind the magnetic field lines (part of distortion layer)
	for p in all(plasmaField) do
		local plasmaColor = p.color
		if p.beingPushed > 0 then -- change color when pushed
			plasmaColor = p.color + 1
		end
		for i = 1, 3 do
			local position = v2sub(p.pos, v2scale(p.vel, 4 * i))
			circfill(position.x, position.y, p.radius - i, plasmaColor)
		end
	end

	-- draw foreground streaks
	if frame % streakFrequencyForeground == 0 then
		local streakStart = { x = rnd(530), y = rndrange(-50, 330) }
		local streakSize = rndrange(0.5, 3)
		local streakEnd = v2add(streakStart, v2scale(scrollDirection, streakSize))
		line(streakStart.x, streakStart.y, streakEnd.x, streakEnd.y, 31)

		-- check if streak collides with player or payload
		local steps = streakSize * 8
		local streakHit = false
		for i = 0, steps do
			-- check along streak length for collisions
			local point = v2add(streakStart, v2scale(scrollDirection, streakSize * i / steps))
			if (not streakHit) then -- prevent duplicate hits
				if v2proximity(point, player.pos, player.hitRadius) or v2proximity(point, payload.pos, payload.radius) then
					streakHit = true
					-- flash
					circfill(point.x, point.y, 10, 31)
					for j = 1, 6 do
						local randomVector = v2rotate(v2scale(scrollDirection, 0.05), rndrange(-15, 15))
						spawnParticle(point, v2add(v2scale(scrollDirection, rndrange(0.003, 0.08)), randomVector), 0.9, rndrange(45, 60), { 31, 4, 20 }, 2)	
					end
				end
			end
		end
	end

	if player.shooting and frame % player.fireRate == shootStartOffset then
		calculateLaserPosition()
		drawLaserInBackground()	
	end
end

function drawPlasmaUpper()
	-- draw bright foreground plasma balls in front of the magnetic field lines
	for p in all(plasmaField) do
		local plasmaColor = p.color
		if p.beingPushed > 0 then -- change color when pushed
			plasmaColor = p.color + 1
		end
		circfill(p.pos.x, p.pos.y, p.radius, plasmaColor)
	end
end

-- sprays a solar flare of similarly charged plasma from off-screen
function sprayPlasma(direction, count, _charge, spread)
	spawnPoint = v2sub( screenCenter, v2scale(direction, 300))
	for i = 1, count do
		local newPlasma = createSinglePlasma(_charge, rndrange(4, 12))
		newPlasma.vel = v2scale(v2rotate(direction, i * spread), 0.4 - sin(i/count/2) * 0.3 - sin(i/count/4) * 0.3)
		newPlasma.pos = spawnPoint
		add(plasmaField, newPlasma)
	end
end

-- charge 1 or -1
function createSinglePlasma(_charge, _radius)
	local newPlasma = { vel = { v2zero }, pos = { v2zero }, color = plasmaColorPositive, life = 0, lifespan = rndrange(900, 1500), charge = _charge, radius = _radius, onScreen = false, beingPushed = 0 }
	if (_charge == -1) newPlasma.color = plasmaColorNegative
	return newPlasma
end