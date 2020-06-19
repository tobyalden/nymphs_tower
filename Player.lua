Player = class("Player", Entity)
Player.static.SPEED = 200
Player.static.GRAVITY = 4

function Player:initialize(x, y)
    Entity.initialize(self, x, y)
    self.graphic = Sprite:new("player.png", 16, 32)
    self.graphic:add("idle", {1})
    self.graphic:add("run", {2, 3, 4, 3}, 4, true)
    self.graphic:add("jump", {5})
    self.graphic:add("crouch", {6})
    self.graphic:add("jetpack", {7, 8}, 4, true)
    self.velocity = Vector:new(0, 0)
    self.mask = Hitbox:new(self, 8, 23)
    self.graphic.offsetX = -5;
    self.graphic.offsetY = -9;
    self.types = {"player"}
    self:loadSfx({"jump.wav", "run.wav"})
    input.define("jump", "z")
    input.define("up", "up")
    input.define("down", "down")
    input.define("left", "left")
    input.define("right", "right")
end

function Player:isOnGround()
    if #self:collide(self.x, self.y + 1, {"walls"}) > 0 then
        return true
    else
        return false
    end
end

function Player:update(dt)
    Entity.update(self, dt)
    if input.down("left") then self.velocity.x = - 1
    elseif input.down("right") then self.velocity.x = 1
    else self.velocity.x = 0 end
    if self:isOnGround() then
        self.velocity.y = 0
    else
        self.velocity.y = self.velocity.y + Player.GRAVITY * dt
    end
    self:moveBy(
        Player.SPEED * self.velocity.x * dt,
        Player.SPEED * self.velocity.y * dt,
        {"enemy", "walls"}
    )
    if input.down("jump") then
        self.sfx["jump"]:play()
    end
    if self.velocity.x ~= 0 or self.velocity.y ~= 0 then
        self.sfx["run"]:loop()
    else
        self.sfx["run"]:stop()
    end
end
