GameWorld = class("GameWorld", World)

bumpWorld = bump.newWorld()

function GameWorld:initialize()
    World.initialize(self)
    local player = Player:new(love.graphics.width / 2, love.graphics.height / 2)
    bumpWorld:add(player, player.x, player.y, 50, 50)
    self:add(player)
    local enemy = Enemy:new(love.graphics.width / 4, love.graphics.height / 4)
    bumpWorld:add(enemy, enemy.x, enemy.y, 50, 50)
    self:add(enemy)
end
