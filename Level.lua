json = require "json"
Level = class("Level", Entity)

function Level:initialize(path)
    Entity.initialize(self, 0, 0)
    self.types = {"walls"}
    io.input(path)
    raw = io.read("*all")
    jsonData = json.decode(raw)

    self.entities = {}

    self.mask = Grid:new(self, jsonData["width"], jsonData["height"], 16, 16)
    for _, layer in pairs(jsonData["layers"]) do
        -- set mask
        if layer["name"] == "walls" then
            for tileX = 1, layer["gridCellsX"] do
                for tileY = 1, layer["gridCellsY"] - 1 do
                    self.mask:setTile(
                        tileX, tileY, layer["grid2D"][tileY][tileX] == "1"
                    )
                end
            end
        end

        -- load entities
        if layer["name"] == "entities" then
            for _, entity in pairs(layer["entities"]) do
                if entity["name"] == "player" then
                    local player = Player:new(entity["x"], entity["y"])
                    player.x = player.x + 5
                    player.y = player.y + 11
                    self.entities["player"] = player
                end
                if entity["name"] == "acid" then
                    local acid = Acid:new(
                        entity["x"], entity["y"],
                        entity["width"], entity["height"]
                    )
                    table.insert(self.entities, acid)
                end
            end
        end

        -- load camera zones
        if layer["name"] == "camera_zones" then
            for _, entity in pairs(layer["entities"]) do
                if entity["name"] == "camera_zone" then
                    local cameraZone = CameraZone:new(
                        entity["x"], entity["y"],
                        entity["width"], entity["height"]
                    )
                    table.insert(self.entities, cameraZone)
                end
            end
        end
    end

    -- set graphic
    self.graphic = Tilemap:new("tiles.png", 16, 16)
    for tileY = 1, self.mask.rows do
        for tileX = 1, self.mask.columns do
            if self.mask:getTile(tileX, tileY) then
                self.graphic:setTile(tileX, tileY, 2)
            end
        end
    end

    self.layer = -3
end

function Level:update(dt)
end
