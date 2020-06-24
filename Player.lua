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
Player.static.SHOT_COOLDOWN = 0.5
Player.static.GUN_POWER = 1
Player.static.INVINCIBLE_AFTER_HIT_TIME = 1
Player.static.HIT_DAMAGE = 20
Player.static.KNOCKBACK_POWER_X = 200
Player.static.KNOCKBACK_POWER_Y = 200
Player.static.KNOCKBACK_TIME = 0.25
Player.static.FUEL_RECOVERY_DELAY = 0.5

Player.static.SOLIDS = {"walls", "block", "lock"}

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
    self.graphic:add("run", {2, 3, 4, 3}, 6)
    self.graphic:add("jump", {5})
    self.graphic:add("crouch", {5})
    self.graphic:add("jetpack", {6, 7}, 4)
    self.graphic.offsetX = -5;
    self.graphic.offsetY = -11;
    self.layer = -1

    self:loadSfx({"jump.wav", "run.wav"})

    self.health = Player.STARTING_HEALTH
    self.fuel = Player.STARTING_FUEL
    self.shotCooldown = self:addTween(Alarm:new(Player.SHOT_COOLDOWN))
    self.isBufferingShot = false
    self.hasGun = true
    self.healthUpgrades = 0
    self.fuelUpgrades = 0
    self.invincibleTimer = self:addTween(Alarm:new(
        Player.INVINCIBLE_AFTER_HIT_TIME
    ))
    self.knockbackTimer = self:addTween(Alarm:new(Player.KNOCKBACK_TIME))
    self.fuelRecoveryTimer = self:addTween(Alarm:new(Player.FUEL_RECOVERY_DELAY))
end

function Player:isOnGround()
    if #self:collide(self.x, self.y + 0.01, Player.SOLIDS) > 0 then
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
    if self.knockbackTimer.active then
        self.velocity.y = self.velocity.y + Player.GRAVITY * dt
        self:moveBy(
            self.velocity.x * dt,
            self.velocity.y * dt,
            Player.SOLIDS
        )
        return
    end
    if input.down("left") then self.velocity.x = -Player.SPEED
    elseif input.down("right") then self.velocity.x = Player.SPEED
    else self.velocity.x = 0 end
    if self:isOnGround() then
        self.velocity.y = 0
        isJetpackOn = false
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
            self.fuelRecoveryTimer:start()
            self.velocity.y = self.velocity.y - Player.JETPACK_POWER * dt
            self.fuel = math.max(self.fuel - Player.JETPACK_FUEL_USE_RATE * dt, 0)
        end
        self.velocity.y = self.velocity.y + Player.GRAVITY * dt
    end
    if not self.fuelRecoveryTimer.active then
        self.fuel = math.min(
            self.fuel + Player.JETPACK_FUEL_RECOVER_RATE * dt,
            self:getMaxFuel()
        )
    end
    self.velocity.y = math.clamp(
        self.velocity.y, -Player.MAX_RISE_SPEED, Player.MAX_FALL_SPEED
    )
    self:moveBy(
        self.velocity.x * dt,
        self.velocity.y * dt,
        Player.SOLIDS
    )
end

function Player:animation()
    if self.invincibleTimer.active then
        local invincibleAlpha = 0.25
        if self.graphic.alpha == invincibleAlpha then
            self.graphic.alpha = 1
        else
            self.graphic.alpha = invincibleAlpha
        end
    else
        self.graphic.alpha = 1
    end
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

function Player:decreaseHealth(damage)
    self.health = math.max(self.health - damage, 0)
    if self.health == 0 then
        self:die()
    end
end

function Player:takeHit(damage)
    self:decreaseHealth(damage)
    self.invincibleTimer:start()
end

function Player:die()
    self.visible = false
    self.active = false
    self.world:doSequence({
        {1, function() self.world:onDeath() end}
    })
end

function Player:shooting()
    if self.hasGun and (input.pressed("shoot") or self.isBufferingShot) then
        if self.shotCooldown.active then
            if self.shotCooldown:getPercentComplete() > 0.75 then
                self.isBufferingShot = true
            end
        else
            local bulletHeading = Vector:new(1, 0)
            if self.graphic.flipX then
                bulletHeading.x = -1
            end
            local bullet = PlayerBullet:new(
                self.x,
                self.y - 11 + 15,
                bulletHeading
            )
            self.world:add(bullet)
            self.shotCooldown:start()
            self.isBufferingShot = false
        end
    end
end

