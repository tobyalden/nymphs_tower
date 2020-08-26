Acid = class("Acid", Entity)

Acid.static.DAMAGE_RATE = 12.5
--Acid.static.DAMAGE_RATE = 0

function Acid:initialize(x, y, width, height, acidId, riseSpeed, uniqueId)
    Entity.initialize(self, x, y)
    self.uniqueId = uniqueId
    self.acidId = acidId
    self.riseSpeed = riseSpeed
    self.originalY = y
    self.originalHeight = height
    self.riseTo = height
    self.types = {"acid"}
    self.graphic = TiledSprite:new("acid.png", 8, 8, width, height)
    self.mask = Hitbox:new(self, width, height)
    self.layer = -2
    self.riseTimer = self:addTween(Alarm:new(1, function()
        self:finishRise()
    end))
    self.onStart = false
end

function Acid:finishRise()
    self.graphic.scaleY = (
        1 + (self.riseTo / self.originalHeight - 1)
        * 1
    )
    self.y = (
        self.originalY - (self.riseTo - self.originalHeight)
        * 1
    )
    self.mask:updateHeight(self.originalHeight * self.graphic.scaleY)

    self.originalY = self.y
    self.originalHeight = self.mask.height
    self.graphic = TiledSprite:new(
        "acid.png", 8, 8, self.mask.width, self.mask.height
    )
    self.graphic.scaleY = 1
end

function Acid:rise(riseTo)
    local distanceToRise = math.abs(self.mask.height - riseTo)
    local riseTime = distanceToRise / self.riseSpeed
    self.riseTimer:start(riseTime)
    self.riseTo = riseTo
end

function Acid:update(dt)
    if not self.onStart then
        self:finishRise()
        self.onStart = true
    end
    if self.riseTimer.active then
        self.graphic.scaleY = (
            1 + (self.riseTo / self.originalHeight - 1)
            * self.riseTimer:getPercentComplete()
        )
        self.y = (
            self.originalY - (self.riseTo - self.originalHeight)
            * self.riseTimer:getPercentComplete()
        )
        self.mask:updateHeight(self.originalHeight * self.graphic.scaleY)
    else
        --self.graphic.scaleY = self.riseTo / self.originalHeight
        --self.y = self.originalY - (self.riseTo - self.originalHeight)
        --self.mask:updateHeight(self.originalHeight * self.graphic.scaleY)
    end
    Entity.update(self, dt)
end
