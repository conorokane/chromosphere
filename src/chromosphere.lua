function _init()
	-- load palette
	fetch("src/0.pal"):poke(0x5000)

	cpuLoad = 0
	screenCenter = { x = 240, y = 135 }
	fleetCenter = { x = 70, y = 135 }

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
	drawMagneticFields()
	drawUpperPlasma()
	drawPlayer()

	-- framerate display
	if (frame % 30 == 0) cpuLoad = string.format("%.0f", stat(1) * 100)
	rectfill(436, 0, 480, 10, bgColor)
	print("CPU:"..cpuLoad.."%", 437, 2, 40)
end

