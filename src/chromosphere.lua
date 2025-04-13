function _init()
	-- load palette
	fetch("src/chromosphere_ingame.pal"):poke(0x5000)

	cpuLoad = 0
	screenCenter = { x = 240, y = 135 }
	firstFrame = true
	dissolveSteps = 200

	window{cursor = 0}

	initPlayer()
	initPlasma()
	initPayload()
	initGame()
end

function initGame()
	screenBounds = {left = 8, right = 472, top = 8, bottom = 262}
	frame = 0
	setupColorTable()
end

function _update()
	frame += 1
	updatePlasma()
	updatePayload()
	updatePlayer()
end

function _draw()
	restoreScreenFromMemory()
	dissolveScreen()
	drawPlasmaLower()
	drawPayloadLower()
	distortScreen()
	copyScreenToMemory()
	drawMagneticFields()
	drawPayload()
	drawPlasmaUpper()
	drawPlayer()
	drawHud()

	-- framerate display
	if (frame % 30 == 0) cpuLoad = string.format("%.0f", stat(1) * 100)
	rectfill(436, 0, 480, 10, bgColor)
	print("CPU:"..cpuLoad.."%", 437, 2, 40)
end

function restoreScreenFromMemory()
	if (firstFrame)	then
		cls(bgColor)
		firstFrame = false
	else
		-- restore stored screen
		memcpy(0x010000, 0x080000, 131072) -- 128kb = 13,1072 bytes
	end
end

function copyScreenToMemory()
	-- copy current screen to free memory
	memcpy(0x080000, 0x010000, 131072)
end

function distortScreen()
	for i = 1, distortSteps do
		local x, y = rnd(480), rnd(270)
			rectfill(x-1, y-1, x+1, y+1, pget(x, y))
	end
end

function dissolveScreen()
	-- dissolve to background color
	for i = 1, dissolveSteps do
		local x, y = rnd(480), rnd(270)
		local fillColor = bgColor
		pixelColor = pget(x,y)
		if pixelColor == plasmaColorNegative 
			or pixelColor == plasmaColorNegative + 1
			or pixelColor == plasmaColorNegative + 2
			or pixelColor == plasmaColorPositive
			or pixelColor == plasmaColorPositive + 1
			or pixelColor == plasmaColorPositive + 2
		then
			fillColor = pixelColor + 1
		elseif	pixelColor == payload.color then
			fillColor = payload.color
	  	end

		if fillColor == payload.color then
			circfill(x - 4, y, 2, fillColor)
			circfill(x, y, 1, bgColor)
		else
  			circfill(x, y, 2, fillColor)
		end
	end
end

function setupColorTable()
	-- set up color table to draw magnetic-field lines
	for i = 0, 8 do
		c_set_table(magfield.color, 48 + i, 32 + i) -- move plasma colors to mag-field colors
		c_set_table(magfield.color, 32 + i, 32 + i) -- ensure overwriting an existing mag-field color stays the same
	end
	c_set_table(magfield.color, payload.color, payload.color - 16) -- magfields draw special color over payload
	c_set_table(magfield.color, payload.color - 16, payload.color - 16) -- prevent overwrite

	poke(0x550b, 63) -- set target mask to all 1s to allow shapes to use the color table
	-- see: https://www.lexaloffle.com/dl/docs/picotron_gfx_pipeline.html
end

-- set a color in the default color table
-- source https://www.lexaloffle.com/bbs/?tid=141281
function c_set_table (draw_color, target_color, result)
	poke (0x8000 + 64 * draw_color + target_color, result)
end