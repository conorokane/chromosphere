function initPayload()
	payload = { pos = { x = 0, y = 0 }, color = 61, fxFrequency = 10, fxRange = 5, maxHP = 50, hpBarTarget = { x = 0, y = -30 }, hpBarInertia = 0.4, radius = 25 , takingDamage = false }
	payload.currentHP = payload.maxHP
	updatePayload()
end

function updatePayload()
	payload.pos = { x = 120 + sin(t() * 0.01) * 50, y = 135 + cos(t() * 0.02) * 50 }
end

function drawPayloadLower()
	-- fx blobs
	if (frame % payload.fxFrequency == 0) then
		local distance = rndrange(20, 20 + payload.fxRange)
		local pos = v2add(payload.pos, v2scale(v2randomnormalized(), distance))
		circfill(pos.x, pos.y, 20 - distance / 2, payload.color)
	end
	circfill(payload.pos.x, payload.pos.y, payload.radius, payload.color)
end

function drawPayload()
	circfill(payload.pos.x, payload.pos.y, payload.radius, payload.color)
end

function payloadLoseHP(amount)
	payload.currentHP -= amount
	payload.currentHP = max(payload.currentHP, 0)
	payload.takingDamage = true
end