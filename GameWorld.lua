GameWorld = class("GameWorld", World)

function GameWorld:initialize()
    World.initialize(self)
    local player = Player:new(
        love.graphics.width / 4, love.graphics.height / 4, true
    )
    self:add(player)
    --local enemy = Enemy:new(
        --love.graphics.width / 4, love.graphics.height / 4, true
    --)
    --self:add(enemy)
    local level = Level:new("level.json")
    self:add(level)
end
