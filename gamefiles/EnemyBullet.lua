EnemyBullet = class("EnemyBullet", Entity)

EnemyBullet.static.BULLET_SPEED = 100

function EnemyBullet:initialize(parent, x, y, heading, speed, shouldFall, isSmall)
    Entity.initialize(self, x, y)
    speed = speed or EnemyBullet.BULLET_SPEED
    self.parent = parent
    self.shouldFall = shouldFall or false
    self.isSmall = isSmall or false
    self.types = {"enemy_bullet"}
    if self.isSmall then
        self.graphic = Sprite:new("enemybulletsmall.png")
        self.mask = Hitbox:new(self, 8, 8)
        self.graphic.offsetX = -2
        self.graphic.offsetY = -2
    else
        self.graphic = Sprite:new("enemybullet.png")
        self.mask = Hitbox:new(self, 18, 18)
        self.graphic.offsetX = -3
        self.graphic.offsetY = -3
    end
    self.velocity = heading
    self.velocity:normalize(speed)
    self.layer = -10
end

function EnemyBullet:update(dt)
    if self.shouldFall then
        self.velocity.y = self.velocity.y + Player.GRAVITY / 4 * dt
    end
    self:moveBy(
        self.velocity.x * dt,
        self.velocity.y * dt
    )
    if self:distanceFrom(self.parent, true) > (gameWidth + gameHeight) then
        self.world:remove(self)
    end
    Entity.update(self, dt)
end
