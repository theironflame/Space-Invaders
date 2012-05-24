--Fun class creating function
function class(superclass, name)
    local cls = superclass and superclass() or {}
    cls.__name = name or ""
    cls.__super = superclass
    return setmetatable(cls, {__call = function (c, ...)
        self = setmetatable({__class = cls}, cls)
        if cls.__init then
            cls.__init(self, ...)
        end
        return self
    end})
end

local Bullet = class()
local Alien = class()

function Bullet:__init(x,y)
	self.x=x
	self.y=y
	self.used=false
end

function Alien:__init(x,y,score,form)
	self.x=x
	self.y=y
	self.score=score
	self.form=form
	self.dead = false
end

function love.load()
	spriteWidth = 80
	spriteHeight = 80
	
	mobWidth = 10
	mobHeight = 6
	
	font = love.graphics.newFont(20)
	love.graphics.setFont(font)
	
	mobX = 0
	score = 0
	
	fired = false
	playing = false
	spawned = false
	
	mZoom = 6
	uZoom = 6
	
	sel=0
	
	round = 1
	
	userX = 0
	userY = 768-8*uZoom
	
	moveSwitch = true
	
	speed = 3
	nFire = love.timer.getTime()
	lFire = love.timer.getTime()
	
	nMove = love.timer.getTime()
	lMove = love.timer.getTime()
	
	alienImage = love.graphics.newImage("Aliens.png")
	alienImage:setFilter("nearest", "nearest")
	
	userQuad = love.graphics.newQuad(16,24,16,8,alienImage:getWidth(),alienImage:getHeight())
	bulletQuad = love.graphics.newQuad(2,26,4,6,alienImage:getWidth(),alienImage:getHeight())
	
	bullets = {}
	aliens = {}
	
	alienQuad = {}
	
	alienQuad[0] = love.graphics.newQuad(0,0,8,8,alienImage:getWidth(),alienImage:getHeight())
	alienQuad[1] = love.graphics.newQuad(8,0,8,8,alienImage:getWidth(),alienImage:getHeight())
	alienQuad[2] = love.graphics.newQuad(16,0,8,8,alienImage:getWidth(),alienImage:getHeight())
	alienQuad[3] = love.graphics.newQuad(16,16,16,8,alienImage:getWidth(),alienImage:getHeight())
end

function fire()
	if not fired then
		table.insert(bullets,Bullet(userX+8*uZoom,userY+3*uZoom))
		fired=true
	end
end

function updateBullets(dt)
	nMove = love.timer.getTime()
	--if not table.getn(aliens) == 0 then
		--love.event.push('quit')
		if (nMove-lMove) > 0.8 and table.getn(aliens) > 0 then
			lMove=love.timer.getTime()
			if not aliens[1] == nil and aliens[1].x<=0 then
				moveSwitch=true
			elseif mobX>=240 then
				moveSwitch=false
			end
			if moveSwitch then
				mobX = mobX+20
			else
				mobX = mobX-20
			end
			for ii,vv in pairs(aliens) do
				if aliens[1].x<=0 then
					vv.y = vv.y+spriteHeight/4
				end
				if moveSwitch then
					vv.x = vv.x+spriteWidth/4
					--mobX = mobX+spriteWidth/4
				else
					vv.x = vv.x-spriteWidth/4
					--mobX = mobX-spriteWidth/4
				end
			end
		end

		for i,v in pairs(bullets) do
			if v.used or v.y+6<0 then
				table.remove(bullets,i)
				fired=false
				break
			end
			v.y = v.y - (dt*1000)
			for j,k in pairs(aliens) do 
				if v.x+4>k.x and v.x<k.x+spriteWidth and v.y+6>k.y and v.y<k.y+spriteHeight then
					v.used = true
					if k.form == 1 then
						score = score+k.score
					elseif k.form == 0 then
						score = score+k.score
					elseif k.form == 2 then
						score = score+k.score
					end
					table.remove(aliens,j)
					fired=false
				end
			end
		end
	--else
		--round = round+1
	--end
end

function love.update(dt)
	if playing then
		if not aliens[table.getn(aliens)-1] == nil then
			if aliens[table.getn(aliens)-1].y>768 then
				playing = false
			end
		end
	
		nFire = love.timer.getTime()
		--if spawned then
			updateBullets(dt)
		--end
		speed = 500*dt
		
		if love.keyboard.isDown("up") then
			fire()
			lFire = love.timer.getTime()
		end
		if love.keyboard.isDown("left") then
			userX = userX-speed
		elseif love.keyboard.isDown("right") then
			userX = userX+speed
		end
		
		if userX < 0 then
			userX = 0
		elseif userX+16*uZoom > 1024 then
			userX = 1024-16*uZoom
		end
	else
	if love.keyboard.isDown("up") and sel<1 then
		sel=sel+1
	elseif love.keyboard.isDown("down") and sel>0 then
		sel=sel-1
	end
	if love.keyboard.isDown("return") then
		if sel == 0 then
			love.event.push('quit')
		elseif sel == 1 then
			updateAlienSet()
			playing = true
			spawned = true
		end
	end
	end
	if love.keyboard.isDown("escape") then
		love.event.push('quit')
	end
end

function updateAlienSet()
	local i = 0
	for x=0, mobWidth-1 do
		for y=0, mobHeight-1 do
			i = i+1
			if y<1 then
				aliens[i] = Alien(x*spriteWidth,y*spriteHeight,5,1)
			elseif y<4 then
				aliens[i] = Alien(x*spriteWidth,y*spriteHeight,10,0)
			else
				aliens[i] = Alien(x*spriteWidth,y*spriteHeight,15,2)
			end
		end
	end
	table.insert(aliens,Alien(0,0,50,3))
end

function love.draw()
	for i,v in pairs(aliens) do
		love.graphics.drawq(alienImage,alienQuad[v.form],v.x,v.y,0,mZoom,mZoom)
	end
	for i,v in pairs(bullets) do
		love.graphics.drawq(alienImage,bulletQuad,v.x,v.y,0,3,3)
	end
	love.graphics.print("SCORE:"..score,0,20)
	love.graphics.print("FPS:"..love.timer.getFPS(),0,0)
	--love.graphics.print("Playing: "..playing,0,40)
	if not playing then
		if sel == 0 then
			love.graphics.print(">",(1024/2)-70,520)
		elseif sel == 1 then
			love.graphics.print(">",(1024/2)-70,500)
		end
		love.graphics.print("Start",(1024/2)-50,500)
		love.graphics.print("Quit",(1024/2)-50,520)
	end
	
	love.graphics.drawq(alienImage,userQuad,userX,userY,0,uZoom,uZoom)
end







