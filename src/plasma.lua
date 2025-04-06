function initPlasma()
	firstFrame = true
	distortSteps = 1000
	dissolveSteps = 300
	plasmaField = {}
	plasmaColorPositive = 52
	plasmaColorNegative = 49
	spawnPlasma(490, 135)
end

function spawnPlasma(xPos, yPos)
	newPlasma = { vel = { x = -0.8, y = rndrange(-0.5, 0.5) }, pos = { x = xPos, y = yPos }, color = plasmaColorPositive, life = 0, charge = 1, radius = rndrange(4, 10) }
	if rnd() > 0.5 then
		newPlasma.charge = -1
		newPlasma.color = plasmaColorNegative
	end
	add(plasmaField, newPlasma)
end

function updatePlasma()
	for p in all(plasmaField) do
		v2simulatefast(p)
		if (p.life > 1200) del(plasmaField, p)
		-- check for magnetic field collisions
		if player.magfieldsActive then
			for i = 1, #magfield.colliders do
				if v2proximity(p.pos, magfield.colliders[i], magfield.colliderSize) then
					p.vel = v2rotate(p.vel, p.charge * magfield.strength[i])
				end
			end
		end
	end

	-- spawn more plasmaField
	if (frame % 10 == 0) spawnPlasma(490, rndrange(40, 240))
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

	for p in all(plasmaField) do
		-- large outer circles fall behind with velocity with 2 smaller inner circles
		for i = 1, 3 do
			circfill(p.pos.x + rndrange(-3 - i, 3 + i), p.pos.y + rndrange(-3 - i, 3 + i), p.radius + 2 - i, p.color)
		end
		circfill(p.pos.x + rndrange(-2, 2), p.pos.y + rndrange(-2, 2), p.radius, p.color - 1)
	end
	
	-- distort screen
	for i = 1, distortSteps do
		local x, y = rnd(480), rnd(270)
			rectfill(x-1, y-1, x+1, y+1, pget(x, y))
	  end
	-- copy current screen to free memory
	memcpy(0x080000, 0x010000, 128000)
end