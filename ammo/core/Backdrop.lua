Backdrop = class("Backdrop")

function Backdrop:initialize(path)
    self.image = love.graphics.newImage(path)
    self.batch = love.graphics.newSpriteBatch(self.image)
    self.tiles = {}
    for tileX = 0, math.ceil(gameWidth / self.image:getWidth()) + 1 do
        for tileY = 0, math.ceil(gameHeight / self.image:getHeight()) + 1 do
            self.batch:add(
                love.graphics.newQuad(
                    0, 0,
                    self.image:getWidth(), self.image:getHeight(),
                    self.image:getWidth(), self.image:getHeight()
                ),
                (tileX - 1) * self.image:getWidth(),
                (tileY - 1) * self.image:getHeight()
            )
        end
    end
end
