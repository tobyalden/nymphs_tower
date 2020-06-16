Tilemap = class("Tilemap")

function Tilemap:initialize(path, tileWidth, tileHeight)
    self.image = love.graphics.newImage(path)
    self.batch = love.graphics.newSpriteBatch(self.image)
    self.tileWidth = tileWidth
    self.tileHeight = tileHeight
    self.tiles = {}

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

function Tilemap:setTile(tileX, tileY, tileId)
    -- TODO: Store ID, set tile instead of adding if already exists in batch
    self.batch:add(
        self.tiles[tileId], 
        (tileX - 1) * self.tileWidth,
        (tileY - 1) * self.tileHeight
    )
end

function Tilemap:getTile(tileX, tileY)
end

