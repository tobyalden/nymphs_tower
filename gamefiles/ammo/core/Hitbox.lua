Hitbox = class("Hitbox")

function Hitbox:initialize(parent, width, height, offsetX, offsetY)
  self.parent = parent
  self.width = width
  self.height = height
  self.offsetX = offsetX or 0
  self.offsetY = offsetY or 0
end

function Hitbox:updateHeight(newHeight)
    self.height = newHeight
    bumpWorld:update(
        self,
        self.parent.x + self.offsetX, self.parent.y + self.offsetY,
        self.width, self.height
    )
end

function Hitbox:updateOffset(newOffsetX, newOffsetY)
    self.offsetX = newOffsetX
    self.offsetY = newOffsetY
    bumpWorld:update(
        self,
        self.parent.x + self.offsetX, self.parent.y + self.offsetY,
        self.width, self.height
    )
end
