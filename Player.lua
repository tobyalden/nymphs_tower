Player = class("Player", Entity)
Player.static.SPEED = 150
Player.static.RUN_ACCEL = 150 * 4 * 4 * 2
Player.static.AIR_ACCEL = 150 * 4 * 4
Player.static.GRAVITY = 600
Player.static.MAX_FALL_SPEED = 300
Player.static.MAX_RISE_SPEED = 150
Player.static.JUMP_POWER = 150
Player.static.JETPACK_POWER = 900 * 1
Player.static.STARTING_HEALTH = 100
Player.static.STARTING_FUEL = 100
Player.static.JETPACK_FUEL_USE_RATE = 50
Player.static.JETPACK_FUEL_RECOVER_RATE = 100
--Player.static.SHOT_COOLDOWN = 0.5
Player.static.SHOT_COOLDOWN = 0.4
Player.static.GUN_POWER = 1
Player.static.INVINCIBLE_AFTER_HIT_TIME = 1
--Player.static.HIT_DAMAGE = 20
Player.static.HIT_DAMAGE = 200
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

    self.mask = Hitbox:new(self, 8, 21)
    self.types = {"player"}
    self.velocity = Vector:new(0, 0)
    self.accel = Vector:new(0, 0)

    self.graphic = Sprite:new("player.png", 16, 32)
    self.graphic:add("idle", {1})
    self.graphic:add("run", {2, 3, 4, 3}, 6)
    self.graphic:add("jump", {5})
    self.graphic:add("crouch", {5})
    self.graphic:add("jetpack", {6, 7}, 4)
    self.graphic.offsetX = -5
    self.graphic.offsetY = -11
    self.graphic.flipX = true
    self.layer = -1

    self:loadSfx({
        "jump.wav", "run.wav", "land.wav", "jetpack.wav", "jetpackoff.wav",
        "bumphead.wav", "jetpackon.wav", "save.wav", "shoot.wav",
        "playerhit.wav", "acid.wav", "acidland.wav", "acidout.wav",
        "playerdeath.wav", "playerpredeath.wav"
    })

    self.fuel = Player.STARTING_FUEL
    self.shotCooldown = self:addTween(Alarm:new(Player.SHOT_COOLDOWN))
    self.isBufferingShot = false
    self.hasGun = true
    self.hasGravityBelt = true
    self.isGravityBeltEquipped = false
    self.healthUpgrades = 0
    --self.healthUpgrades = 8
    self:restoreHealth()
    --self.fuelUpgrades = 0
    self.fuelUpgrades = 4
    self.invincibleTimer = self:addTween(Alarm:new(
        Player.INVINCIBLE_AFTER_HIT_TIME
    ))
    self.knockbackTimer = self:addTween(Alarm:new(Player.KNOCKBACK_TIME))
    self.fuelRecoveryTimer = self:addTween(Alarm:new(Player.FUEL_RECOVERY_DELAY))
    --self.sfx["longmusic"]:loop()
    self.wasOnGround = false
    self.wasJetpackOn = false
    self.wasInAcid = false

    self.runParticleTimer = self:addTween(Alarm:new(0.3, function()
        self:explode(3, 30, 0.5, 14, 0, 11, 1)
    end))
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
    local isSolid = false
    for _, solidType in pairs(Player.SOLIDS) do
        for _, collidedType in pairs(collided[1].types) do
            if solidType == collidedType then
                isSolid = true
                break
            end
        end
        if isSolid then
            break
        end
    end
    if isSolid then
        if self.velocity.y < 0 then
            if self.isGravityBeltEquipped then
                self.velocity.y = -self.velocity.y / 1.05
            else
                self.velocity.y = -self.velocity.y / 1.25
            end
        end
        self.sfx["bumphead"]:play()
    end
end

