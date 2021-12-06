MainMenu = class("MainMenu", World)

--MainMenu.static.CAMERA_SPEED = 1.5

function MainMenu:initialize()
    collectgarbage("restart")
    World.initialize(self)
    self.menu = Menu:new({"NEW GAME", "CONTINUE", "OPTIONS"})
    self:addGraphic(Sprite:new("mainmenu.png"))
    local versionNumber = Text:new("v.1.8", 9)
    versionNumber.offsetX = 2
    versionNumber.offsetY = 168
    self:addGraphic(versionNumber)
    -- self.menu = Menu:new({"NEW GAME", "CONTINUE"})
    self:add(self.menu)
    self.curtain = Curtain:new()
    self:add(self.curtain)
    self.curtain:fadeOut()

    self.message = Text:new("PRESS SPACE TO SELECT", 10, "arial.ttf", {1, 1, 1}, 320, "center")
    self.message.offsetX = -40
    self.message.offsetY = 157
    self:addGraphic(self.message)
end

function MainMenu:update(dt)
    World.update(self, dt)
end
