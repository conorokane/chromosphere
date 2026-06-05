function initEnemies()
	enemies = {}
end

function spawnEnemy(_type, _x, _y, _speed, _frequency, _amplitude, _delay)
	if _type == 0 then
		newEnemy = {
			pos = { x = _x, y = _y }, 
			radius = 16, 
			hitPoints = 3,
			damaged = 0,
			frames = { 9, 10, 11, 12, 17, 18, 19, 20 },
			playSpeed = 0.2,
			centerOffset = { x = 0, y = 5},
			vel = v2make(_speed, 0),
			frequency = _frequency,
			amplitude = _amplitude,
			delay = _delay,
			life = 0,
			move = function(self)
				-- sine wave motion
				if self.delay < 0 then
					v2simulatefast(self)
					self.vel = v2rotate(self.vel, cos(self.life * self.frequency) * self.amplitude)
				else
					self.delay -= 1
				end
				if (self.pos.x < -30) del(enemies, self)
			end,
			draw = function(self)
				animate(self)
				spr(self.frames[flr(self.currentFrame)], self.pos.x + self.centerOffset.x - self.radius, self.pos.y + self.centerOffset.y - self.radius)
			end
		}
		newEnemy.currentFrame = rnd(#newEnemy.frames - 1)
	elseif _type == 1 then
		newEnemy = {
			pos = { x = _x + rnd(20), y = _y + rndrange(-20, 20)},
			target = { x = _x, y = _y },
			radius = 8,
			hitPoints = 2,
			damaged = 0,
			frequency = _frequency,
			amplitude = _amplitude,
			delay = _delay,
			life = 0,
			speed = _speed,
			move = function(self)
				-- lerp to target
				self.pos = v2lerp(self.pos, self.target, self.speed)
				-- randomize target
				self.life += 1
				if (self.life + self.delay) % self.frequency == self.frequency - 1 then		
					-- every 3rd jump is towards the payload
					if (self.life > self.frequency * 2) self.life = 0
					if self.life == 0 then
						local vectorToPayload = v2scale(v2normalize(v2sub(payload.pos, self.target)), self.amplitude)
						self.target = v2add(self.target, vectorToPayload)
					else
						self.target = v2add(self.target, v2scale(v2randomnormalized(), rndrange(self.amplitude/2, self.amplitude))) -- random jump
						if (self.target.y < 30) self.target.y += 30 -- avoid edges
						if (self.target.y > 240) self.target.y -= 30
						if (self.target.x < payload.pos.x) self.target.x += 10
					end
					-- spray some particles backwards
					local sprayVector = v2normalize(v2sub(self.pos, self.target))
					spawnParticle(self.pos, v2scale(sprayVector, 2), 0.90, 20, { 49, 50, 51 }, 0.5)
				end
		
	
			end,
			draw = function(self)
				local sprite = 24
				if (self.pos.x - self.target.x > 1) sprite = 25
				if (self.pos.x - self.target.x < -1) sprite = 26			
				spr(sprite, self.pos.x - 16, self.pos.y - 16)
			end
		}
	end
	newEnemy.type = _type
	add(enemies, newEnemy)
end

function updateEnemies()
	for e in all(enemies) do
		e:move()
	end
end

function drawEnemies()
	for e in all(enemies) do
		if e.damaged > 0 then 
			setPaletteDamage(true)
			e.damaged -= 1
		end
		e:draw()
		setPaletteDamage(false)
	end
end

-- swap colors to flash damaged enemies
function setPaletteDamage(damaged)
	if damaged then
		pal(24, 7)
		pal(8, 7)
	else
		pal(24, 24)
		pal(8, 8)
	end
end

function takeDamage(e, value, push)
	e.hitPoints -= value
	if e.hitPoints == 0 then
		explode(e)
		del(enemies, e)
	else
		e.pos.x += push
		e.damaged = 5
	end
end

function explode(e)
	for i = 0, 16 do
		local randomVector = v2rotate( { x = 4, y = 0 }, rndrange(-120, 120))
		local initialVector = v2scale(v2right, rndrange(2, 4))
		spawnParticle( e.pos, v2add(initialVector, randomVector), 0.95, rndrange(6, 20), { 36, 35, 34 }, 1)
	end
	for i = 1, 5 do
		circfill(e.pos.x + rndrange(0, e.radius * 3), e.pos.y + rndrange(-e.radius / 2, e.radius / 2), rndrange(10, e.radius), rndrange(33, 37))
	end
	-- camera splats
	-- save these for a fireball explosion - not suitable for organic enemy deaths
	-- for i = 0, rndrange(1, 3) do
	-- 	local splatVel = v2rotate( v2scale({ x = 4, y = 0 }, rndrange(0.5, 1.5)), rndrange(-45, 45))
	-- 	spawnCameraSplat(e.pos, splatVel, 0.9, rndrange(20, 60), rndrange(5, 30))
	-- end
end