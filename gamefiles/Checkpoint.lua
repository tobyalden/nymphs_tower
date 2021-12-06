Checkpoint = class("Checkpoint", Entity)

--Checkpoint.static.ACCEL = 100

function Checkpoint:initialize(x, y)
    Entity.initialize(self, x, y)
    self.types = {"checkpoint"}
    self.graphic = Sprite:new("checkpoint.png", 16, 32)
    self.graphic:add("idle", {1, 5, 9, 13, 9, 5, 1}, 12)
    self.graphic:add("flash", {2, 6, 10}, 20, false, function()
        self.graphic:play("idle")
    end)
    self.graphic:play("idle")
    self.mask = Hitbox:new(self, 16, 32)
    self.layer = -2
end

function Checkpoint:flash()
    self.graphic:play("flash")
end

function Checkpoint:update(dt)
    local isSolid = not self.world:hasFlag('finalboss') and #self:collide(self.x, self.y, {"acid"}) == 0
    self.visible = isSolid
    self.collidable = isSolid
    Entity.update(self, dt)
end

