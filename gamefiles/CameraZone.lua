CameraZone = class("CameraZone", Entity)

function CameraZone:initialize(x, y, width, height)
    Entity.initialize(self, x, y)
    self.types = {"camera_zone"}
    self.mask = Hitbox:new(self, width, height)
end

function CameraZone:getSize()
    return self.mask.width * self.mask.height
end