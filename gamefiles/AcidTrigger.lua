AcidTrigger = class("AcidTrigger", Entity)

function AcidTrigger:initialize(x, y, width, height, acidId, riseTo, uniqueId)
    Entity.initialize(self, x, y)
    self.uniqueId = uniqueId
    self.acidId = acidId
    self.riseTo = riseTo
    self.types = {"acid_trigger"}
    self.mask = Hitbox:new(self, width, height)
    -- self.graphic = TiledSprite:new("acidtrigger.png", 16, 16, width, height)
    self.acidId = acidId
    self.requireAcid = requireAcid
    print('unique id for trigger is ' .. uniqueId)
end

function AcidTrigger:trigger()
    for _, entity in pairs(self.world.level.entities) do
        local isAcid = false
        for _, entityType in pairs(entity.types) do
            if entityType == "acid" then
                isAcid = true
                break
            end
        end
        if isAcid and entity.acidId == self.acidId then
            entity:rise(self.riseTo)
            self.world:remove(self)
        end
    end
end

function AcidTrigger:update(dt)
    Entity.update(self, dt)
end
