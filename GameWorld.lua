GameWorld = class("GameWorld", World)

local wasDKeyDown = false

function GameWorld:initialize()
    World.initialize(self)
    local player = Player:new(30, 30, true)
    self:add(player)
    --local enemy = Enemy:new(
        --love.graphics.width / 4, love.graphics.height / 4, true
    --)
    --self:add(enemy)
    level = Level:new("level.json")
    self:add(level)
end

function GameWorld:update(dt)
    if love.keyboard.isDown("d") and not wasDKeyDown then
        ammo.world = GameWorld:new()
    end
    wasDKeyDown = love.keyboard.isDown("d")
    World.update(self, dt)
end
