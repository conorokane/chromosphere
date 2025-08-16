function _init()
	-- load palette
	fetch("src/chromosphere_ingame.pal"):poke(0x5000)

	cpuLoad = 0
	screenCenter = { x = 240, y = 135 }
	firstFrame = true
	distortSteps = 120
	dissolveSteps = 130

	scrollDirection = v2make(-130, -20)
	scrollRotationRate = 0.0002
	scrollRotationScale = 0.03

	window{cursor = 0}

	initPlayer()
	initPlasma()
	initPayload()
	initEffects()
	initGame()
end

function initGame()
	screenBounds = {left = 8, right = 472, top = 8, bottom = 262}
	frame = 0
	setupColorTable()
end

function _update()
	frame += 1
	resetFlags()
	updatePlasma()
	updatePayload()
	updateEffects()
	updatePlayer()
end

function _draw()
	restoreScreenFromMemory()
	dissolveScreen()
	drawPlasmaLower()
	drawPayloadLower()
	distortScreen()
	drawEffects("lower")
	copyScreenToMemory()
	drawMagneticFields()
	drawPayload()
	drawPlayer()
	drawEffects("upper") -- called again to draw particles on top of sprites
	drawPlasmaUpper()
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
			-- rectfill(x - 2, y - 2, x + 2, y + 2, pget(x, y)) -- werxzy style
			circfill(x + rndrange(-3, 3), y + rndrange(-3, 3), 2, pget(x, y))
	end
end

function dissolveScreen()
	-- dissolve to background color
	for i = 1, dissolveSteps do
		local x, y = rnd(480), rnd(270)
		local fillColor = bgColor
		local circleRadius = rndrange(2, 4)
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
			local fillPos = v2add(v2make(x, y), v2scale(scrollDirection, 0.08))
			circfill(fillPos.x, fillPos.y, rndrange(1, 3), fillColor)
			-- circfill(x, y, circleRadius, bgColor)
		else
  			circfill(x, y, circleRadius, fillColor)
		end
	end
end

function resetFlags()
	-- resetting flags that may get set true later in the update, but before draw
	player.takingDamage = false
	payload.takingDamage = false
end

function setupColorTable()
	-- set up color table to draw magnetic-field lines
	for i = 0, 63 do
		c_set_table(magfield.color, i, 57) -- set up magfield color to draw dark red over all colors
	end
	for i = 0, 4 do
		c_set_table(magfield.color, 48 + i, 59) -- pink plasma
	end
	for i = 0, 4 do
		c_set_table(magfield.color, 52 + i, 58) -- orange plasma
	end
	c_set_table(magfield.color, bgColor, 57) -- background color 
	c_set_table(magfield.color, payload.color, 60) -- magfields draw special color over payload
	c_set_table(magfield.color, 4, 20)  -- background streaks go darker
	c_set_table(magfield.color, 31, 31) -- foreground streaks are unchanged - makes them look like they're in front
	c_set_table(magfield.color, 57, 57) -- prevent overwrite
	c_set_table(magfield.color, 58, 58) 
	c_set_table(magfield.color, 59, 59) 
	c_set_table(magfield.color, 60, 60) 

	poke(0x550b, 63) -- set target mask to all 1s to allow shapes to use the color table
	-- see: https://www.lexaloffle.com/dl/docs/picotron_gfx_pipeline.html
end

-- set a color in the default color table
-- source https://www.lexaloffle.com/bbs/?tid=141281
function c_set_table (draw_color, target_color, result)
	poke (0x8000 + 64 * draw_color + target_color, result)
end