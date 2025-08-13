function drawHud()
	drawHPBar(player.hpBarPos, player.maxHP, player.currentHP, player.takingDamage)
	drawHPBar(v2add(payload.pos, payload.hpBarTarget), payload.maxHP, payload.currentHP, payload.takingDamage)
end

function drawHPBar(pos, width, value, warning) -- width = max HP
	-- use subsprite because the UI sprite is 32x32
	sspr(1, 0, 0, 3, 7, pos.x - width - 2, pos.y - 3)
	sspr(1, 0, 0, 3, 7, pos.x + width, pos.y - 3, 3, 7, true)
	local barLength = (value / width) * width * 2
	--bar background
	rectfill(pos.x - width - 1, pos.y - 2, pos.x + width + 1, pos.y + 2, 5)
	rectfill(pos.x - width - 1, pos.y - 1, pos.x + width + 1, pos.y + 1, 21)

	local barColor = 26
	if (warning) barColor = 8
	rectfill(pos.x - width, pos.y - 1, pos.x - width + barLength, pos.y + 1, barColor)
end