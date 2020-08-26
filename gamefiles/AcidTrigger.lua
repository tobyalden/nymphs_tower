AcidTrigger = class("AcidTrigger", Entity)

function AcidTrigger:initialize(x, y, width, height, acid_id, rise_to)
    Entity.initialize(self, x, y)
    self.acid_id = acid_id
    self.rise_to = rise_to
    self.types = {"acid_trigger"}
    self.mask = Hitbox:new(self, width, height)
    self.graphic = TiledSprite:new("acidtrigger.png", 16, 16, width, height)
    self.acid_id = acid_id
    self.requireAcid = requireAcid
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
        if isAcid and entity.acid_id == self.acid_id then
            entity:rise(self.rise_to)
            self.world:remove(self)
        end
    end
end

function AcidTrigger:update(dt)
    Entity.update(self, dt)
end
