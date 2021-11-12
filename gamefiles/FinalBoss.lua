FinalBoss = class("FinalBoss", Entity)
FinalBoss:include(Boss)

FinalBoss.static.MAX_SPEED = 100
FinalBoss.static.MAX_SPEED_HARD_MODE = 150

-- TODO: It seems like having a big hitbox and calling moveBy causes the engine
-- to run incredibly slow. bypassed with moveTo method, but definitely a bug

function FinalBoss:initialize(x, y, nodes)
    Entity.initialize(self, x, y)
    if GameWorld.static.isSecondTower then
        self.displayName = "KEEPER"
    else
        self.displayName = "WOUNDED KEEPER"
    end
    self.flag = "finalboss"
    self.types = {"instakill"}
    self.startingHealth = 50
    --self.startingHealth = 1
    self.health = self.startingHealth
    self.graphic = Sprite:new("keeper.png", 192, 160)
    if GameWorld.static.isSecondTower then
        self.graphic:add("idle", {11, 12, 13, 14, 15, 16, 17, 18, 19, 20}, 5)
    else
        self.graphic:add("idle", {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}, 5)
    end
    self.graphic:play("idle")
    self.mask = Hitbox:new(self, 192, 160)
    self.layer = -5
    self.nodes = {}
    for i, node in pairs(nodes) do
        self.nodes[i] = Vector:new(node.x, node.y)
    end
    self.nodeIndex = 1
    self.shotTimer = self:addTween(Alarm:new(
        1,
        function()
            --self:fireBullet()
        end,
        "looping"
    ))
    self.stopMoving = false
    self:loadSfx({"bosshit.wav", "bossdeath.wav", "bosspredeath.wav"})
end

function FinalBoss:update(dt)
    if not self.world.isHardMode and self.health == self.startingHealth then
        self.health = math.ceil(self.startingHealth * 2/3)
    end
    self:bossUpdate(dt)
    Entity.update(self, dt)
end

function FinalBoss:fireBullet()
    --local towardsPlayer = Vector:new(
        --self.world.player:getMaskCenter().x - self:getMaskCenter().x,
        --self.world.player:getMaskCenter().y - self:getMaskCenter().y
    --)
    local shotSeparation = 30
    local bullet = EnemyBullet:new(
        self,
        self.x,
        self.y + 20
        + math.round(love.math.random()) * shotSeparation
        + math.round(love.math.random()) * shotSeparation,
        --Vector:new(-1, (0.5 - love.math.random()) / 2),
        Vector:new(-1, -1 * love.math.random()),
        150 + love.math.random() * 20, true
    )
    self.world:add(bullet)
end

function FinalBoss:movement(dt)
    if self.stopMoving then
        return
    end
    local shotTime = 1
    if self.world.isHardMode then
        shotTime = 0.5
    end
    if self.world:hasFlag(self.flag) and not self.shotTimer.active then
        self.shotTimer:start(shotTime)
    end
    --print(self.shotTimer.time)

    local maxSpeed = FinalBoss.MAX_SPEED
    if self.world.isHardMode then
        maxSpeed = FinalBoss.MAX_SPEED_HARD_MODE
    end
    local moveAmount = maxSpeed * dt
    --moveAmount = 0
    --moveAmount = math.abs(moveAmount)

    while moveAmount > 0 do
        local targetNodeIndex = self.nodeIndex
        local towardsNode = Vector:new(
            self.nodes[targetNodeIndex].x - self.x,
            self.nodes[targetNodeIndex].y - self.y
        )
        local distanceToNextNode = towardsNode:len()
        if distanceToNextNode > moveAmount then
            towardsNode:normalize(moveAmount)
            self:moveTo(
                self.x + towardsNode.x,
                self.y + towardsNode.y
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
            moveAmount = moveAmount - distanceToNextNode + moveRemainder:len()
            self.nodeIndex = self.nodeIndex + 1
            if not self.nodes[self.nodeIndex] then
                self.stopMoving = true
                moveAmount = 0
            end
        end
    end
end

function FinalBoss:collisions(dt)
    self:bossCollisions(dt)
end

function FinalBoss:takeHit(damage)
    self:bossTakeHit(damage)
end

function FinalBoss:die()
    self:bossDie()
end
