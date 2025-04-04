function _init()
	-- load palette
	fetch("src/0.pal"):poke(0x5000)

	initPlayer()
	initGame()
	initPlasma()
end

function initGame()
	screenBounds = {left = 8, right = 472, top = 8, bottom = 262}
	frame = 0
end

function _update()
	frame += 1
	updatePlayer()
	updatePlasma()
end

function _draw()
	cls(21)
	drawPlayer()
	drawPlasma()
end

