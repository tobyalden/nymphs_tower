json = require "json"
Level = class("Level", Entity)

function Level:initialize(path)
    Entity.initialize(self, 0, 0)
    self.types = {"walls"}
    io.input(path)
    raw = io.read("*all")
    jsonData = json.decode(raw)
    -- TODO: Instead of just grabbing the first layer, check that its name is
    -- "walls"
    self.mask = Grid:new(self, jsonData["width"], jsonData["height"], 16, 16)
    for tileX = 1, jsonData["layers"][1]["gridCellsX"] do
        for tileY = 1, jsonData["layers"][1]["gridCellsY"] - 1 do
            self.mask:setTile(
                tileX, tileY,
                jsonData["layers"][1]["grid2D"][tileY][tileX] == "1"
            )
        end
    end
end

function Level:update(dt)
end

function Level:draw()
    for tileX = 1, self.mask.columns do
        for tileY = 1, self.mask.rows do
            if(self.mask:getTile(tileX, tileY)) then
                love.graphics.rectangle(
                    "fill", (tileX - 1) * 16, (tileY - 1) * 16, 16, 16
                )
            end
        end
    end
end

