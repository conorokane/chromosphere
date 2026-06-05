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
	elipse (payload.pos.x, payload.pos.y, 37, 37 * sin(frame * 0.0013) / 2, 20, 0.5 + (frame * 0.0013), 26, 2)
	elipse (payload.pos.x, payload.pos.y, 40, 40 * sin(frame * 0.0012) / 2, 20, 0.5 + (frame * 0.0012), 11, 2)
	elipse (payload.pos.x, payload.pos.y, 43, 43 * sin(frame * 0.0011) / 2, 20, 0.5 + (frame * 0.0011), 27, 2)
	elipse (payload.pos.x, payload.pos.y, 46, 46 * sin(frame * 0.001) / 2, 20, 0.5 + (frame * 0.001), 3, 2)
	-- payload graphics
	circfill(payload.pos.x, payload.pos.y, payload.radius, blend_payload)

	-- upper half of elipses
	elipse (payload.pos.x, payload.pos.y, 37, 37 * sin(frame * 0.0013) / 2, 20, frame * 0.0013, 26, 2)
	elipse (payload.pos.x, payload.pos.y, 40, 40 * sin(frame * 0.0012) / 2, 20, frame * 0.0012, 11, 2)
	elipse (payload.pos.x, payload.pos.y, 43, 43 * sin(frame * 0.0011) / 2, 20, frame * 0.0011, 27, 2)
	elipse (payload.pos.x, payload.pos.y, 46, 46 * sin(frame * 0.001) / 2, 20, frame * 0.001, 3, 2)
end

function payloadLoseHP(amount)
	payload.currentHP -= amount
	payload.currentHP = max(payload.currentHP, 0)
	payload.takingDamage = true
end