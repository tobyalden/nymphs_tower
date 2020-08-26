Acid = class("Acid", Entity)

Acid.static.DAMAGE_RATE = 12.5
--Acid.static.DAMAGE_RATE = 0

function Acid:initialize(x, y, width, height, acid_id, rise_speed)
    Entity.initialize(self, x, y)
    self.acid_id = acid_id
    self.rise_speed = rise_speed
    self.original_y = y
    self.original_height = height
    self.rise_to = height
    self.types = {"acid"}
    self.graphic = TiledSprite:new("acid.png", 8, 8, width, height)
    self.mask = Hitbox:new(self, width, height)
    self.layer = -2
    self.riseTimer = self:addTween(Alarm:new(1))
end

function Acid:rise(rise_to)
    local distanceToRise = math.abs(self.mask.height - rise_to)
    local riseTime = distanceToRise / self.rise_speed
    self.riseTimer:start(riseTime)
    self.rise_to = rise_to
end

function Acid:update(dt)
        --if self.shotCooldown.active then
            --if self.shotCooldown:getPercentComplete() > 0.75 then
    --if self.mask.height ~= self.rise_to then
    if self.riseTimer.active then
        self.graphic.scaleY = (
            1 + (self.rise_to / self.original_height - 1)
            * self.riseTimer:getPercentComplete()
        )
        self.y = (
            self.original_y - (self.rise_to - self.original_height)
            * self.riseTimer:getPercentComplete()
        )
        self.mask.height = self.rise_to
    --else
        --self.graphic.scaleY = self.rise_to / self.original_height
        --self.y = self.original_y - (self.rise_to - self.original_height)
        --self.mask.height = self.rise_to
    end
    Entity.update(self, dt)
end
