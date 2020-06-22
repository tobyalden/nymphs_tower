FlagTrigger = class("FlagTrigger", Entity)

function FlagTrigger:initialize(x, y, width, height, flag)
    Entity.initialize(self, x, y)
    self.types = {"flag_trigger"}
    self.mask = Hitbox:new(self, width, height)
    self.graphic = TiledSprite:new("flagtrigger.png", 16, 16, width, height)
    self.flag = flag
end

function FlagTrigger:trigger()
    self.world.flags[self.flag] = true
    self.world:remove(self)
    --print(inspect(self.world.flags))
end

function FlagTrigger:update(dt)
    Entity.update(self, dt)
end


