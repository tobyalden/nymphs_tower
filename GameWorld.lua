GameWorld = class("GameWorld", World)

local wasDKeyDown = false

function GameWorld:initialize()
    World.initialize(self)
    local player = Player:new(30, 30, true)
    self:add(player)
    level = Level:new("level.json")
    self:add(level)
    ui = UI:new()
    self:add(ui)
    background = Background:new()
    self:add(background)
    self:loadSfx({"longmusic.ogg"})
    self.sfx["longmusic"]:loop()
end

function GameWorld:update(dt)
    if love.keyboard.isDown("d") and not wasDKeyDown then
        ammo.world = GameWorld:new()
    end
    wasDKeyDown = love.keyboard.isDown("d")
    World.update(self, dt)
end
