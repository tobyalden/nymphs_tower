OptionsMenu = class("OptionsMenu", Entity)

function OptionsMenu:initialize(itemNames)
    Entity.initialize(self)
    self.x = 30
    self.y = 25

    self.graphic = Graphiclist:new({})
    self.itemNames = itemNames

    for i, itemName in ipairs(itemNames) do
        local item = Text:new(itemName, 24)
        item.offsetY = 32 * (i - 1)
        self.graphic:add(item)
        if i == 1 then
            self.fullscreenMenuItem = item
        elseif i == 2 then
            self.speedrunMenuItem = item
        end
    end

    self.cursor = Sprite:new("cursor.png")
    self.cursorIndex = 1
    self.cursor.offsetX = -16
    self.cursor.offsetY = 5 + (self.cursorIndex - 1) * 32
    self.graphic:add(self.cursor)

    self.message = Text:new("", 10, "arial.ttf", {1, 1, 1}, 320, "center")
    self.message.offsetX = -self.x
    self.message.offsetY = -self.y + 140
    self.graphic:add(self.message)

    self.startTimer = self:addTween(Alarm:new(3, function()
        ammo.world = MainMenu:new()
    end))

    self:loadSfx({"menunew.wav", "menumove.wav", "menuback.wav", "menucontinue.wav", "menuno.wav"})
end

function OptionsMenu:update(dt)
    local oldCursorIndex = self.cursorIndex
    if not self.startTimer.active then
	    if input.pressed("up") then
	        self.cursorIndex = self.cursorIndex - 1
	    elseif input.pressed("down") then
	        self.cursorIndex = self.cursorIndex + 1
	    elseif input.pressed("jump") then
	        if self.cursorIndex == 1 then
	        	-- FULLSCREEN
		        self.sfx["menumove"]:play()
		        push:switchFullscreen(gameWidth * windowedScale, gameHeight * windowedScale)
	        elseif self.cursorIndex == 2 then
	        	-- SPEEDRUN MODE
		        self.sfx["menumove"]:play()
		        GameWorld.isSpeedrunMode = not GameWorld.isSpeedrunMode
	        elseif self.cursorIndex == 3 then
	        	-- BACK
	        	self:fadeToMainMenu()
		        self.sfx["menuback"]:play()
	        end
	    end
	end

    self.cursorIndex = math.clamp(self.cursorIndex, 1, #self.itemNames)
    if oldCursorIndex ~= self.cursorIndex then
        self.sfx["menumove"]:play()
    end

    if self.cursorIndex == 1 then
    	-- FULLSCREEN
    	self.message:setText("TOGGLE FULLSCREEN")
    elseif self.cursorIndex == 2 then
    	-- SPEEDRUN MODE
    	self.message:setText("ENABLES ONSCREEN TIMER AND RESET BUTTON")
    elseif self.cursorIndex == 3 then
    	self.message:setText("RETURN TO MAIN MENU")
    	-- BACK
    end

    self.cursor.offsetX = -19
    self.cursor.offsetY = 5 + (self.cursorIndex - 1) * 33

    if push:isFullscreen() then
	    self.fullscreenMenuItem:setText("FULLSCREEN: ON")
	else
	    self.fullscreenMenuItem:setText("FULLSCREEN: OFF")
	end

    if GameWorld.isSpeedrunMode then
	    self.speedrunMenuItem:setText("SPEEDRUN MODE: ON")
	else
	    self.speedrunMenuItem:setText("SPEEDRUN MODE: OFF")
	end

    Entity.update(self, dt)
end

function OptionsMenu:fadeToMainMenu()
    self.startTimer:start()
    self.world.curtain:fadeIn()
end
