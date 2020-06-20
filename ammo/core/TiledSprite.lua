TiledSprite = class("Sprite")

function TiledSprite:initialize(path, frameWidth, frameHeight, drawWidth, drawHeight)
    Sprite.initialize(self, path, frameWidth, frameHeight)
    self.tiledFrames = {}
    for i, frame in pairs(self.frames) do
        self.tiledFrames[i] = love.graphics.newSpriteBatch(self.image)
        for tileX = 1, drawWidth / frameWidth do
            for tileY = 1, drawHeight / frameHeight do
                self.tiledFrames[i]:add(
                    self.frames[i],
                    (tileX - 1) * frameWidth,
                    (tileY - 1) * frameHeight
                )
            end
        end
    end
end
