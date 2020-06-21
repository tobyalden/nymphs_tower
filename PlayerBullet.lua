PlayerBullet = class("PlayerBullet", Entity)

PlayerBullet.static.BULLET_POWER = 1
PlayerBullet.static.BULLET_SPEED = 400

function PlayerBullet:initialize(x, y, heading)
    Entity.initialize(self, x, y)
    self.types = {"player_bullet"}
    self.graphic = Sprite:new("playerbullet.png")
    self.mask = Hitbox:new(self, 3, 3)
    self.velocity = heading
    self.velocity:normalize(PlayerBullet.BULLET_SPEED)
end

function PlayerBullet:update(dt)
    self:moveBy(
        self.velocity.x * dt,
        self.velocity.y * dt,
        {"walls"}
    )
    Entity.update(self, dt)
end

function PlayerBullet:moveCollideX(collided)
    self.world:remove(self)
end

function PlayerBullet:moveCollideY(collided)
    self.world:remove(self)
end
