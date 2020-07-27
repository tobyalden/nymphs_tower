MainMenu = class("MainMenu", World)

--MainMenu.static.CAMERA_SPEED = 1.5

function MainMenu:initialize()
    World.initialize(self)
    self.menu = Menu:new({"NEW GAME", "CONTINUE", "OPTIONS"})
    self:add(self.menu)
end

function MainMenu:update(dt)
    World.update(self, dt)
end
