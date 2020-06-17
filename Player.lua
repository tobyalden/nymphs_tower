Player = class("Player", Entity)
Player.static.SPEED = 400

function Player:initialize(x, y)
    Entity.initialize(self, x, y)
    self.graphic = Sprite:new("rena.png", 50, 50)
    self.graphic:add("left", {1})
    self.graphic:add("right", {2})
    self.graphic:add("dance", {1, 2, 3, 4, 5, 6}, 1, true)
    self.velocity = Vector:new(0, 0)
    self.mask = Hitbox:new(self, 50, 50)
    self.types = {"player"}
    self:loadSfx({"jump.wav", "run.wav"})
    input.define("jump", "z")
    input.define("up", "up")
    input.define("down", "down")
    input.define("left", "left")
    input.define("right", "right")
end

function Player:update(dt)
    Entity.update(self, dt)
    if input.down("left") then self.velocity.x = - 1
    elseif input.down("right") then self.velocity.x = 1
    else self.velocity.x = 0 end
    if input.down("up") then self.velocity.y = -1
    elseif input.down("down") then self.velocity.y = 1
    else self.velocity.y = 0 end
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
