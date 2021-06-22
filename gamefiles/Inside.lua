Inside = class("Inside", Entity)

function Inside:initialize(x, y, width, height, musicName)
    Entity.initialize(self, x, y)
    self.types = {"inside"}
    self.mask = Hitbox:new(self, width, height)
    self.musicName = musicName
    --print(self.musicName)
end


