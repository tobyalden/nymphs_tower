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
Player.static.HIT_DAMAGE = 20
--Player.static.HIT_DAMAGE = 200
Player.static.KNOCKBACK_POWER_X = 200
Player.static.KNOCKBACK_POWER_Y = 200
Player.static.KNOCKBACK_TIME = 0.25
Player.static.FUEL_RECOVERY_DELAY = 0.5
Player.static.DEBUG_SPEED = 500

Player.static.SOLIDS = {"walls", "block", "lock"}

local releasedJump

function Player:initialize(x, y)
    Entity.initialize(self, x, y)

    releasedJump = false

    self.canMove = false

    self.mask = Hitbox:new(self, 8, 21)
    self.types = {"player"}
    self.velocity = Vector:new(0, 0)
    self.accel = Vector:new(0, 0)
    self.isDead = false

    self.graphic = Sprite:new("player.png", 16, 32)
    self.graphic:add("idle", {1})
    self.graphic:add("run", {2, 3, 4}, 6)
    self.graphic:add("jump", {4})
    self.graphic:add("jetpack", {5})
    self.graphic:add("idle_gun", {6}, 4)
    self.graphic:add("jetpack", {5})
    self.graphic:add("run_gun", {7, 8, 9}, 6)
    self.graphic:add("jump_gun", {9})
    self.graphic:add("harmonica", {10})
    self.graphic:add("jetpack_gun", {11})
    self.graphic.offsetX = -5
    self.graphic.offsetY = -11
    self.graphic.flipX = true
    self.layer = -1
    self.harmonicaTimer = 0

    self:loadSfx({
        "jump.wav", "run.wav", "land.wav", "jetpack.wav", "jetpackoff.wav",
        "bumphead.wav", "jetpackon.wav", "save.wav", "shoot1.wav",
        "shoot2.wav", "shoot3.wav", "playerhit.wav", "acid.wav",
        "acidland.wav", "acidout.wav", "playerdeath.wav", "playerpredeath.wav",
        "fueljingle.wav", "healthjingle.wav", "itemjingle.wav",
        "harmonica.wav", "harmonica_stop.wav", "harmonica_angel.wav",
        "equip.wav", "unequip.wav", "highjump.wav", "mapopen.wav", "mapclose.wav"
    })

    self.shotCooldown = self:addTween(Alarm:new(Player.SHOT_COOLDOWN))
    --self.isBufferingShot = false
    self.hasGun = false
    self.hasGravityBelt = false
    self.hasHazardSuit = false
    self.hasHarmonica = false
    self.isGravityBeltEquipped = false
    self.isPlayingHarmonica = false
    self.hasMap = false
    self.hasCompass = true
    self.hasCrown = false
    self.isLookingAtMap = false

    --self.healthUpgrades = 6 --MAX
    --self.fuelUpgrades = 4 -- MAX
    self.healthUpgrades = 6
    self.fuelUpgrades = 4

    self.hitDamage = Player.HIT_DAMAGE

    self:restoreHealth()
    self.fuel = 0
    self.invincibleTimer = self:addTween(Alarm:new(
        Player.INVINCIBLE_AFTER_HIT_TIME
    ))
    self.knockbackTimer = self:addTween(Alarm:new(Player.KNOCKBACK_TIME))
    self.fuelRecoveryTimer = self:addTween(Alarm:new(Player.FUEL_RECOVERY_DELAY))
    self.wasOnGround = true
    self.wasJetpackOn = false
    self.wasInAcid = false
    self.harmonicaDelay = self:addTween(Alarm:new(2.5))

    self.runParticleTimer = self:addTween(Alarm:new(0.3, function()
        self:explode(3, 30, 0.5, 14, 0, 11, 1)
    end))
    self.jetpackParticleTimer = self:addTween(Alarm:new(0.1, function()
        if self.graphic.flipX then
            self:explode(3, 50, 1, 4, 5, 2, 1)
        else
            self:explode(3, 50, 1, 4, -5, 2, 1)
        end
    end))
end

function Player:loseItems()
    self.hasGun = false
    self.hasGravityBelt = false
    self.isGravityBeltEquipped = false
    self.hasHazardSuit = false
    self.hasMap = false
    self.fuelUpgrades = 0
