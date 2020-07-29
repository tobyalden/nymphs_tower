PlayerBullet = class("PlayerBullet", Entity)

PlayerBullet.static.BULLET_POWER = 1
PlayerBullet.static.BULLET_SPEED = 400

function PlayerBullet:initialize(x, y, heading)
    Entity.initialize(self, x, y)
    self.types = {"player_bullet"}
    self.graphic = Sprite:new("playerbullet.png")
    self.mask = Hitbox:new(self, 6, 6)
    self.velocity = heading
    self.velocity:normalize(PlayerBullet.BULLET_SPEED)
    self:loadSfx({"playerbulletexplode.wav"})
end

function PlayerBullet:update(dt)
    self:moveBy(
        self.velocity.x * dt,
        self.velocity.y * dt,
        {"walls"}
    )
    Entity.update(self, dt)
end

function PlayerBullet:hit()
    self.world:remove(self)
    self.sfx["playerbulletexplode"]:play()
    self:explode(4, 30, 1, 18)
end

function PlayerBullet:moveCollideX(collided)
    self:hit()
end

function PlayerBullet:moveCollideY(collided)
    self:hit()
end
