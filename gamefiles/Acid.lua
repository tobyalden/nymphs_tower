Acid = class("Acid", Entity)

Acid.static.DAMAGE_RATE = 12.5
--Acid.static.DAMAGE_RATE = 0

function Acid:initialize(x, y, width, height, acid_id, rise_speed)
    Entity.initialize(self, x, y)
    self.acid_id = acid_id
    self.rise_speed = rise_speed
    self.types = {"acid"}
    self.graphic = TiledSprite:new("acid.png", 8, 8, width, height)
    self.mask = Hitbox:new(self, width, height)
    self.layer = -2
end

function Acid:rise(rise_to)
    self.graphic.scaleY = rise_to / self.mask.height
    self.y = self.y - (rise_to - self.mask.height)
    self.mask.height = rise_to
end
