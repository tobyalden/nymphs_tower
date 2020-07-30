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
        self.world:removeFlag(self.flag)
        self.world:addFlag(self.flag .. '_defeated')
        self.world.currentBoss = nil
        self.sfx["bosspredeath"]:play()
        self:explode(80, 150, 5, 1, 0, 0, -99, true, true)
        self:explode(60, 150, 4, 1, 0, 0, -99, true, true)
        self:explode(30, 80, 3, 1, 0, 0, -99, true, true)
        self:explode(20, 50, 2, 1, 0, 0, -99, true, true)
        self:explode(10, 50, 1, 1, 0, 0, -99, true, true)
        self.world:pauseLevel()
        self.world:doSequence({
            {0.5, function()
                self.world:unpauseLevel()
                self.sfx["bossdeath"]:play()
                self.visible = false
                self.active = false
                self.world:remove(self)
            end}
        })
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
