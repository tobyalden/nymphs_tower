SecretBoss = class("SecretBoss", Entity)
SecretBoss:include(Boss)

SecretBoss.static.NODE_TRAVEL_SPEED = 200
SecretBoss.static.BOUNCE_SPEED = 100
SecretBoss.static.CHASE_SPEED = 80
SecretBoss.static.PAUSE_TIME = 0.5
--SecretBoss.static.NODE_TRAVEL_SPEED = 0

function SecretBoss:initialize(x, y, nodes)
    Entity.initialize(self, x, y)
    if GameWorld.static.isSecondTower then
        self.displayName = "KING"
    else
        self.displayName = "NYMPH"
    end
    self.flag = "secret_boss"
    self.types = {"enemy"}
    self.startingHealth = 20
    --self.startingHealth = 1
    self.health = self.startingHealth
    if GameWorld.static.isSecondTower then
        self.graphic = Sprite:new("king.png", 40, 50)
        self.graphic:add("idle_alt", {5, 6, 7, 8}, 6)
        self.graphic:play("idle_alt")
    else
        self.graphic = Sprite:new("queen.png", 40, 50)
        self.graphic:add("idle", {1, 2, 3, 2}, 6)
        self.graphic:play("idle")
    end
    self.mask = Hitbox:new(self, 40, 50)
    self.layer = -5
    self.nodes = {}
    self.highestNodeY = nodes[1].y
    for i, node in pairs(nodes) do
        if node.y < self.highestNodeY then
            self.highestNodeY = node.y
        end
        self.nodes[i] = Vector:new(node.x, node.y)
    end
    self.nodeIndex = 1
    self.reversed = love.math.random() > 0.5
    self.pauseTime = SecretBoss.PAUSE_TIME
    self.pauseTimer = self:addTween(Alarm:new(self.pauseTime))
    self.attackTimer = self:addTween(Alarm:new(self.pauseTime / 2, function()
        self:fireBullet()
    end))
    self.fanTimer = self:addTween(Alarm:new(2, function()
        self:fireFan()
    end, "looping"))
    self.phaseNumber = 1
    -- TODO: Should this pick a random direction?
    self.velocity = Vector:new(-1, 1)
    self:loadSfx({"bosshit.wav", "bossdeath.wav", "bosspredeath.wav", "enemyshotbig.wav", "enemyshotsmall.wav"})
end 

function SecretBoss:update(dt)
    self.graphic.flipX = (
        self.world.player:getMaskCenter().x > self:getMaskCenter().x
    )
    self:bossUpdate(dt)
    Entity.update(self, dt)
end

function SecretBoss:fireBullet()
    if self.y == self.highestNodeY then
        self:fireSpread()
    else
        self:fireDropShot()
    end
end

function SecretBoss:fireFan()
    local offset = math.random() * math.pi * 2
    local numBullets = 8
    if self.world.isHardMode then
        numBullets = 12
    end
    local increment = (math.pi * 2) / numBullets
    for i = 1, numBullets do
        local rotation = increment * (i - 1) + offset
        local bulletHeading = Vector:new(math.cos(rotation), math.sin(rotation))
        local bullet = EnemyBullet:new(
            self,
            self.x + self.mask.width / 2 - 9,
            self.y + self.mask.height / 2 - 9,
            bulletHeading,
            EnemyBullet.BULLET_SPEED * 1.5,
            false, true
        )
        self.world:add(bullet)
    end
    self.sfx["enemyshotsmall"]:play()
end

function SecretBoss:fireDropShot()
    local towardsPlayer = Vector:new(
        self.world.player:getMaskCenter().x - self:getMaskCenter().x,
        self.world.player:getMaskCenter().y - self:getMaskCenter().y
    )
    towardsPlayer:normalize()
    local shotAngle = Vector:new(towardsPlayer.x, -1)
    local shotSeparation = 30
    local bullet = EnemyBullet:new(
        self,
        self.x,
        self.y,
        shotAngle,
        150 + love.math.random() * 20, true
    )
    self.world:add(bullet)
    self.sfx["enemyshotbig"]:play()
end

function SecretBoss:fireSpread()
    local towardsPlayer = Vector:new(
        self.world.player:getMaskCenter().x - self:getMaskCenter().x,
        self.world.player:getMaskCenter().y - self:getMaskCenter().y
    )
    local bullet = EnemyBullet:new(
        self,
        self.x + self.mask.width / 2 - 9,
        self.y + self.mask.height / 2 - 9,
        towardsPlayer,
        EnemyBullet.BULLET_SPEED * 1.5,
        false, true
    )
    self.world:add(bullet)

    local spreadAmount = 0.2

    local sideBullet1Heading = towardsPlayer:copy()
    sideBullet1Heading:rotate(spreadAmount)
    local sideBullet1 = EnemyBullet:new(
        self,
        self.x + self.mask.width / 2 - 9,
        self.y + self.mask.height / 2 - 9,
        sideBullet1Heading,
        EnemyBullet.BULLET_SPEED * 1.5,
        false, true
    )
    self.world:add(sideBullet1)

    local sideBullet2Heading = towardsPlayer:copy()
    sideBullet2Heading:rotate(-spreadAmount)
    local sideBullet2 = EnemyBullet:new(
        self,
        self.x + self.mask.width / 2 - 9,
        self.y + self.mask.height / 2 - 9,
        sideBullet2Heading,
        EnemyBullet.BULLET_SPEED * 1.5,
        false, true
    )
    self.world:add(sideBullet2)
    self.sfx["enemyshotsmall"]:play()
