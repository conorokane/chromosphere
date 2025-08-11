function initPlayer()
	stickLeft = {}
	stickRight = {}
	stickRightSmoothed = { x = 0, y = 0 }
	rightStickDecay = 0.2
	rightStickDeadZoneSquared = 0.002
	player = {pos = {x = 240, y = 135}, speed = 3, aim = {x = 0, y = 0}, radius = 8, target = {x = 240, y = 135}, inertia = 0.1, aimAngle = 0, magfieldsActive = false, maxHP = 10, hpBarTarget = { x = 0, y = -17 }, hpBarInertia = 0.4, takingDamage = false }
	player.currentHP = player.maxHP
	player.hpBarPos = v2add(player.pos, player.hpBarTarget)

	-- magnetic fields
	magfield = {steps = 15, distanceScale = 0.4, heightScale = 0.3, vertsScale = 1, positions = {}, positions2 = {}, offsets = {}, offsets2 = {}, inertiaScale = 0.7, vertsScale = 1.5, secondaryFieldScale = 0.3, colliders = {}, colliderSize = 30, strength = { 3, 6, 9 }, color = 47 }

	for i = 0, magfield.steps - 1 do
		magfield.positions[i] = { x = player.pos.x, y = player.pos.y }
		magfield.positions2[i] = { x = player.pos.x, y = player.pos.y }
		magfield.offsets[i] = 0
		magfield.offsets2[i] = 0
	end
end

function updatePlayer()
	stickLeft = {
		x = (btn(1) or 0)/255 - (btn(0) or 0)/255,
		y = (btn(3) or 0)/255 - (btn(2) or 0)/255
	}
	stickRight = {
		x = (btn(9) or 0)/255 - (btn(8) or 0)/255,
		y = (btn(11) or 0)/255 - (btn(10) or 0)/255
	}

	if v2squarelength(stickRight) >= rightStickDeadZoneSquared then
		stickRightSmoothed = stickRight
	else
		stickRightSmoothed = v2lerp(stickRightSmoothed, v2zero, rightStickDecay)
	end

	player.target.x += stickLeft.x * player.speed
	player.target.y += stickLeft.y * player.speed
	player.target.x = clamp(player.target.x, screenBounds.left, screenBounds.right)
	player.target.y = clamp(player.target.y, screenBounds.top, screenBounds.bottom)

	-- lerp player to target
	player.pos = v2lerp(player.pos, player.target, player.inertia)

	player.aim.x = player.pos.x + stickRightSmoothed.x
	player.aim.y = player.pos.y + stickRightSmoothed.y

	-- lerp hp bar to target
	player.hpBarPos = v2lerp(player.hpBarPos, v2add(player.pos, player.hpBarTarget), player.hpBarInertia)

	if v2squarelength(stickRightSmoothed) < rightStickDeadZoneSquared then
		-- reset magnetic field positions
		for i = 0, magfield.steps - 1 do
			magfield.positions[i] = { x = player.pos.x, y = player.pos.y }
			magfield.positions2[i] = { x = player.pos.x, y = player.pos.y }
		end
		player.magfieldsActive = false
	else
		player.magfieldsActive = true
		calculateMagneticFields()
	end
end

function calculateMagneticFields()
	local aimVector = v2sub(player.aim, player.pos)
	aimVector = v2scale(aimVector, magfield.distanceScale)
	
	for i = 0, magfield.steps - 1 do
		-- calculate desired positions
		local iSquared = (i + 1) * (i + 1)
		magfield.offsets[i] = { x = aimVector.x * iSquared, y = aimVector.y * iSquared }
		magfield.offsets2[i] = { x = -aimVector.x * magfield.secondaryFieldScale * iSquared, y = -aimVector.y * magfield.secondaryFieldScale * iSquared }
		local target = v2add(player.pos, magfield.offsets[i])
		local target2 = v2add(player.pos, magfield.offsets2[i])
		
		-- lerp actual position to target
		magfield.positions[i] = v2lerp(magfield.positions[i], target, 1 / ((1 + i) * magfield.inertiaScale))
		magfield.positions2[i] = v2lerp(magfield.positions2[i], target2, 1 / ((1 + i) * magfield.inertiaScale))
		
		-- place colliders
		local colliderTarget = v2sub(magfield.positions[i], player.pos)
		if i == magfield.steps - 1 then
			 magfield.colliders[1] = v2add(player.pos, v2scale(colliderTarget, 1.5))
			 magfield.colliders[2] = v2add(player.pos, v2scale(colliderTarget, 1))
			 magfield.colliders[3] = v2add(player.pos, v2scale(colliderTarget, 0.35))
		end
	end
end

function drawMagneticFields()
	if v2squarelength(stickRightSmoothed) > rightStickDeadZoneSquared then
		for i = 0, magfield.steps - 1 do
			local angle = 0
			local angle2 = 0
			local lengthOfOffset = v2length(v2sub(player.pos, magfield.positions[i]))
			local lengthOfOffset2 = v2length(v2sub(player.pos, magfield.positions2[i]))
			if i > 0 then
				local vectorToPlayer = v2sub(player.pos, magfield.positions[i])
				local vectorToPlayer2 = v2sub(player.pos, magfield.positions2[i])

				angle = atan2(vectorToPlayer.x, vectorToPlayer.y)
				angle2 = atan2(vectorToPlayer2.x, vectorToPlayer2.y)
			end

			-- field lines use color table to create inverse colors
			roval(magfield.positions[i].x, magfield.positions[i].y, lengthOfOffset, 4 + magfield.heightScale * lengthOfOffset, 6 + i * magfield.vertsScale, angle, magfield.color)
			roval(magfield.positions2[i].x, magfield.positions2[i].y, lengthOfOffset2, 4 + magfield.heightScale * lengthOfOffset2, 6 + i * magfield.vertsScale, angle2, magfield.color)
		end
		-- debug draw collider
		-- for col in all(magfield.colliders) do
		-- 	rect(col.x - magfield.colliderSize, col.y - magfield.colliderSize, col.x + magfield.colliderSize, col.y + magfield.colliderSize, 7)
		-- end
	end
end

function drawPlayer()
	spr(1, player.pos.x - player.radius, player.pos.y - player.radius)
end

function playerLoseHP(amount)
	player.currentHP -= amount
	player.currentHP = max(player.currentHP, 0)
	player.takingDamage = true
end

-- magnetic field effects

-- draw a rotated oval
function roval (x, y, w, h, verts, angle, col)
	line()
	points = {}
	local px, py
 	for i=0,verts do
		-- calculate ellipse
		px = cos(i / verts) * w
		py = sin(i / verts) * h
		-- rotate points
		local pxrotated = px * cos(angle) - py * sin(angle)
		local pyrotated = py * cos(angle) + px * sin(angle)
		-- draw points
		line(x + pxrotated, y + pyrotated, col)
 	end
end