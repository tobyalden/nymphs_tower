json = require "json"
Level = class("Level", Entity)

function Level:initialize(path)
    Entity.initialize(self, 0, 0)
    self.types = {"walls"}
    io.input(path)
    raw = io.read("*all")
    jsonData = json.decode(raw)
    self.mask = Grid:new(self, jsonData["width"], jsonData["height"], 16, 16)
    for _, layer in pairs(jsonData["layers"]) do
        if layer["name"] == "walls" then
            for tileX = 1, layer["gridCellsX"] do
                for tileY = 1, layer["gridCellsY"] - 1 do
                    self.mask:setTile(
                        tileX, tileY, layer["grid2D"][tileY][tileX] == "1"
                    )
                end
            end
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

