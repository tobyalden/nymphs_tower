TiledSprite = class("TiledSprite", Sprite)

function TiledSprite:initialize(path, frameWidth, frameHeight, drawWidth, drawHeight)
    Sprite.initialize(self, path, frameWidth, frameHeight)
    self.tiledFrames = {}
    for i, frame in pairs(self.frames) do
        self.tiledFrames[i] = love.graphics.newSpriteBatch(self.paddedImage)
        local lastTileX
        for tileX = 1, math.ceil(drawWidth / frameWidth) do
            for tileY = 1, math.ceil(drawHeight / frameHeight) do
                local _x, _y, _w, _h = self.frames[i]:getViewport()
                local _sw, _sh = self.frames[i]:getTextureDimensions()
                if tileX == math.ceil(drawWidth / frameWidth) and drawWidth % frameWidth ~= 0 then
                    _w = drawWidth % frameWidth
                end
                if tileY == math.ceil(drawHeight / frameHeight) and drawHeight % frameHeight ~= 0 then
                    _h = drawHeight % frameHeight
                end
                local leftoverFrame = love.graphics.newQuad(_x, _y, _w, _h, _sw, _sh)
                self.tiledFrames[i]:add(
                    leftoverFrame,
                    (tileX - 1) * frameWidth,
                    (tileY - 1) * frameHeight
                )
            end
        end
    end
end
