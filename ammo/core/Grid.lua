Grid = class("Grid")

function Grid:initialize(parent, width, height, tileWidth, tileHeight)
    self.width = math.ceil(width / tileWidth) * tileWidth
    self.height = math.ceil(height / tileHeight) * tileHeight
    self.tileWidth = tileWidth
    self.tileHeight = tileHeight
    self.rows = self.height / tileHeight
    self.columns = self.width / tileWidth
    self.data = {}
    self.solidType = solidType
    for tileY = 1, self.rows do
        self.data[tileY] = {}
        for tileX = 1, self.columns do
            self.data[tileY][tileX] = { isSolid = false, types = parent.types }
        end
    end
end

function Grid:setTile(tileX, tileY, solid)
    self.data[tileY][tileX].isSolid = solid
end

function Grid:getTile(tileX, tileY)
    -- TODO: Check if tileX & tileY are valid
    return self.data[tileY][tileX].isSolid
end
