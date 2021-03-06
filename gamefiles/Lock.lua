Lock = class("Lock", Entity)

function Lock:initialize(x, y, width, height, flag)
    Entity.initialize(self, x, y)
    self.types = {"lock"}
    if GameWorld.static.isSecondTower then
        self.graphic = TiledSprite:new("lock_alt.png", 32, 32, width, height)
    else
        self.graphic = TiledSprite:new("lock.png", 32, 32, width, height)
    end
    self.mask = Hitbox:new(self, width, height)
    self.layer = -2
    self.flag = flag
end

function Lock:update(dt)
    local defeatedFlag
    if GameWorld.static.isSecondTower then
        defeatedFlag = self.flag .. '_defeated_again'
    else
        defeatedFlag = self.flag .. '_defeated'
    end
    local isSolid = (
        self.world:hasFlag(self.flag)
        and not self.world:hasFlag(defeatedFlag)
    )
    self.visible = isSolid
    self.collidable = isSolid
    Entity.update(self, dt)
end