end

function Player:giveAllItems()
    self.hasGun = true
    self.hasGravityBelt = true
    self.hasHazardSuit = true
    self.hasMap = true
    self.hasCompass = true
    self.healthUpgrades = 10
    self.fuelUpgrades = 4
end

function Player:isInside()
    local collidedInsides = self:collide(self.x, self.y, {"inside"})
    if #collidedInsides > 0 and collidedInsides[1].musicName ~= "top" then
        return true
    end
    return false
end

function Player:isAtTop()
    local collidedInsides = self:collide(self.x, self.y, {"inside"})
    if #collidedInsides > 0 and collidedInsides[1].musicName == "top" then
        return true
    end
    return false
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
            self.sfx["bumphead"]:play()
            self:explode(4, 40, 0.5, 12, 0, -13, 1)
        end
    end
end

function Player:debugMovement(dt)
    local heading = Vector:new()
    if input.down("debug_up") then
        heading.y = -1
    elseif input.down("debug_down") then
        heading.y = 1
    end
    if input.down("debug_left") then
        heading.x = -1
    elseif input.down("debug_right") then
        heading.x = 1
    end
    self:moveBy(
        heading.x * Player.DEBUG_SPEED * dt,
        heading.y * Player.DEBUG_SPEED * dt
    )
end

function Player:movement(dt)
    local collidedCheckpoints = self:collide(self.x, self.y, {"checkpoint"})
    if self.velocity:len() == 0 and self.hasHarmonica and input.down("down") and not self.isLookingAtMap and #collidedCheckpoints == 0 then
        self.isPlayingHarmonica = true
    else
        self.isPlayingHarmonica = false
    end

    if self.velocity.y == 0 and (self.hasMap or self.hasCompass) and input.pressed("map") then
        self.velocity.x = 0
        self.isLookingAtMap = not self.isLookingAtMap
        if self.isLookingAtMap then
            self.sfx["mapopen"]:play()
        else
            self.sfx["mapclose"]:play()
        end
    end

    if self.isPlayingHarmonica or self.isLookingAtMap then
        if not self.fuelRecoveryTimer.active then
            self.fuel = math.min(
                self.fuel + Player.JETPACK_FUEL_RECOVER_RATE * dt,
                self:getMaxFuel()
            )
        end
        return
    end

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
    -- TODO: Speedrun tech where jetpack affects your x velocity slightly?
    --if self.velocity.x > speed then
        --self.velocity.x = math.approach(self.velocity.x, speed, dt * Player.RUN_ACCEL)
    --elseif self.velocity.x < -speed then
        --self.velocity.x = math.approach(self.velocity.x, -speed, dt * Player.RUN_ACCEL)
    --end
    self.velocity.x = math.clamp(self.velocity.x, -speed, speed)
    if self:isOnGround() then
        self.velocity.y = 0
        isJetpackOn = false
        if input.pressed("jump") then
            if self.isGravityBeltEquipped then
                self.velocity.y = -Player.JUMP_POWER * 1.25
                self.sfx["highjump"]:play()
            else
                self.velocity.y = -Player.JUMP_POWER
                self.sfx["jump"]:play()
            end
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
    if self.isGravityBeltEquipped then
      self.velocity.y = math.clamp(
          self.velocity.y, -Player.MAX_RISE_SPEED * 1.25, Player.MAX_FALL_SPEED * 1.25
      )
    else
        self.velocity.y = math.clamp(
            self.velocity.y, -Player.MAX_RISE_SPEED, Player.MAX_FALL_SPEED
        )
    end
    local velocityXTech = self.velocity.x
    if isJetpackOn and not self:isOnGround() then
        velocityXTech = velocityXTech * 1.1
    end
    self:moveBy(
        velocityXTech * dt,
        self.velocity.y * dt,
        Player.SOLIDS
    )
end

