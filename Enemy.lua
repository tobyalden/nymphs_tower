require("ammo")
Enemy = class("Enemy", Entity)

function Enemy:initialize(x, y)
    Entity.initialize(self, x, y)
    self.sprite = love.graphics.newImage("mion.png")
    self.width = 50
    self.height = 50
    self.type = "enemy"
end

function Enemy:update(dt)
end

function Enemy:draw()
    love.graphics.draw(self.sprite, self.x, self.y)
end
