Wizard = class("Wizard", Entity)
Wizard:include(Boss)

Wizard.static.MAX_SPEED = 200
--Wizard.static.MAX_SPEED = 0

function Wizard:initialize(x, y, nodes)
    Entity.initialize(self, x, y)
    self.displayName = "WIZARD"
    self.flag = "wizard"
    self.types = {"enemy"}
    self.startingHealth = 10
    --self.startingHealth = 1
    self.health = self.startingHealth
    self.graphic = Sprite:new("wizard.png")
    self.mask = Hitbox:new(self, 48, 48)
    self.layer = 0
    self.nodes = {}
    for i, node in pairs(nodes) do
        self.nodes[i] = Vector:new(node.x, node.y)
    end
    self.nodeIndex = 1
    self.reversed = love.math.random() > 0.5
    self.lungeTimer = self:addTween(Alarm:new(
        math.pi,
        function()
            self.reversed = love.math.random() > 0.5
            self:fireBullet()
            self.world:doSequence({
                {0.25, function() self:fireBullet() end},
                {0.5, function() self:fireBullet() end}
            })
        end,
        "looping"
    ))
end 

function Wizard:update(dt)
    self:bossUpdate(dt)
    Entity.update(self, dt)
end

function Wizard:fireBullet()
    local towardsPlayer = Vector:new(
        self.world.player:getMaskCenter().x - self:getMaskCenter().x,
        self.world.player:getMaskCenter().y - self:getMaskCenter().y
    )
    local bullet = EnemyBullet:new(
        self.x + self.mask.width / 2 - 9,
        self.y + self.mask.height / 2 - 9,
        towardsPlayer
    )
    self.world:add(bullet)
end

function Wizard:movement(dt)
    if self.world:hasFlag(self.flag) and not self.lungeTimer.active then
        self.lungeTimer:start()
    end
    --print(self.lungeTimer.time)

    local moveAmount = Wizard.MAX_SPEED * dt * math.sin(self.lungeTimer.time)
    local reversed = self.reversed
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

function Wizard:collisions(dt)
    self:bossCollisions(dt)
end

function Wizard:takeHit(damage)
    self:bossTakeHit(damage)
end

function Wizard:die()
    self:bossDie()
end
