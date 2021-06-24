FlagTrigger = class("FlagTrigger", Entity)

function FlagTrigger:initialize(x, y, width, height, flag, requireFlag)
    Entity.initialize(self, x, y)
    self.types = {"flag_trigger"}
    self.mask = Hitbox:new(self, width, height)
    --self.graphic = TiledSprite:new("flagtrigger.png", 16, 16, width, height)
    self.flag = flag
    self.requireFlag = requireFlag
end

function FlagTrigger:trigger()
    if self.requireFlag == "" or self.world:hasFlag(self.requireFlag) then
        self.world:addFlag(self.flag)
        self.world:remove(self)
    end
end

function FlagTrigger:update(dt)
    Entity.update(self, dt)
end