end

function SecretBoss:movement(dt)
    if self.phaseNumber == 1 then
        self:phaseOneMovement(dt)
    elseif self.phaseNumber == 2 then
        if self.world:hasFlag(self.flag) and not self.fanTimer.active then
            local maxSpeed = SecretBoss.BOUNCE_SPEED
            if not self.world.isHardMode then
                maxSpeed = maxSpeed / 2
            end
            self.velocity:normalize(maxSpeed)
            self.fanTimer:start()
        end
        self:phaseTwoMovement(dt)
    else
        self.fanTimer.active = false
        self:phaseThreeMovement(dt)
    end
end

function SecretBoss:phaseThreeMovement(dt)
    local towardsPlayer = Vector:new(
        self.world.player:getMaskCenter().x - self:getMaskCenter().x,
        self.world.player:getMaskCenter().y - self:getMaskCenter().y
    )
    local maxSpeed = SecretBoss.CHASE_SPEED
    if not self.world.isHardMode then
        maxSpeed = maxSpeed / 2
    end
    if GameWorld.static.isSecondTower then
        maxSpeed = maxSpeed * 1.5
    end
    towardsPlayer:normalize(maxSpeed / 25)
    self.velocity.x = self.velocity.x + towardsPlayer.x
    self.velocity.y = self.velocity.y + towardsPlayer.y
    if self.velocity:len() > maxSpeed then
        self.velocity:normalize(maxSpeed)
    end
    self:moveBy(self.velocity.x * dt, self.velocity.y * dt)
end

function SecretBoss:phaseTwoMovement(dt)
    self:moveBy(self.velocity.x * dt, self.velocity.y * dt, {"walls", "lock"})
end

function SecretBoss:moveCollideX(collided)
    self.velocity.x = -self.velocity.x
end

function SecretBoss:moveCollideY(collided)
    self.velocity.y = -self.velocity.y
end

function SecretBoss:phaseOneMovement(dt)
    if self.pauseTimer.active then
        return
    end

    local maxSpeed = SecretBoss.NODE_TRAVEL_SPEED
    if not self.world.isHardMode then
        maxSpeed = maxSpeed / 2
    end
    local moveAmount = maxSpeed * dt
    local reversed = self.reversed

    while moveAmount > 0 do
        local targetNodeIndex = self.nodeIndex
        if reversed then
            targetNodeIndex = self.nodeIndex - 1
            if not self.nodes[targetNodeIndex] then
                targetNodeIndex = #self.nodes
            end
        end
        local towardsNode = Vector:new(
            self.nodes[targetNodeIndex].x - self.x,
            self.nodes[targetNodeIndex].y - self.y
        )
        local distanceToNextNode = towardsNode:len()
        if distanceToNextNode > moveAmount then
            towardsNode:normalize(moveAmount)
            self:moveBy(
                towardsNode.x,
                towardsNode.y
            )
            moveAmount = 0
        else
            local moveRemainder = Vector:new(
                self._moveX, self._moveY
            )
            self:moveTo(
                self.nodes[targetNodeIndex].x,
                self.nodes[targetNodeIndex].y
            )
            --if self.phaseNumber == 1 then
            moveAmount = 0
            self.pauseTimer:start()
            self.attackTimer:start()
            reversed = love.math.random() > 0.5
            if reversed then
                self.nodeIndex = self.nodeIndex - 1
                if not self.nodes[self.nodeIndex] then
                    self.nodeIndex = #self.nodes
                end
            else
                self.nodeIndex = self.nodeIndex + 1
                if not self.nodes[self.nodeIndex] then
                    self.nodeIndex = 1
                end
            end
        end
    end
end

function SecretBoss:collisions(dt)
    self:bossCollisions(dt)
end

function SecretBoss:takeHit(damage)
    self:bossTakeHit(damage)
end

function SecretBoss:die()
    if self.phaseNumber == 3 then
        self:bossDie()
    else
        self.sfx["bosspredeath"]:play()
        self.world:pauseLevel()
        self.world:doSequence({
            {1, function()
                self.world:unpauseLevel()
            end}
        })
        self.phaseNumber = self.phaseNumber + 1
        self.health = self.startingHealth
        if GameWorld.static.isSecondTower then
            if self.phaseNumber == 2 then
                self.displayName = "KING (WILD)"
            else
                self.displayName = "KING (UNDONE)"
            end
        else
            if self.phaseNumber == 2 then
                self.displayName = "NYMPH (WILD)"
            else
                self.displayName = "NYMPH (UNDONE)"
            end
        end
    end
end