function Player:animation()
    if self:isOnGround() and self.velocity.x ~= 0 then
        self.runParticleTimer.active = true
    else
        self.runParticleTimer.active = false
    end
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
    if input.down("left") then
        self.graphic.flipX = true
    elseif input.down("right") then
        self.graphic.flipX = false
    end
    if self.graphic.flipX then
        self.graphic.offsetX = -3
    else
        self.graphic.offsetX = -5
    end

    local animationSuffix
    if self.hasGun then
        animationSuffix = "_gun";
    else
        animationSuffix = "";
    end
    if self.isPlayingHarmonica then
        self.graphic:play("harmonica")
    elseif self:isOnGround() then
        if self.velocity.x ~= 0 then
            self.graphic:play("run"  ..  animationSuffix)
        else
            self.graphic:play("idle"  ..  animationSuffix)
        end
    else
        if isJetpackOn then
            self.graphic:play("jetpack"  ..  animationSuffix)
        else
            self.graphic:play("jump"  ..  animationSuffix)
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
    self.isDead = true
    self:explode(30, 250, 2, 2, 0, 0, -99, true)
    self:explode(20, 180, 1.5, 2, 0, 0, -99, true)
    self:explode(10, 150, 1, 2, 0, 0, -99, true)
    self.world:pauseLevel()
    self.world:doSequence({
        {0.5, function()
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
    --if self.hasGun and (input.down("shoot") or self.isBufferingShot) then
    if self.hasGun and input.down("shoot") then
        if self.shotCooldown.active then
            --if self.shotCooldown:getPercentComplete() > 0.75 then
                --self.isBufferingShot = true
            --end
        else
            local bulletHeading = Vector:new(1, 0)
            if self.graphic.flipX then
                bulletHeading.x = -1
            end
            local bullet = PlayerBullet:new(
                self.x,
                self.y + 8,
                bulletHeading
            )
            if self:isOnGround() then
                if self.velocity:len() ~= 0 then
                    bullet.y = bullet.y - 2
                else
                    bullet.y = bullet.y - 1
                end
            else
                if isJetpackOn then
                    bullet.y = bullet.y - 4
                else
                    bullet.y = bullet.y - 2
                end
            end
            self.world:add(bullet)
            local choices = {1, 2, 3}
            --self.sfx['shoot' .. math.random(#choices)]:play()
            self.sfx['shoot1']:play()
            self.shotCooldown:start()
            --self.isBufferingShot = false
        end
    end
end

function Player:isInAcid()
    return #self:collide(self.x, self.y, {"acid"}) > 0
end

function Player:collisions(dt)
    local collidedDecorations = self:collide(self.x, self.y, {"decoration"})
    if #collidedDecorations > 0 then
        self.layer = -10
    else
        self.layer = -1
    end

    local collidedBoats = self:collide(self.x, self.y + 1, {"boat"})
    if #collidedBoats > 0 then
        self.graphic.offsetY = -11 + collidedBoats[1].graphic.offsetY
    else
        self.graphic.offsetY = -11
    end

    if self:isInAcid() and not self.hasHazardSuit then
        local acidDamage = Acid.DAMAGE_RATE * dt
        if self.world.isHardMode then
            acidDamage = acidDamage * 2
        end
        self:decreaseHealth(acidDamage)
    end

    local itemChimeTime = 3

    local collidedGuns = self:collide(self.x, self.y, {"gun"})
    if #collidedGuns > 0 then
        self.sfx["itemjingle"]:play()
        self.world:pauseLevel()
        self.world:doSequence({
            {itemChimeTime, function()
                self.world:unpauseLevel()
                self.world:remove(collidedGuns[1])
                table.insert(self.world.itemIds, collidedGuns[1].uniqueId)
                self.hasGun = true
                local totalTime = self.world.ui:showMessageSequence({
                    "YOU FOUND THE RAYGUN"
                })
            end}
        })
    end

    local collidedGravityBelts = self:collide(self.x, self.y, {"gravity_belt"})
    if #collidedGravityBelts > 0 then
        self.sfx["itemjingle"]:play()
        self.world:pauseLevel()
        self.world:doSequence({
            {itemChimeTime, function()
                self.world:unpauseLevel()
                self.world:remove(collidedGravityBelts[1])
                table.insert(self.world.itemIds, collidedGravityBelts[1].uniqueId)
                self.hasGravityBelt = true
                local totalTime = self.world.ui:showMessageSequence({
                    "YOU FOUND THE GRAVITY BELT"
                })
            end}
        })
    end

    local collidedHazardSuits = self:collide(self.x, self.y, {"hazard_suit"})
    if #collidedHazardSuits > 0 then
        self.sfx["itemjingle"]:play()
        self.world:pauseLevel()
        self.world:doSequence({
            {itemChimeTime, function()
                self.world:unpauseLevel()
                self.world:remove(collidedHazardSuits[1])
                table.insert(self.world.itemIds, collidedHazardSuits[1].uniqueId)
                self.hasHazardSuit = true
                local totalTime = self.world.ui:showMessageSequence({
                    "YOU FOUND THE HAZARD SUIT"
                })
            end}
        })
    end

    local collidedHarmonicas = self:collide(self.x, self.y, {"harmonica"})
    if #collidedHarmonicas > 0 then
        self.sfx["itemjingle"]:play()
        self.world:pauseLevel()
        self.world:doSequence({
            {itemChimeTime, function()
                self.world:unpauseLevel()
                self.world:remove(collidedHarmonicas[1])
                table.insert(self.world.itemIds, collidedHarmonicas[1].uniqueId)
                self.hasHarmonica = true
                local totalTime = self.world.ui:showMessageSequence({
                    "YOU FOUND THE HARMONICA",
                    "HOLD DOWN TO USE",
                })
            end}
        })
    end

    local collidedMaps = self:collide(self.x, self.y, {"map"})
    if #collidedMaps > 0 then
        self.sfx["itemjingle"]:play()
        self.world:pauseLevel()
        self.world:doSequence({
            {itemChimeTime, function()
                self.world:unpauseLevel()
                self.world:remove(collidedMaps[1])
                table.insert(self.world.itemIds, collidedMaps[1].uniqueId)
                self.hasMap = true
                local totalTime = self.world.ui:showMessageSequence({
                    "YOU FOUND THE MAP"
                })
            end}
        })
    end

    local collidedCompasses = self:collide(self.x, self.y, {"compass"})
    if #collidedCompasses > 0 then
        self.sfx["itemjingle"]:play()
        self.world:pauseLevel()
        self.world:doSequence({
            {itemChimeTime, function()
                self.world:unpauseLevel()
                self.world:remove(collidedCompasses[1])
                table.insert(self.world.itemIds, collidedCompasses[1].uniqueId)
                self.hasCompass = true
                local totalTime = self.world.ui:showMessageSequence({
                    "YOU FOUND THE COMPASS"
                })
            end}
        })
    end

    local collidedCrowns = self:collide(self.x, self.y, {"crown"})
    if #collidedCrowns > 0 then
        self.sfx["itemjingle"]:play()
        self.world:pauseLevel()
        self.world:doSequence({
            {itemChimeTime, function()
                self.world:unpauseLevel()
                self.world:remove(collidedCrowns[1])
                table.insert(self.world.itemIds, collidedCrowns[1].uniqueId)
                self.hasCrown = true
                local totalTime = self.world.ui:showMessageSequence({
                    "YOU FOUND THE CROWN",
                    "RETURN TO THE BOAT",
                })
            end}
        })
    end

    local collidedHealthUpgrades = self:collide(self.x, self.y, {"health_upgrade"})
    if #collidedHealthUpgrades > 0 then
        self.sfx["healthjingle"]:play()
        self.world:pauseLevel()
        self.world:doSequence({
            {itemChimeTime, function()
                local totalTime = self.world.ui:showMessageSequence({
                    "YOU FOUND A HEALTH PACK"
                })
                self.world:unpauseLevel()
                self.world:remove(collidedHealthUpgrades[1])
                table.insert(self.world.itemIds, collidedHealthUpgrades[1].uniqueId)
                self.healthUpgrades = self.healthUpgrades + 1
                self:restoreHealth()
            end}
        })
    end

    local collidedFuelUpgrades = self:collide(self.x, self.y, {"fuel_upgrade"})
    if #collidedFuelUpgrades > 0 then
        self.sfx["fueljingle"]:play()
        self.world:pauseLevel()
        self.world:doSequence({
            {itemChimeTime, function()
                local totalTime = self.world.ui:showMessageSequence({
                    "YOU FOUND A FUEL TANK"
                })
                self.world:unpauseLevel()
                self.world:addFlag(collidedFuelUpgrades[1].addFlag)
                self.world:remove(collidedFuelUpgrades[1])
                table.insert(self.world.itemIds, collidedFuelUpgrades[1].uniqueId)
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

    local collidedAcidTriggers = self:collide(self.x, self.y, {"acid_trigger"})
    if #collidedAcidTriggers > 0 then
        for _, collidedAcidTrigger in pairs(collidedAcidTriggers) do
            collidedAcidTrigger:trigger()
            table.insert(self.world.itemIds, collidedAcidTrigger.uniqueId)
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

    if input.pressed("down") and not self.isLookingAtMap then
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
    if self.fuelUpgrades == 0 then
        return 0
    elseif self.fuelUpgrades == 1 then
        return Player.STARTING_FUEL
    else
        return (
            Player.STARTING_FUEL
            + (self.fuelUpgrades - 1) * FuelUpgrade.FUEL_AMOUNT
        )
    end
end


function Player:handleSfx(dt)
    if self.isDead then
        self.sfx["run"]:stop()
        self.sfx["acid"]:stop()
        self.sfx["jetpack"]:stop()
        self.sfx["harmonica"]:stop()
        self.sfx["harmonica_angel"]:stop()
    else
        if not self.wasOnGround and self:isOnGround() then
            self.sfx["land"]:play()
            self:explode(4, 40, 1, 12, 0, 10, 1)
        end
        if self:isOnGround() and self.velocity.x ~= 0 then
            self.sfx["jetpack"]:loop()
        else
            self.sfx["run"]:stop()
        end

        local harmonicaSfxName = "harmonica"
        -- TODO: Remove hardcoded value here
        if self.y == 1499 then
            harmonicaSfxName = "harmonica_angel"
        end
        if self.isPlayingHarmonica then
            if not self.sfx[harmonicaSfxName]:isPlaying() then
                self.harmonicaDelay:start()
                self.sfx[harmonicaSfxName]:loop()
            end
            self.harmonicaTimer = self.harmonicaTimer + dt
            if (
                self.harmonicaTimer > 5
                and harmonicaSfxName == "harmonica_angel"
            ) then
                self.world:teleportToSecondTower()
            end
        else
            self.harmonicaTimer = 0
            if (
                self.sfx[harmonicaSfxName]:isPlaying()
                and not self.harmonicaDelay.active
            ) then
                self.sfx["harmonica_stop"]:play()
            end
            self.sfx[harmonicaSfxName]:stop()
        end
        if isJetpackOn then
            self.sfx["jetpack"]:loop()
            self.jetpackParticleTimer.active = true
            if not self.wasJetpackOn then
                self.sfx["jetpackon"]:play()
            end
        else
            self.sfx["jetpack"]:stop()
            self.jetpackParticleTimer.active = false
            if self.wasJetpackOn then
                self.sfx["jetpackoff"]:play()
            end
        end
        if self:isInAcid() then
            if not self.hasHazardSuit then
                self.sfx["acid"]:loop()
            end
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
end

function Player:update(dt)
    if not self.canMove then
        self:moveBy(
            0,
            Player.MAX_FALL_SPEED * dt,
            Player.SOLIDS
        )
        self:animation()
        return
    end
    if self.world.isHardMode then
        self.hitDamage = Player.HIT_DAMAGE * 2
    end
    self:shooting()

    if (
        input.pressed("up")
        and self.hasGravityBelt
        and not (self.isLookingAtMap
        or self.isPlayingHarmonica)
    ) then
        self.isGravityBeltEquipped = not self.isGravityBeltEquipped
        if self.isGravityBeltEquipped then
            self.sfx["equip"]:play()
        else
            self.sfx["unequip"]:play()
        end
    end

    if GameWorld.DEBUG_MODE and input.down("shift") then
        self:debugMovement(dt)
    else
        self:movement(dt)
        self:collisions(dt)
    end
    self:animation()

    Entity.update(self, dt)

    self:handleSfx(dt)
    self.wasOnGround = self:isOnGround()
    self.wasJetpackOn = isJetpackOn
    self.wasInAcid = self:isInAcid()

    --if self.velocity.x ~= 0 or self.velocity.y ~= 0 then
        --self.sfx["run"]:loop()
    --else
        --self.sfx["run"]:stop()
    --end
end
