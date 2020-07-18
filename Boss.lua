Boss = {
    bossUpdate = function(self, dt)
        if self.world:hasFlag(self.flag .. '_defeated') then
            self.world:remove(self)
        elseif self.world:hasFlag(self.flag) then
            self.world.currentBoss = self
            self:movement(dt)
            self:collisions()
        end
    end,
    bossTakeHit = function(self, damage)
        self.health = self.health - damage
        if self.health <= 0 then
            self:die()
        end
    end,
    bossDie = function(self)
        self.world:remove(self)
        self.world:removeFlag(self.flag)
        self.world:addFlag(self.flag .. '_defeated')
        self.world.currentBoss = nil
    end,
    bossCollisions = function(self, dt)
        local collidedBullets = self:collide(self.x, self.y, {"player_bullet"})
        if #collidedBullets > 0 then
            self:takeHit(Player.GUN_POWER)
            for _, collidedBullet in pairs(collidedBullets) do
                self.world:remove(collidedBullet)
            end
        end
    end
}