function Player:movement(dt)
    local gravity = Player.GRAVITY
    if self.isGravityBeltEquipped then
        gravity = Player.GRAVITY / 1.5
    end
    if self.knockbackTimer.active then
        self.velocity.y = self.velocity.y + gravity * dt
        self:moveBy(
            self.velocity.x * dt,
            self.velocity.y * dt,
            Player.SOLIDS
        )
        return
    end
    local speed = Player.SPEED
    if self.isGravityBeltEquipped then
        speed = Player.SPEED * 1.25
    end
    local accel = Player.AIR_ACCEL
    if self:isOnGround() then
        accel = Player.RUN_ACCEL
    end
    if self.isGravityBeltEquipped then
        accel = Player.RUN_ACCEL * 1.25
    end
    if input.down("left") then self.accel.x = -accel
    elseif input.down("right") then self.accel.x = accel
    else self.accel.x = 0 end
    if input.down("left") or input.down("right") then
        self.velocity.x = self.velocity.x + self.accel.x * dt
    else
        self.velocity.x = math.approach(self.velocity.x, 0, accel * dt)
    end
    self.velocity.x = math.clamp(self.velocity.x, -speed, speed)
    if self:isOnGround() then
        self.velocity.y = 0
        isJetpackOn = false
        if input.pressed("jump") then
            if self.isGravityBeltEquipped then
                self.velocity.y = -Player.JUMP_POWER * 1.25
            else
                self.velocity.y = -Player.JUMP_POWER
            end
            self.sfx["jump"]:play()
            self:explode(4, 40, 1, 12, 0, 10, 1)
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
        self.velocity.y = self.velocity.y + gravity * dt
    end
    if not self.fuelRecoveryTimer.active then
        self.fuel = math.min(
            self.fuel + Player.JETPACK_FUEL_RECOVER_RATE * dt,
            self:getMaxFuel()
        )
    end
    if  self.isGravityBeltEquipped then
      self.velocity.y = math.clamp(
          self.velocity.y, -Player.MAX_RISE_SPEED * 1.25, Player.MAX_FALL_SPEED * 1.25
      )
    else
        self.velocity.y = math.clamp(
            self.velocity.y, -Player.MAX_RISE_SPEED, Player.MAX_FALL_SPEED
        )
    end
    if self:isOnGround() and self.velocity.x ~= 0 then
        self.sfx["run"]:loop()
        self.runParticleTimer.active = true
    else
        self.sfx["run"]:stop()
        self.runParticleTimer.active = false
    end
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
    if self.health > 0 then
        self.sfx["playerhit"]:play()
        self.invincibleTimer:start()
    else
        self.sfx["playerpredeath"]:play()
    end
end

function Player:die()
    -- Version with hitstop
    self:explode(30, 250, 2, 2, 0, 0, -99, true)
    self:explode(20, 180, 1.5, 2, 0, 0, -99, true)
    self:explode(10, 150, 1, 2, 0, 0, -99, true)
    self.world:pauseLevel()
    self.world:doSequence({
        {0.1, function()
            self.world:unpauseLevel()
            self.sfx["playerdeath"]:play()
            self.visible = false
            self.active = false
        end},
        {1, function() self.world:onDeath() end}
    })

    -- Version without hitstop
    --self:explode(30, 250, 2, 2, 0, 0, -99, false)
    --self:explode(20, 180, 1.5, 2, 0, 0, -99, false)
    --self:explode(10, 150, 1, 2, 0, 0, -99, false)
    --self.sfx["playerdeath"]:play()
    --self.visible = false
    --self.active = false
    --self.world:doSequence({
        --{1, function() self.world:onDeath() end}
    --})

    self.sfx["jetpack"]:stop()
    self.sfx["acid"]:stop()
    self.sfx["run"]:stop()
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
            self.sfx["shoot"]:play()
            self.shotCooldown:start()
            self.isBufferingShot = false
        end
    end
end

function Player:isInAcid()
    return #self:collide(self.x, self.y, {"acid"}) > 0
end

