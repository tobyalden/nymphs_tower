Backdrop = class("Backdrop")

function Backdrop:initialize(path)
    self.image = love.graphics.newImage(path)
    self.batch = love.graphics.newSpriteBatch(self.image)
    self.tiles = {}
    imagesPerScreenWidth = math.ceil(gameWidth / self.image:getWidth())
    imagesPerScreenHeight = math.ceil(gameHeight / self.image:getHeight())
    for tileX = 0, imagesPerScreenWidth + 1 do
        for tileY = 0, imagesPerScreenHeight + 1 do
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
