function initPayload()
	payload = { pos = { x = 0, y = 0 }, fxFrequency = 10, fxRange = 5, maxHP = 30, hpBarTarget = { x = 0, y = -30 }, hpBarInertia = 0.4, radius = 25 , takingDamage = false }
	payload.currentHP = payload.maxHP
	updatePayload()
end

function updatePayload()
	payload.pos = { x = 100 + sin(t() * 0.01) * 50, y = 135 + cos(t() * 0.02) * 50 }
end

function drawPayloadLower()
	-- fx blobs
	if (frame % payload.fxFrequency == 0) then
		local distance = rndrange(20, 20 + payload.fxRange)
		local pos = v2add(payload.pos, v2scale(v2randomnormalized(), distance))
		circfill(pos.x, pos.y, 25 - distance / 2, blend_payload)
	end
	circfill(payload.pos.x, payload.pos.y, payload.radius, blend_payload)
end

function drawPayload()
	-- lower half of elipses
	local dt = frame * 0.003
	local col
	for i = 0, 5 do
		col = 19
		if (i == 0) col = 26
		if (i == 1) col = 11
		if (i ==2 or i == 3) col = 3
		fillp(dotPatternScanLinesDiagonal)
		elipse (payload.pos.x, payload.pos.y, 40 - i * 2, (40 - i * 2) * sin(dt / 12 - (i * 0.02)), 10, 0.5 + dt - i * 0.02, col, 2)
		fillp()
	end
	-- payload graphics
	circfill(payload.pos.x, payload.pos.y, payload.radius, blend_payload)
	circfill(payload.pos.x + 8, payload.pos.y - 8, payload.radius / 2, 38)
	circfill(payload.pos.x + 8, payload.pos.y - 8, payload.radius / 4, 39)

	-- upper half of elipses
	for i = 5, 0, - 1 do
		col = 19
		if (i == 0) col = 26
		if (i == 1) col = 11
		if (i ==2 or i == 3) col = 3
		fillp(dotPatternScanLinesDiagonal)
		elipse (payload.pos.x, payload.pos.y, 40 - i * 2, (40 - i * 2) * sin(dt / 12 - (i * 0.02)), 10, dt - i * 0.02, col, 2)
		fillp()
	end
end

function payloadLoseHP(amount)
	payload.currentHP -= amount
	payload.currentHP = max(payload.currentHP, 0)
	payload.takingDamage = true
end