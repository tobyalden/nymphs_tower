Boat = class("Boat", Entity)

Boat.static.BOB_SPEED = 1.5
Boat.static.BOB_AMOUNT = 4

function Boat:initialize(x, y, isBackground)
    Entity.initialize(self, x, y)
    self.types = {"boat", "walls"}
    if isBackground then
        self.layer = 1
        self.graphic = Sprite:new("boat_bg.png")
    else
        self.layer = -2
        self.graphic = Sprite:new("boat_fg.png")
    end
    self.mask = Hitbox:new(self, 116, 32, 0, 160 - 32)
    self.bobUp = false
    self.bobTimer = self:addTween(Alarm:new(
        Boat.BOB_SPEED,
        function()
            self.bobUp = not self.bobUp
        end,
        "looping"
    ), true)
end

function Boat:update(dt)
    if self.bobUp then
        self.graphic.offsetY = (
            easeInOutSine(self.bobTimer:getPercentComplete()) * Boat.BOB_AMOUNT
        )
    else
        self.graphic.offsetY = (
            easeInOutSine(1 - self.bobTimer:getPercentComplete())
        ) * Boat.BOB_AMOUNT
    end
    Entity.update(self, dt)
end

function easeInOutSine(number)
    return -(math.cos(math.pi * number) - 1) / 2
end
