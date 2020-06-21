Player = class("Player", Entity)
Player.static.SPEED = 150
Player.static.GRAVITY = 600
Player.static.MAX_FALL_SPEED = 300
Player.static.MAX_RISE_SPEED = 150
Player.static.JUMP_POWER = 150
Player.static.JETPACK_POWER = 900 * 1
Player.static.STARTING_HEALTH = 100
Player.static.STARTING_FUEL = 100
Player.static.JETPACK_FUEL_USE_RATE = 50
Player.static.JETPACK_FUEL_RECOVER_RATE = 100
Player.static.SHOT_COOLDOWN = 1

-- endgame item: anti-gravity belt that halves gravity

local releasedJump

function Player:initialize(x, y)
    Entity.initialize(self, x, y)

    releasedJump = false

    input.define("up", "up")
    input.define("down", "down")
    input.define("left", "left", "[")
    input.define("right", "right", "]")
    input.define("jump", "z")
    input.define("shoot", "x")

    self.mask = Hitbox:new(self, 8, 21)
    self.types = {"player"}
    self.velocity = Vector:new(0, 0)

    self.graphic = Sprite:new("player.png", 16, 32)
    self.graphic:add("idle", {1})
    self.graphic:add("run", {2, 3, 4, 3}, 6, true)
    self.graphic:add("jump", {5})
    self.graphic:add("crouch", {5})
    self.graphic:add("jetpack", {6, 7}, 4, true)
    self.graphic.offsetX = -5;
    self.graphic.offsetY = -11;
    self.layer = -1

    self:loadSfx({"jump.wav", "run.wav"})

    self.health = Player.STARTING_HEALTH
    self.fuel = Player.STARTING_FUEL
    self.shotCooldown = self:addTween(Alarm:new(Player.SHOT_COOLDOWN))
end

function Player:isOnGround()
    if #self:collide(self.x, self.y + 0.01, {"walls"}) > 0 then
        return true
    else
        return false
    end
end

function Player:moveCollideX(collided)
    self.velocity.x = 0
end

function Player:moveCollideY(collided)
    if self.velocity.y < 0 then
        self.velocity.y = -self.velocity.y / 1.25
    end
end

function Player:movement(dt)
    if input.down("left") then self.velocity.x = -Player.SPEED
    elseif input.down("right") then self.velocity.x = Player.SPEED
    else self.velocity.x = 0 end
    if self:isOnGround() then
        self.velocity.y = 0
        isJetpackOn = false
        self.fuel = math.min(
            self.fuel + Player.JETPACK_FUEL_RECOVER_RATE * dt,
            Player.STARTING_FUEL
        )
        if input.pressed("jump") then
            self.velocity.y = -Player.JUMP_POWER
            releasedJump = false
        end
    else
        if input.released("jump") then
            releasedJump = true
        end
        if input.down("jump") and releasedJump and self.fuel > 0 then
            isJetpackOn = true
        else
            isJetpackOn = false
        end
        if isJetpackOn then
            self.velocity.y = self.velocity.y - Player.JETPACK_POWER * dt
            self.fuel = math.max(self.fuel - Player.JETPACK_FUEL_USE_RATE * dt, 0)
        end
        self.velocity.y = self.velocity.y + Player.GRAVITY * dt
    end
    self.velocity.y = math.clamp(
        self.velocity.y, -Player.MAX_RISE_SPEED, Player.MAX_FALL_SPEED
    )
    self:moveBy(
        self.velocity.x * dt,
        self.velocity.y * dt,
        {"walls"}
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
        if isJetpackOn then
            self.graphic:play("jetpack")
        else
            self.graphic:play("jump")
        end
    end
end

function Player:takeHit(damage)
    self.health = math.max(self.health - damage, 0)
    if self.health == 0 then
        self:die()
    end
end

function Player:die()
    self.visible = false
    self.active = false
    self.world:doSequence({
        {1, function() self.world:onDeath() end}
    })
end

function Player:update(dt)
    self:movement(dt)
    self:animation()
    if input.pressed("shoot") and not self.shotCooldown.active then
        local bulletHeading = Vector:new(1, 0)
        if self.graphic.flipX then
            bulletHeading.x = -1
        end
        local bullet = PlayerBullet:new(
            self.x,
            self.y - 11 + 17,
            bulletHeading
        )
        self.world:add(bullet)
        self.shotCooldown:start()
    end
    if #self:collide(self.x, self.y, {"acid"}) > 0 then
        self:takeHit(Acid.DAMAGE_RATE * dt)
    end
    Entity.update(self, dt)

    --if self.velocity.x ~= 0 or self.velocity.y ~= 0 then
        --self.sfx["run"]:loop()
    --else
        --self.sfx["run"]:stop()
    --end
end
