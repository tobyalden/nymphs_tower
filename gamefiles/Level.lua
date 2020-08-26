json = require "json"
Level = class("Level", Entity)

function Level:initialize(path)
    Entity.initialize(self, 0, 0)
    self.types = {"walls"}
    --io.input(path)
    --io.input(path)
    --raw = io.read("*all")
    raw = love.filesystem.read(path)
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
        local uniqueId = 0
        if layer["name"] == "entities" then
            for _, entity in pairs(layer["entities"]) do
                if entity["name"] == "player" then
                    local player = Player:new(entity["x"], entity["y"])
                    player.x = player.x + 5
                    player.y = player.y + 11
                    self.entities["player"] = player
                elseif entity["name"] == "acid" then
                    local acid = Acid:new(
                        entity["x"], entity["y"],
                        entity["width"], entity["height"],
                        entity["values"]["acid_id"], entity["values"]["rise_speed"]
                    )
                    table.insert(self.entities, acid)
                elseif entity["name"] == "acid_trigger" then
                    local acidTrigger = AcidTrigger:new(
                        entity["x"], entity["y"],
                        entity["width"], entity["height"],
                        entity["values"]["acid_id"], entity["values"]["rise_to"]
                    )
                    table.insert(self.entities, acidTrigger)
                elseif entity["name"] == "gun" then
                    local gun = Gun:new(entity["x"], entity["y"], uniqueId)
                    table.insert(self.entities, gun)
                    uniqueId = uniqueId + 1
                elseif entity["name"] == "harmonica" then
                    local harmonica = Harmonica:new(
                        entity["x"], entity["y"], uniqueId
                    )
                    table.insert(self.entities, harmonica)
                    uniqueId = uniqueId + 1
                elseif entity["name"] == "gravity_belt" then
                    local gravityBelt = GravityBelt:new(
                        entity["x"], entity["y"], uniqueId
                    )
                    table.insert(self.entities, gravityBelt)
                    uniqueId = uniqueId + 1
                elseif entity["name"] == "hazard_suit" then
                    local hazardSuit = HazardSuit:new(
                        entity["x"], entity["y"], uniqueId
                    )
                    table.insert(self.entities, hazardSuit)
                    uniqueId = uniqueId + 1
                elseif entity["name"] == "health_upgrade" then
                    local healthUpgrade = HealthUpgrade:new(
                        entity["x"], entity["y"], uniqueId
                    )
                    table.insert(self.entities, healthUpgrade)
                    uniqueId = uniqueId + 1
                elseif entity["name"] == "fuel_upgrade" then
                    local fuelUpgrade = FuelUpgrade:new(
                        entity["x"], entity["y"],
                        entity["values"]["add_flag"], uniqueId
                    )
                    table.insert(self.entities, fuelUpgrade)
                    uniqueId = uniqueId + 1
                elseif entity["name"] == "block" then
                    local block = Block:new(entity["x"], entity["y"])
                    table.insert(self.entities, block)
                elseif entity["name"] == "pig" then
                    local pig = Pig:new(entity["x"], entity["y"])
                    table.insert(self.entities, pig)
                elseif entity["name"] == "wizard" then
                    local wizard = Wizard:new(
                        entity["x"], entity["y"], entity["nodes"]
                    )
                    table.insert(self.entities, wizard)
                elseif entity["name"] == "miku" then
                    local miku = Miku:new(
                        entity["x"], entity["y"], entity["nodes"]
                    )
                    table.insert(self.entities, miku)
                elseif entity["name"] == "finalboss" then
                    local finalBoss = FinalBoss:new(
                        entity["x"], entity["y"], entity["nodes"]
                    )
                    table.insert(self.entities, finalBoss)
                elseif entity["name"] == "secret_boss" then
                    local secretBoss = SecretBoss:new(
                        entity["x"], entity["y"], entity["nodes"]
                    )
                    table.insert(self.entities, secretBoss)
                elseif entity["name"] == "lock" then
                    local lock = Lock:new(
                        entity["x"], entity["y"],
                        entity["width"], entity["height"],
                        entity["values"]["flag"]
                    )
                    table.insert(self.entities, lock)
                elseif entity["name"] == "flag_trigger" then
                    local flagTrigger = FlagTrigger:new(
                        entity["x"], entity["y"],
                        entity["width"], entity["height"],
                        entity["values"]["flag"],
                        entity["values"]["require_flag"]
                    )
                    table.insert(self.entities, flagTrigger)
                elseif entity["name"] == "checkpoint" then
                    local checkpoint = Checkpoint:new(entity["x"], entity["y"])
                    table.insert(self.entities, checkpoint)
                elseif entity["name"] == "spike_floor" then
                    local spikeFloor = Spike:new(
                        entity["x"], entity["y"], entity["width"], 16, "floor"
                    )
                    table.insert(self.entities, spikeFloor)
                elseif entity["name"] == "spike_ceiling" then
                    local spikeCeiling = Spike:new(
                        entity["x"], entity["y"], entity["width"], 16, "ceiling"
                    )
                    table.insert(self.entities, spikeCeiling)
                elseif entity["name"] == "spike_left" then
                    local spikeLeft = Spike:new(
                        entity["x"], entity["y"], 16, entity["height"], "left"
                    )
                    table.insert(self.entities, spikeLeft)
                elseif entity["name"] == "spike_right" then
                    local spikeRight = Spike:new(
                        entity["x"], entity["y"], 16, entity["height"], "right"
                    )
                    table.insert(self.entities, spikeRight)
                elseif entity["name"] == "star" then
                    local star = Star:new(
                        entity["x"] + 2, entity["y"] + 2,
                        entity["values"]["headingX"],
                        entity["values"]["headingY"]
                    )
                    table.insert(self.entities, star)
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
