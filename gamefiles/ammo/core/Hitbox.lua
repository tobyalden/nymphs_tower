Hitbox = class("Hitbox")

function Hitbox:initialize(parent, width, height)
  self.parent = parent
  self.width = width
  self.height = height
end

function Hitbox:updateHeight(newHeight)
    self.height = newHeight
    bumpWorld:update(self, self.parent.x, self.parent.y, self.width, self.height)
end
