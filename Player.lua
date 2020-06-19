Player = class("Player", Entity)
Player.static.SPEED = 150
Player.static.GRAVITY = 600
Player.static.JUMP_POWER = 150

function Player:initialize(x, y)
    Entity.initialize(self, x, y)
    self.graphic = Sprite:new("player.png", 16, 32)
    self.graphic:add("idle", {1})
    self.graphic:add("run", {2, 3, 4, 3}, 6, true)
    self.graphic:add("jump", {5})
    self.graphic:add("crouch", {6})
    self.graphic:add("jetpack", {7, 8}, 4, true)
    self.velocity = Vector:new(0, 0)
    self.mask = Hitbox:new(self, 8, 23)
    self.graphic.offsetX = -5;
    self.graphic.offsetY = -9;
    self.layer = -1
    self.types = {"player"}
    self:loadSfx({"jump.wav", "run.wav"})
    input.define("jump", "z")
    input.define("up", "up")
    input.define("down", "down")
    input.define("left", "left")
    input.define("right", "right")
end

function Player:isOnGround()
    if #self:collide(self.x, self.y + 0.01, {"walls"}) > 0 then
        return true
    else
        return false
    end
end

function Player:movement(dt)
    if input.down("left") then self.velocity.x = -Player.SPEED
    elseif input.down("right") then self.velocity.x = Player.SPEED
    else self.velocity.x = 0 end
    if self:isOnGround() then
        self.velocity.y = 0
        if input.pressed("jump") then
            self.velocity.y = -Player.JUMP_POWER
        end
    else
        self.velocity.y = self.velocity.y + Player.GRAVITY * dt
    end
    self:moveBy(
        self.velocity.x * dt,
        self.velocity.y * dt,
        {"enemy", "walls"}
    )
end

function Player:animation()
    if self.velocity.x < 0 then
        self.graphic.flipX = true
    elseif self.velocity.x > 0 then
        self.graphic.flipX = false
    end
    if self.graphic.flipX then
        self.graphic.offsetX = -3;
    else
        self.graphic.offsetX = -5;
    end

    if self:isOnGround() then
        if self.velocity.x ~= 0 then
            self.graphic:play("run")
        else
            self.graphic:play("idle")
        end
    else
        self.graphic:play("jump")
    end
end

function Player:update(dt)
    self:movement(dt)
    self:animation()
    Entity.update(self, dt)

    --if self.velocity.x ~= 0 or self.velocity.y ~= 0 then
        --self.sfx["run"]:loop()
    --else
        --self.sfx["run"]:stop()
    --end
end
