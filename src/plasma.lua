function initPlasma()
	firstFrame = true
	distortSteps = 1000
	dissolveSteps = 300
	plasmaField = {}
	plasmaColorPositive = 52
	plasmaColorNegative = 49
end

function updatePlasma()
	for p in all(plasmaField) do
		v2simulatefast(p)
		-- rotate cores
		p.coreVector = v2rotate(p.coreVector, p.rotationSpeed * p.charge)
		if (p.life > p.lifespan) del(plasmaField, p)
		-- check for magnetic field collisions
		if player.magfieldsActive then
			for i = 1, #magfield.colliders do
				if v2proximity(p.pos, magfield.colliders[i], magfield.colliderSize) then
					p.vel = v2rotate(p.vel, p.charge * magfield.strength[i])
				end
			end
		end
	end

	-- spawn random plasma
	-- if (frame % 10 == 0) spawnPlasma(490, rndrange(40, 240))

	-- spray
	local sign = 1
	if (rnd() < 0.5) sign = -1
	if (frame % 160 == 0) sprayPlasma(v2randominrange(120, 180), rndrange(15, 25), sign, rndrange(1, 1.5))
end

function drawPlasma()
	if (firstFrame)	then
		cls(bgcolor)
		firstFrame = false
	else
		-- restore stored screen
		memcpy(0x010000, 0x080000, 128000)
	end
	
	-- dissolve to background color
	for i = 1, dissolveSteps do
		local x, y = rnd(480), rnd(270)
	  local fillColor = bgcolor
	  pixelColor = pget(x,y)
	  if pixelColor == plasmaColorNegative or pixelColor == plasmaColorPositive then
		  fillColor = pixelColor + 1
	  end
	  circfill(x, y, 2, fillColor)
	end

	-- draw plasma balls
	for p in all(plasmaField) do
		-- large outer circles fall behind with velocity with 2 smaller inner circles
		for i = 1, 3 do
			circfill(p.pos.x + rndrange(-3 - i, 3 + i), p.pos.y + rndrange(-3 - i, 3 + i), p.radius + 2 - i, p.color)
		end
		local corepos = v2add(p.pos, p.coreVector)
		circfill(corepos.x, corepos.y, p.radius, p.color - 1)
	end
	
	-- distort screen
	for i = 1, distortSteps do
		local x, y = rnd(480), rnd(270)
			rectfill(x-1, y-1, x+1, y+1, pget(x, y))
	  end
	-- copy current screen to free memory
	memcpy(0x080000, 0x010000, 128000)
end

function spawnPlasma(xPos, yPos)
	local newPlasma = createSinglePlasma(1)
	newPlasma.vel = { x = -0.8, y = rndrange(-0.5, 0.5) }
	newPlasma.pos = { x = xPos, y = yPos }
	if rnd() > 0.5 then
		newPlasma.charge = -1
		newPlasma.color = plasmaColorNegative
	end
	add(plasmaField, newPlasma)
end

-- sprays a solar flare of similarly charged plasma from off-screen
function sprayPlasma(direction, count, _charge, spread)
	spawnPoint = v2sub( screenCenter, v2scale(direction, 300))
	for i = 1, count do
		local newPlasma = createSinglePlasma(_charge)
		newPlasma.vel = v2scale(v2rotate(direction, i * spread), 0.3 - sin(i/count/2) * 0.3 - sin(i/count/4) * 0.3)
		newPlasma.pos = spawnPoint
		add(plasmaField, newPlasma)
	end
end

function createSinglePlasma(_charge)
	local newPlasma = { vel = { v2zero }, pos = { v2zero }, color = plasmaColorPositive, life = 0, lifespan = rndrange(900, 1500), charge = _charge, radius = rndrange(4, 9), coreVector = v2randomnormalized(), rotationSpeed = rndrange(8, 14) }
	if (_charge == -1) newPlasma.color = plasmaColorNegative
	return newPlasma
end