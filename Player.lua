Player = class("Player", Entity)
Player.static.SPEED = 400

function Player:initialize(x, y)
    Entity.initialize(self, x, y)
    self.sprite = Sprite:new("rena.png", 50, 50)
    self.sprite.flipX = true
    self.sprite.flipY = true
    self.sprite:add("left", {1})
    self.sprite:add("right", {2})
    self.sprite:add("dance", {1, 2, 3, 4, 5, 6}, 1, true)
    self.sprite:play("dance")
    --self.sprite.offsetX = 10
    --self.sprite.offsetY = 20
    self.velocity = Vector:new(0, 0)
    self.mask = Hitbox:new(self, 50, 50)
    self.types = {"player"}
end

function Player:update(dt)
    Entity.update(self, dt)
    if love.keyboard.isDown("left") then self.velocity.x = - 1
    elseif love.keyboard.isDown("right") then self.velocity.x = 1
    else self.velocity.x = 0 end
    if love.keyboard.isDown("up") then self.velocity.y = -1
    elseif love.keyboard.isDown("down") then self.velocity.y = 1
    else self.velocity.y = 0 end

    self:moveBy(
        Player.SPEED * self.velocity.x * dt,
        Player.SPEED * self.velocity.y * dt,
        {"enemy", "walls"}
    )
end