function Player:collisions(dt)
    if self:isInAcid() then
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
            end}
        })
    end

    local collidedGravityBelts = self:collide(self.x, self.y, {"gravity_belt"})
    if #collidedGravityBelts > 0 then
        self.world:pauseLevel()
        self.world:doSequence({
            {itemChimeTime, function()
                self.world:unpauseLevel()
                self.world:remove(collidedGravityBelts[1])
                self.hasGravityBelt = true
                local totalTime = self.world.ui:showMessageSequence({
                    "YOU FOUND THE GRAVITY BELT",
                    "PRESS UP TO TOGGLE ON AND OFF",
                })
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
                self.world:addFlag(collidedFuelUpgrades[1].addFlag)
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
        self:takeHit(self.hitDamage)
        self:knockback(collidedEnemies[1])
    end

    local collidedInstakills = self:collide(self.x, self.y, {"instakill"})
    if #collidedInstakills > 0 then
        self:die()
    end

    local collidedBullets = self:collide(self.x, self.y, {"enemy_bullet"})
    if #collidedBullets > 0 and not self.invincibleTimer.active then
        self:takeHit(self.hitDamage)
        self:knockback(collidedBullets[1], 0.75, false, false)
    end

    local collidedSpikes = self:collide(self.x, self.y, {"spike"})
    if #collidedSpikes > 0 and not self.invincibleTimer.active then
        self:takeHit(self.hitDamage)
        if collidedSpikes[1].facing == "ceiling" then
            self:knockback(collidedSpikes[1], 0.25, true, true)
        elseif collidedSpikes[1].facing == "floor" then
            self:knockback(collidedSpikes[1], 0.75, false, true)
        else
            self:knockback(collidedSpikes[1], 0.75, false, false)
        end
    end

    if input.pressed("down") then
        local collidedCheckpoints = self:collide(self.x, self.y, {"checkpoint"})
        if #collidedCheckpoints > 0 then
            collidedCheckpoints[1]:flash()
            self.world:saveGame(collidedCheckpoints[1].x + 3, collidedCheckpoints[1].y)
            self.sfx["save"]:play()
            self.world.ui:showMessageSequence({ "GAME SAVED" }, 1)
        end
    end
end

function Player:knockback(source, scale, allowDownwardsKnockback, averageX)
    scale = scale or 1
    allowDownwardsKnockback = allowDownwardsKnockback or false
    local knockbackVelocity = Vector:new(
        self:getMaskCenter().x - source:getMaskCenter().x,
        self:getMaskCenter().y - source:getMaskCenter().y
    )
    knockbackVelocity:normalize()
    if math.abs(knockbackVelocity.x) < 0.5 and knockbackVelocity.x ~= 0 then
        knockbackVelocity.x = (
            0.5 * math.abs(knockbackVelocity.x) / knockbackVelocity.x
        )
    end
    knockbackVelocity.x = knockbackVelocity.x * Player.KNOCKBACK_POWER_X
    if allowDownwardsKnockback then
        knockbackVelocity.y = Player.KNOCKBACK_POWER_Y * math.sign(knockbackVelocity.y)
    else
        knockbackVelocity.y = -Player.KNOCKBACK_POWER_Y
    end
    knockbackVelocity:scale(scale)
    if averageX then
        self.velocity.x = (knockbackVelocity.x + self.velocity.x) / 2
    else
        self.velocity.x = knockbackVelocity.x
    end
    self.velocity.y = knockbackVelocity.y
    self.knockbackTimer:start(Player.KNOCKBACK_TIME * scale)
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
    if self.world.isHardMode then
        self.hitDamage = Player.HIT_DAMAGE * 2
    end
    self:shooting()
    self:collisions(dt)
    if input.pressed("up") and self.hasGravityBelt then
        self.isGravityBeltEquipped = not self.isGravityBeltEquipped
    end
    self:movement(dt)
    self:animation()

    Entity.update(self, dt)
    if self.health > 0 then
        if not self.wasOnGround and self:isOnGround() then
            self.sfx["land"]:play()
            self:explode(4, 40, 1, 12, 0, 10, 1)
        end
        if isJetpackOn then
            self.sfx["jetpack"]:loop()
            if not self.wasJetpackOn then
                self.sfx["jetpackon"]:play()
            end
        else
            self.sfx["jetpack"]:stop()
            if self.wasJetpackOn then
                self.sfx["jetpackoff"]:play()
            end
        end
        if self:isInAcid() then
            self.sfx["acid"]:loop()
            if not self.wasInAcid then
                self.sfx["acidland"]:play()
            end
        else
            if self.wasInAcid then
                self.sfx["acidout"]:play()
            end
            self.sfx["acid"]:stop()
        end
    end
    self.wasOnGround = self:isOnGround()
    self.wasJetpackOn = isJetpackOn
    self.wasInAcid = self:isInAcid()

    --if self.velocity.x ~= 0 or self.velocity.y ~= 0 then
        --self.sfx["run"]:loop()
    --else
        --self.sfx["run"]:stop()
    --end
end
