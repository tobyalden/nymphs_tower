Tilemap = class("Tilemap")

function Tilemap:initialize(path, tileWidth, tileHeight)
    self.image = love.graphics.newImage(path)
    self.batch = love.graphics.newSpriteBatch(self.image)
    self.tileWidth = tileWidth
    self.tileHeight = tileHeight
    self.tiles = {}
    self.spriteIds = {}

    for tileY = 1, self.image:getHeight() / tileHeight do
        for tileX = 1, self.image:getWidth() / tileWidth do
            table.insert(
                self.tiles,
                love.graphics.newQuad(
                    (tileX - 1) * tileWidth, (tileY - 1) * tileHeight,
                    tileWidth, tileHeight,
                    self.image:getWidth(), self.image:getHeight()
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
    -- TODO: Store ID, set tile instead of adding if already exists in batch
end

function Tilemap:getTile(tileX, tileY)
end

