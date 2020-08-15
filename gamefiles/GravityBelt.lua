GravityBelt = class("GravityBelt", Entity)

function GravityBelt:initialize(x, y, uniqueId)
    Entity.initialize(self, x, y)
    self.uniqueId = uniqueId
    self.types = {"gravity_belt"}
    self.graphic = Sprite:new("gravitybelt.png")
    self.mask = Hitbox:new(self, 24, 24)
end
