Tilemap = class("Tilemap")

function Tilemap:initialize(path, tileWidth, tileHeight)
    self.image = love.graphics.newImage(path)
    local imageData = love.image.newImageData(path)
    local widthInTiles = self.image:getWidth() / tileWidth
    local heightInTiles = self.image:getHeight() / tileHeight
    local pixelOffsetX = 0
    local pixelOffsetY = 0
    local padding = 1
    local paddedImageData = love.image.newImageData(
        self.image:getWidth() + widthInTiles * padding,
        self.image:getHeight() + heightInTiles * padding
    )
    -- Create a new image from the source image with added padding between tiles
    for pixelY = 0, imageData:getHeight() - 1 do
        if pixelY > 0 and pixelY % tileHeight == 0 then
            pixelOffsetY = pixelOffsetY + padding
        end
        for pixelX = 0, imageData:getWidth() - 1 do
            if pixelX > 0 and pixelX % tileWidth == 0 then
                pixelOffsetX = pixelOffsetX + padding
            end
            local r, g, b, a = imageData:getPixel(pixelX, pixelY)
            paddedImageData:setPixel(
                pixelX + pixelOffsetX, pixelY + pixelOffsetY, r, g, b, a
            )
        end
        pixelOffsetX = 0
    end
    self.paddedImage = love.graphics.newImage(paddedImageData)
    self.batch = love.graphics.newSpriteBatch(self.paddedImage)
    self.tileWidth = tileWidth
    self.tileHeight = tileHeight
    self.tiles = {}
    self.spriteIds = {}

    -- Chop padded image up into tiles
    for tileY = 1, heightInTiles do
        for tileX = 1, widthInTiles do
            table.insert(
                self.tiles,
                love.graphics.newQuad(
                    (tileX - 1) * (tileWidth + padding),
                    (tileY - 1) * (tileHeight + padding),
                    tileWidth, tileHeight,
                    self.paddedImage:getWidth(), self.paddedImage:getHeight()
                )
            )
        end
    end

end

function getSpriteKey(tileX, tileY)
    return tileX .. "-" .. tileY
end

function Tilemap:setTile(tileX, tileY, tileId)
    local spriteKey = getSpriteKey(tileX, tileY)
    if self.spriteIds[spriteKey] then
        self.batch:set(
            self.spriteIds[spriteKey],
            self.tiles[tileId],
            (tileX - 1) * self.tileWidth,
            (tileY - 1) * self.tileHeight
        )
    else
        local spriteId = self.batch:add(
            self.tiles[tileId],
            (tileX - 1) * self.tileWidth,
            (tileY - 1) * self.tileHeight
        )
        self.spriteIds[spriteKey] = spriteId
    end
end

function Tilemap:getTile(tileX, tileY)
end

