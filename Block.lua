Block = class("Block", Entity)

function Block:initialize(x, y)
    Entity.initialize(self, x, y)
    self.types = {"block"}
    self.graphic = Sprite:new("block.png")
    self.mask = Hitbox:new(self, 16, 16)
    self.layer = -2
end

function Block:update(dt)
    Entity.update(self, dt)
    local collidedBullets = self:collide(self.x, self.y, {"player_bullet"})
    if #collidedBullets > 0 then
        self.world:remove(self)
        for _, collidedBullet in pairs(collidedBullets) do
            collidedBullet.collidable = false
            self.world:remove(collidedBullet)
        end
    end
end
