
function _init()
	-- load palette
	fetch("src/0.pal"):poke(0x5000)

	stickLeft = {}
	stickRight = {}
	stickRightSmoothed = { x = 0, y = 0 }
	rightStickDecay = 0.2
	rightStickDeadZoneSquared = 0.002

	player = {pos = {x = 240, y = 135}, speed = 3, aim = {x = 0, y = 0}, radius = 8, target = {x = 240, y = 135}, inertia = 0.1, aimAngle = 0}
	screenBounds = {left = 8, right = 472, top = 8, bottom = 262}
	magfield = {steps = 15, distanceScale = 0.4, heightScale = 0.3, vertsScale = 1, positions = {}, positions2 = {}, offsets = {}, offsets2 = {}, inertiaScale = 0.7, vertsScale = 1.5, secondaryFieldScale = 0.3}

	for i = 0, magfield.steps - 1 do
		magfield.positions[i] = { x = player.pos.x, y = player.pos.y }
		magfield.positions2[i] = { x = player.pos.x, y = player.pos.y }
		magfield.offsets[i] = 0
		magfield.offsets2[i] = 0
	end

	frame = 0
end

function _update()
	frame += 1

	stickLeft = {
		x = (btn(1) or 0)/255 - (btn(0) or 0)/255,
		y = (btn(3) or 0)/255 - (btn(2) or 0)/255
	}
	stickRight = {
		x = (btn(9) or 0)/255 - (btn(8) or 0)/255,
		y = (btn(11) or 0)/255 - (btn(10) or 0)/255
	}

	if v2squarelength(stickRight) > 0.1 then
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

	if v2squarelength(stickRightSmoothed) < rightStickDeadZoneSquared then
		-- reset magnetic field positions
		for i = 0, magfield.steps - 1 do
			magfield.positions[i] = { x = player.pos.x, y = player.pos.y }
			magfield.positions2[i] = { x = player.pos.x, y = player.pos.y }
		end
	else
		calculateMagneticFields()
	end
end

function _draw()
	cls(21)
	if v2squarelength(stickRightSmoothed) > rightStickDeadZoneSquared then
		drawMagneticFields()
	end
	spr(1, player.pos.x - player.radius, player.pos.y - player.radius)
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
	end
end

function drawMagneticFields()
	
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

		rovalPulse(magfield.positions[i].x, magfield.positions[i].y, lengthOfOffset, 4 + magfield.heightScale * lengthOfOffset, 6 + i * magfield.vertsScale, angle, 39 - i \ 2, false)
		rovalPulse(magfield.positions2[i].x, magfield.positions2[i].y, lengthOfOffset2, 4 + magfield.heightScale * lengthOfOffset2, 6 + i * magfield.vertsScale, angle2, 39 - i \ 2, true)
	end
end

-- draw a pulsing rotated oval
function rovalPulse (x, y, w, h, verts, angle, col, reverse)
	line()
	points = {}
	local px, py


 	for i = 0, verts do
		-- calculate ellipse
		px = cos(i / verts) * w
		py = sin(i / verts) * h
		-- rotate points
		local pxrotated = px * cos(angle) - py * sin(angle)
		local pyrotated = py * cos(angle) + px * sin(angle)
		-- draw points
		local color = col
		if (frame % 2 == 0) then -- draw colored pulses every 2nd frame
			if (reverse) then
				if (-1 * frame \ 3 % verts == i) color = col + 3
				if (frame \ 3 % verts == i) color = col - 3
			else
				if (frame \ 3 % verts == i) color = col + 3
				if (-1 * frame \ 3 % verts == i) color = col - 3
			end
			color = clamp(color, 32, 39)
		end
		line(x + pxrotated, y + pyrotated, color)
 	end
end

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

