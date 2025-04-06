function _init()
	-- load palette
	fetch("src/0.pal"):poke(0x5000)

	bgcolor = 20

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
	updatePlasma()
	updatePlayer()
end

function _draw()
	drawPlasma()
	drawPlayer()
end

