Lock = class("Lock", Entity)

function Lock:initialize(x, y, width, height, flag)
    Entity.initialize(self, x, y)
    self.types = {"lock"}
    self.graphic = TiledSprite:new("lock.png", 16, 16, width, height)
    self.mask = Hitbox:new(self, width, height)
    self.layer = -2
    self.flag = flag
end

function Lock:update(dt)
    local isSolid = self.world:hasFlag(self.flag)
    self.visible = isSolid
    self.collidable = isSolid
    Entity.update(self, dt)
end
