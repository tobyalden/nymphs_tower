MainMenu = class("MainMenu", World)

--MainMenu.static.CAMERA_SPEED = 1.5

function MainMenu:initialize()
    World.initialize(self)
    self.menu = Menu:new({"NEW GAME", "CONTINUE", "OPTIONS"})
    self:addGraphic(Sprite:new("mainmenu.png"))
    -- self.menu = Menu:new({"NEW GAME", "CONTINUE"})
    self:add(self.menu)
    self.curtain = Curtain:new()
    self:add(self.curtain)
    self.curtain:fadeOut()
    collectgarbage("collect")
end

function MainMenu:update(dt)
    World.update(self, dt)
end
