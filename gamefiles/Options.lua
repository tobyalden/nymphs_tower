Options = class("Options", World)

function Options:initialize()
    World.initialize(self)
    self.menu = OptionsMenu:new({"FULLSCREEN", "SPEEDRUN MODE", "VSYNC", "BACK"})
    self:addGraphic(Sprite:new("optionsmenu.png"))
    self:add(self.menu)
    self.curtain = Curtain:new()
    self:add(self.curtain)
    self.curtain:fadeOut()
end

function Options:update(dt)
    World.update(self, dt)
end
