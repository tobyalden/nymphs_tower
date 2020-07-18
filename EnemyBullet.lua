EnemyBullet = class("EnemyBullet", Entity)

EnemyBullet.static.BULLET_SPEED = 100

function EnemyBullet:initialize(x, y, heading)
    Entity.initialize(self, x, y)
    self.types = {"enemy_bullet"}
    self.graphic = Sprite:new("enemybullet.png")
    self.mask = Hitbox:new(self, 18, 18)
    self.graphic.offsetX = -3
    self.graphic.offsetY = -3
    self.velocity = heading
    self.velocity:normalize(EnemyBullet.BULLET_SPEED)
    self.layer = -1
end

function EnemyBullet:update(dt)
    self:moveBy(
        self.velocity.x * dt,
        self.velocity.y * dt,
        {"walls"}
    )
    Entity.update(self, dt)
end

function EnemyBullet:moveCollideX(collided)
    self.world:remove(self)
end

function EnemyBullet:moveCollideY(collided)
    self.world:remove(self)
end

