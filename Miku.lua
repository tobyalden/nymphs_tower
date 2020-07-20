Miku = class("Miku", Entity)
Miku:include(Boss)

Miku.static.MAX_SPEED = 50
--Miku.static.MAX_SPEED = 0

function Miku:initialize(x, y, nodes)
    Entity.initialize(self, x, y)
    self.displayName = "VESSEL"
    self.flag = "miku"
    self.types = {"enemy"}
    self.startingHealth = 18
    --self.startingHealth = 1
    self.health = self.startingHealth
    self.graphic = Sprite:new("miku.png")
    self.mask = Hitbox:new(self, 80, 100)
    self.layer = 0
    self.nodes = {}
    for i, node in pairs(nodes) do
        self.nodes[i] = Vector:new(node.x, node.y)
    end
    self.nodeIndex = 1
    self.reversed = love.math.random() > 0.5
    self.shotTimer = self:addTween(Alarm:new(
        1,
        function()
            self:fireBullet()
        end,
        "looping"
    ))
end 

function Miku:update(dt)
    self:bossUpdate(dt)
    Entity.update(self, dt)
end

function Miku:fireBullet()
    --local towardsPlayer = Vector:new(
        --self.world.player:getMaskCenter().x - self:getMaskCenter().x,
        --self.world.player:getMaskCenter().y - self:getMaskCenter().y
    --)
    local shotSeparation = 30
    local bullet = EnemyBullet:new(
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

function Miku:movement(dt)
    local shotTime = 1
    if self.world.isHardMode then
        shotTime = 0.5
    end
    if self.world:hasFlag(self.flag) and not self.shotTimer.active then
        self.shotTimer:start(shotTime)
    end
    --print(self.shotTimer.time)

    local maxSpeed = Miku.MAX_SPEED
    local moveAmount = Miku.MAX_SPEED * dt
    local reversed = self.reversed
    --moveAmount = 0
    --moveAmount = math.abs(moveAmount)

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
            moveAmount = moveAmount - distanceToNextNode + moveRemainder:len()
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

function Miku:collisions(dt)
    self:bossCollisions(dt)
end

function Miku:takeHit(damage)
    self:bossTakeHit(damage)
end

function Miku:die()
    self:bossDie()
end

