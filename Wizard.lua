Wizard = class("Wizard", Entity)
Wizard:include(Boss)

Wizard.static.MAX_SPEED = 90

function Wizard:initialize(x, y, nodes)
    Entity.initialize(self, x, y)
    self.displayName = "WIZARD"
    self.flag = "wizard"
    self.types = {"enemy"}
    self.startingHealth = 12
    self.health = self.startingHealth
    self.graphic = Sprite:new("wizard.png")
    self.mask = Hitbox:new(self, 48, 48)
    self.layer = 0
    self.nodes = {}
    for i, node in pairs(nodes) do
        self.nodes[i] = Vector:new(node.x, node.y)
    end
    self.nodeIndex = 1
    self.age = 0
end 

function Wizard:update(dt)
    self.age = self.age + dt
    self:bossUpdate(dt)
    Entity.update(self, dt)
end

function Wizard:movement(dt)
    local moveAmount = Wizard.MAX_SPEED * dt * math.sin(self.age)
    local reversed = moveAmount < 0
    moveAmount = math.abs(moveAmount)

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
            self:moveTo(
                self.nodes[targetNodeIndex].x,
                self.nodes[targetNodeIndex].y
            )
            moveAmount = moveAmount - distanceToNextNode
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
