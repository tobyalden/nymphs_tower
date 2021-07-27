Block = class("Block", Entity)

function Block:initialize(x, y)
    Entity.initialize(self, x, y)
    self.types = {"block"}
    self.graphic = Sprite:new("block.png", 16, 16)
    self.graphic:add("1", {1})
    self.graphic:add("2", {2})
    self.graphic:add("3", {3})
    self.graphic:add("4", {4})
    self.graphic:play("1")
    --self.graphic:play(tostring(love.math.random(4)))
    self.mask = Hitbox:new(self, 16, 16)
    self.layer = -2
    self:loadSfx({"blockbreak.wav"})
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
        self.sfx["blockbreak"]:play()
        self:explode(8, 80, 1, 3, 0, 0, 1, false, true)
    end
end
