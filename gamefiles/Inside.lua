Inside = class("Inside", Entity)

function Inside:initialize(x, y, width, height)
    Entity.initialize(self, x, y)
    self.types = {"inside"}
    self.mask = Hitbox:new(self, width, height)
end


