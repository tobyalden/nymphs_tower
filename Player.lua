require("ammo")
Player = class("Player", Entity)
Player.static.SPEED = 400

function Player:initialize(x, y)
    Entity.initialize(self, x, y)
    self.sprite = love.graphics.newImage("rena.png")
    self.velocity = Vector:new(0, 0)
end

function Player:update(dt)
    if love.keyboard.isDown("left") then self.velocity.x = - 1
    elseif love.keyboard.isDown("right") then self.velocity.x = 1
    else self.velocity.x = 0 end
    if love.keyboard.isDown("up") then self.velocity.y = -1
    elseif love.keyboard.isDown("down") then self.velocity.y = 1
    else self.velocity.y = 0 end
    local goalX = self.x + Player.SPEED * self.velocity.x * dt
    local goalY = self.y + Player.SPEED * self.velocity.y * dt
    local actualX, actualY, cols, len = bumpWorld:move(self, goalX, goalY)
    self.x = actualX
    self.y = actualY
end

function Player:draw()
    love.graphics.draw(self.sprite, self.x, self.y)
end
