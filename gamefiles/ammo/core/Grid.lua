Grid = class("Grid")

function Grid:initialize(parent, width, height, tileWidth, tileHeight)
    self.width = math.floor(width / tileWidth) * tileWidth
    self.height = math.floor(height / tileHeight) * tileHeight
    self.tileWidth = tileWidth
    self.tileHeight = tileHeight
    self.rows = self.height / tileHeight
    self.columns = self.width / tileWidth
    self.data = {}
    self.solidType = solidType
    for tileY = 1, self.rows do
        self.data[tileY] = {}
        for tileX = 1, self.columns do
            self.data[tileY][tileX] = { isSolid = false, parent = parent }
        end
    end
end

function Grid:setTile(tileX, tileY, solid)
    self.data[tileY][tileX].isSolid = solid
end

function Grid:getTile(tileX, tileY)
    return self.data[tileY][tileX].isSolid
end
