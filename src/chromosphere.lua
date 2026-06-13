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
	
	initGame()
end

function initGame()
	initPlayer()
	initPlasma()
	initPayload()
	initEffects()
	initEnemies()
	screenBounds = {left = 8, right = 472, top = 8, bottom = 262}
	frame = 0
	setupColorTableFromSprite()

	-- type 2 enemy
	spawnEnemy(2, 430, 135, 1, 0.03, 30, 0)
end

function _update()
	frame += 1
	resetFlags()
	updatePlasma()
	updatePayload()
	updateEffects()
	updateEnemies()
	updatePlayer()

	-- testSpawns()
end

function _draw()
	restoreScreenFromMemory()
	dissolveScreen()
	drawPlasmaLower()
	drawPayloadLower()
	distortScreen()
	drawLogo()
	drawMagneticFields("lower")
	drawEffects("lower")
	copyScreenToMemory()
	drawMagneticFields("upper")
	drawPayload()
	drawPlayer()
	drawEffects("upper") -- called again to draw particles on top of sprites
	drawPlasmaUpper()
	drawEnemies()
	drawLightingEffects()
	drawHud()
	drawCPU()
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
			local bgColor = pget(x,y)
			if (bgColor == blend_payload) fillp(dotPatternThin)
			circfill(x + rndrange(-3, 3), y + rndrange(-3, 3), 2, pget(x, y))
			fillp()
	end
end

function dissolveScreen()
	-- dissolve to background color
	for i = 1, dissolveSteps do
		local x, y = rnd(480), rnd(270)
		local circleRadius = rndrange(2, 4)
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
		elseif	pixelColor == blend_payload then
			fillColor = blend_payload
		end
		
		if fillColor == blend_payload then
			fillp(dotPatternThick)
			-- offset circle position to make payload trail move with the scroll direction
			local fillPos = v2add(v2make(x, y), v2scale(scrollDirection, 0.15))
			circfill(fillPos.x, fillPos.y, rndrange(1, 3), fillColor)
			fillp() -- reset fill pattern
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
		c_set_table(magfield.color, i, 9) -- set up magfield color to draw orange
	end
	for i = 0, 4 do
		c_set_table(magfield.color, 48 + i, 59) -- pink plasma
	end
	for i = 0, 4 do
		c_set_table(magfield.color, 52 + i, 58) -- orange plasma
	end
	c_set_table(magfield.color, bgColor, 9) -- background color 
	c_set_table(magfield.color, payload.color, 60) -- magfields draw special color over payload
	c_set_table(magfield.color, 4, 20)  -- background streaks go darker
	c_set_table(magfield.color, 31, 31) -- foreground streaks are unchanged - makes them look like they're in front
	-- prevent magfield changing itself
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

function setupColorTableFromSprite()
	-- see: https://www.youtube.com/watch?v=Z-0EU4DU6RE
	-- https://ko-fi.com/post/Transparency-Light-and-Shadow-in-PICOTRON--The-m-D1D41VLZEF
	local colorTableSprite = get_spr(255)
	memmap(colorTableSprite, 0x8000)
	poke(0x550b, 63) -- set target mask to all 1s to allow shapes to use the color table
end

function drawCPU()
	if (frame % 30 == 0) cpuLoad = string.format("%.0f", stat(1) * 100)
	rectfill(436, 260, 480, 270, bgColor)
	print("CPU:"..cpuLoad.."%", 437, 262, 40)
end

function drawLogo()
	local left = 10
	local top = 10
	local spacing = 5
	local shadowOffset = 3
	local c, h, r, o, m, s, p, e = 31, 35, 35, 33, 36, 31, 34, 32
	-- drop shadow
	pal(53, 57) -- swap yellow for shade
	left += shadowOffset
	top += shadowOffset
	spr(64, left, top)
	spr(65, left + spacing + c, top)
	spr(66, left + spacing * 2 + c + h, top)
	spr(67, left + spacing * 3 + c + h + r, top)
	spr(68, left + spacing * 4 + c + h + r + o, top)
	spr(67, left + spacing * 5 + c + h + r + o + m, top)
	spr(69, left + spacing * 6 + c + h + r + o + m + o, top)
	spr(70, left + spacing * 7 + c + h + r + o + m + o + s, top)
	spr(65, left + spacing * 8 + c + h + r + o + m + o + s + p, top)
	spr(71, left + spacing * 9 + c + h + r + o + m + o + s + p + h, top)
	spr(66, left + spacing * 10 + c + h + r + o + m + o + s + p + h + e, top)
	spr(71, left + spacing * 11 + c + h + r + o + m + o + s + p + h + e + r, top)
	-- yellow text
	pal(53, 53) -- swap yellow for shade
	left -= shadowOffset
	top -= shadowOffset
	spr(64, left, top)
	spr(65, left + spacing + c, top)
	spr(66, left + spacing * 2 + c + h, top)
	spr(67, left + spacing * 3 + c + h + r, top)
	spr(68, left + spacing * 4 + c + h + r + o, top)
	spr(67, left + spacing * 5 + c + h + r + o + m, top)
	spr(69, left + spacing * 6 + c + h + r + o + m + o, top)
	spr(70, left + spacing * 7 + c + h + r + o + m + o + s, top)
	spr(65, left + spacing * 8 + c + h + r + o + m + o + s + p, top)
	spr(71, left + spacing * 9 + c + h + r + o + m + o + s + p + h, top)
	spr(66, left + spacing * 10 + c + h + r + o + m + o + s + p + h + e, top)
	spr(71, left + spacing * 11 + c + h + r + o + m + o + s + p + h + e + r, top)
end

function testSpawns()
	-- test enemy spawns
	
	-- type 0 enemy wave
	-- if (frame % 450 == 10) then
	-- 	local randomY = rndrange(50, 170) -- higher top value because they always start curving down
	-- 	local randomX = rndrange(520, 700) -- further off screen so they sometimes enter curving up
	-- 	for i = 5, 1, -1 do
	-- 		spawnEnemy(0, randomX, randomY, -0.8, 0.002, 0.4, i * 30)
	-- 	end
	-- end

	-- type 1 enemy clump
	if frame % 800 == 60 then
		for i = 0, 10 do
			spawnEnemy(1, 490, 135, 0.1, 40, 20, i * 2)
		end
	end

	-- spray test plasma
	-- local sign = 1
	-- if (rnd() < 0.5) sign = -1
	-- if (frame % 400 == 20) sprayPlasma(v2randominrange(120, 180), rndrange(15, 25), sign, rndrange(1, 1.5))
end

