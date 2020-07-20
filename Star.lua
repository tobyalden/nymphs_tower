Star = class("Star", Entity)

Star.static.MOVE_SPEED = 100

function Star:initialize(x, y, headingX, headingY)
    Entity.initialize(self, x, y)
    self.types = {"enemy"}
    self.graphic = Sprite:new("star.png")
    self.mask = Hitbox:new(self, 12, 12)
    self.graphic.offsetX = -2
    self.graphic.offsetY = -2
    self.velocity = Vector:new(headingX, headingY)
    self.velocity:normalize(Star.MOVE_SPEED)
    self.layer = -1
end

function Star:update(dt)
    self:moveBy(
        self.velocity.x * dt,
        self.velocity.y * dt,
        {"walls"}
    )
    Entity.update(self, dt)
end

function Star:moveCollideX(collided)
    self.velocity.x = -self.velocity.x
end

function Star:moveCollideY(collided)
    self.velocity.y = -self.velocity.y
end