function Player:collisions(dt)
    if #self:collide(self.x, self.y, {"acid"}) > 0 then
        self:decreaseHealth(Acid.DAMAGE_RATE * dt)
    end

    local itemChimeTime = 2

    local collidedGuns = self:collide(self.x, self.y, {"gun"})
    if #collidedGuns > 0 then
        self.world:pauseLevel()
        self.world:doSequence({
            {itemChimeTime, function()
                self.world:unpauseLevel()
                self.world:remove(collidedGuns[1])
                self.hasGun = true
                local totalTime = self.world.ui:showMessageSequence({
                    "YOU FOUND THE RAYGUN",
                    "PRESS X TO SHOOT",
                })
                --self.world:doSequence({
                    --{totalTime + 1, function()
                    --end}
                --})
            end}
        })
    end

    local collidedHealthUpgrades = self:collide(self.x, self.y, {"health_upgrade"})
    if #collidedHealthUpgrades > 0 then
        self.world:pauseLevel()
        self.world:doSequence({
            {itemChimeTime, function()
                local totalTime = self.world.ui:showMessageSequence({
                    "YOU FOUND A HEALTH PACK"
                })
                self.world:unpauseLevel()
                self.world:remove(collidedHealthUpgrades[1])
                self.healthUpgrades = self.healthUpgrades + 1
                self:restoreHealth()
            end}
        })
    end

    local collidedFuelUpgrades = self:collide(self.x, self.y, {"fuel_upgrade"})
    if #collidedFuelUpgrades > 0 then
        self.world:pauseLevel()
        self.world:doSequence({
            {itemChimeTime, function()
                local totalTime = self.world.ui:showMessageSequence({
                    "YOU FOUND A FUEL TANK"
                })
                self.world:unpauseLevel()
                self.world:remove(collidedFuelUpgrades[1])
                self.fuelUpgrades = self.fuelUpgrades + 1
                self:restoreFuel()
            end}
        })
    end

    local collidedFlagTriggers = self:collide(self.x, self.y, {"flag_trigger"})
    if #collidedFlagTriggers > 0 then
        for _, collidedFlagTrigger in pairs(collidedFlagTriggers) do
            collidedFlagTrigger:trigger()
        end
    end

    local collidedEnemies = self:collide(self.x, self.y, {"enemy"})
    if #collidedEnemies > 0 and not self.invincibleTimer.active then
        self:takeHit(Player.HIT_DAMAGE)
        self:knockback(collidedEnemies[1])
    end

    if input.pressed("down") then
        local collidedCheckpoints = self:collide(self.x, self.y, {"checkpoint"})
        if #collidedCheckpoints > 0 then
            collidedCheckpoints[1]:flash()
            self.world:saveGame(
                collidedCheckpoints[1].x, collidedCheckpoints[1].y,
                self.graphic.flipX
            )
            self.world.ui:showMessageSequence({ "GAME SAVED" }, 1)
        end
    end
end

function Player:knockback(source)
    local knockbackVelocity = Vector:new(
        self:getMaskCenter().x - source:getMaskCenter().x,
        self:getMaskCenter().y - source:getMaskCenter().y
    )
    --local knockbackVelocity = Vector:new(
        --Player.KNOCKBACK_POWER_X, -Player.KNOCKBACK_POWER_Y
    --)
    --if self:getMaskCenter().x < source:getMaskCenter().x then
        --knockbackVelocity.x = -Player.KNOCKBACK_POWER_X
    --end
    knockbackVelocity:normalize()
    if math.abs(knockbackVelocity.x) < 0.5 then
        knockbackVelocity.x = (
            0.5 * math.abs(knockbackVelocity.x) / knockbackVelocity.x
        )
    end
    knockbackVelocity.x = knockbackVelocity.x * Player.KNOCKBACK_POWER_X
    knockbackVelocity.y = -Player.KNOCKBACK_POWER_Y
    --self.velocity:add(knockbackVelocity)
    self.velocity = knockbackVelocity
    self.knockbackTimer:start()
end

function Player:restoreHealth()
    self.health = (
        Player.STARTING_HEALTH
        + self.healthUpgrades * HealthUpgrade.HEALTH_AMOUNT
    )
end

function Player:restoreFuel()
    self.fuel = self:getMaxFuel()
end

function Player:getMaxFuel()
    return (
        Player.STARTING_FUEL
        + self.fuelUpgrades * FuelUpgrade.FUEL_AMOUNT
    )
end

function Player:update(dt)
    self:movement(dt)
    self:animation()
    self:shooting()
    self:collisions(dt)
    Entity.update(self, dt)

    --if self.velocity.x ~= 0 or self.velocity.y ~= 0 then
        --self.sfx["run"]:loop()
    --else
        --self.sfx["run"]:stop()
    --end
end
