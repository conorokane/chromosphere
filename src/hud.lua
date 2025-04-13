function drawHud()
	drawHPBar(player.hpBarPos, player.maxHP, player.currentHP)
	drawHPBar(v2add(payload.pos, payload.hpBarTarget), payload.maxHP, payload.currentHP)
end

function drawHPBar(pos, width, value) -- width = max HP
	rectfill(pos.x - width, pos.y + 1, pos.x + width, pos.y - 4, 7)
	local barLength = (value / width) * (width - 1) * 2
	rectfill(pos.x - width + 1, pos.y, pos.x - width + 1 + barLength, pos.y -3, 27)
end