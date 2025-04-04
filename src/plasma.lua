function initPlasma()
	plasmaField = {}
	spawnPlasma(490, 135)
end

function spawnPlasma(xPos, yPos)
	newPlasma = { vel = { x = -0.8, y = rndrange(-0.5, 0.5) }, pos = { x = xPos, y = yPos }, sprite = 8, life = 0, charge = 1 }
	if rnd() > 0.5 then
		newPlasma.charge = -1
		newPlasma.sprite = 9
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
	for p in all(plasmaField) do
		spr(p.sprite, p.pos.x, p.pos.y)
	end
end