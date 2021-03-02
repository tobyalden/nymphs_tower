json = require "json"
Level = class("Level", Entity)

function Level:initialize(paths)
    Entity.initialize(self, 0, 0)
    self.types = {"walls"}

    self.entities = {}

    -- Figure out total size of map
    local standardWidth
    local totalHeight = 0
    for _, path in pairs(paths) do
        local raw = love.filesystem.read(path)
        local jsonData = json.decode(raw)
        standardWidth = jsonData["width"]
        totalHeight = totalHeight + jsonData["height"]
    end

    self.mask = Grid:new(self, standardWidth, totalHeight, 16, 16)

    local uniqueId = 0
    local heightOffset = 0

    for _, path in pairs(paths) do
        local levelEntities = {}
        local raw = love.filesystem.read(path)
        local jsonData = json.decode(raw)
        for _, layer in pairs(jsonData["layers"]) do
            -- set mask
            if layer["name"] == "walls" then
                local columns = math.ceil(jsonData["width"] / 16)
                local rows = math.ceil(jsonData["height"] / 16)
                for tileX = 1, columns do
                    for tileY = 1, rows do
                        local tileHeightOffset = math.ceil(heightOffset / 16)
                        self.mask:setTile(
                            tileX, tileY + tileHeightOffset, layer["grid2D"][tileY][tileX] == "1"
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
                        player.y = player.y + 11 + heightOffset
                        self.entities["player"] = player
                    elseif entity["name"] == "acid" then
                        local acid = Acid:new(
                            entity["x"], entity["y"],
                            entity["width"], entity["height"],
                            entity["values"]["acid_id"], entity["values"]["rise_speed"],
                            uniqueId
                        )
                        table.insert(levelEntities, acid)
                        uniqueId = uniqueId + 1
                    elseif entity["name"] == "acid_trigger" then
                        local acidTrigger = AcidTrigger:new(
                            entity["x"], entity["y"],
                            entity["width"], entity["height"],
                            entity["values"]["acid_id"], entity["values"]["rise_to"],
                            uniqueId
                        )
                        table.insert(levelEntities, acidTrigger)
                        uniqueId = uniqueId + 1
                    elseif entity["name"] == "gun" then
                        local gun = Gun:new(entity["x"], entity["y"], uniqueId)
                        table.insert(levelEntities, gun)
                        uniqueId = uniqueId + 1
                    elseif entity["name"] == "harmonica" then
                        local harmonica = Harmonica:new(
                            entity["x"], entity["y"], uniqueId
                        )
                        table.insert(levelEntities, harmonica)
                        uniqueId = uniqueId + 1
                    elseif entity["name"] == "gravity_belt" then
                        local gravityBelt = GravityBelt:new(
                            entity["x"], entity["y"], uniqueId
                        )
                        table.insert(levelEntities, gravityBelt)
                        uniqueId = uniqueId + 1
                    elseif entity["name"] == "hazard_suit" then
                        local hazardSuit = HazardSuit:new(
                            entity["x"], entity["y"], uniqueId
                        )
                        table.insert(levelEntities, hazardSuit)
                        uniqueId = uniqueId + 1
                    elseif entity["name"] == "health_upgrade" then
                        local healthUpgrade = HealthUpgrade:new(
                            entity["x"], entity["y"], uniqueId
                        )
                        table.insert(levelEntities, healthUpgrade)
                        uniqueId = uniqueId + 1
                    elseif entity["name"] == "fuel_upgrade" then
                        local fuelUpgrade = FuelUpgrade:new(
                            entity["x"], entity["y"],
                            entity["values"]["add_flag"], uniqueId
                        )
                        table.insert(levelEntities, fuelUpgrade)
                        uniqueId = uniqueId + 1
                    elseif entity["name"] == "block" then
                        local block = Block:new(entity["x"], entity["y"])
                        table.insert(levelEntities, block)
                    elseif entity["name"] == "pig" then
                        local pig = Pig:new(entity["x"], entity["y"])
                        table.insert(levelEntities, pig)
                    elseif entity["name"] == "wizard" then
                        local wizard = Wizard:new(
                            entity["x"], entity["y"], entity["nodes"]
                        )
                        table.insert(levelEntities, wizard)
                    elseif entity["name"] == "miku" then
                        local miku = Miku:new(
                            entity["x"], entity["y"], entity["nodes"]
                        )
                        table.insert(levelEntities, miku)
                    elseif entity["name"] == "finalboss" then
                        local finalBoss = FinalBoss:new(
                            entity["x"], entity["y"], entity["nodes"]
                        )
                        table.insert(levelEntities, finalBoss)
                    elseif entity["name"] == "secret_boss" then
                        local secretBoss = SecretBoss:new(
                            entity["x"], entity["y"], entity["nodes"]
                        )
                        table.insert(levelEntities, secretBoss)
                    elseif entity["name"] == "lock" then
                        local lock = Lock:new(
                            entity["x"], entity["y"],
                            entity["width"], entity["height"],
                            entity["values"]["flag"]
                        )
                        table.insert(levelEntities, lock)
                    elseif entity["name"] == "flag_trigger" then
                        local flagTrigger = FlagTrigger:new(
                            entity["x"], entity["y"],
                            entity["width"], entity["height"],
                            entity["values"]["flag"],
                            entity["values"]["require_flag"]
                        )
                        table.insert(levelEntities, flagTrigger)
                    elseif entity["name"] == "checkpoint" then
                        local checkpoint = Checkpoint:new(entity["x"], entity["y"])
                        table.insert(levelEntities, checkpoint)
                    elseif entity["name"] == "spike_floor" then
                        local spikeFloor = Spike:new(
                            entity["x"], entity["y"], entity["width"], 16, "floor"
                        )
                        table.insert(levelEntities, spikeFloor)
                    elseif entity["name"] == "spike_ceiling" then
                        local spikeCeiling = Spike:new(
                            entity["x"], entity["y"], entity["width"], 16, "ceiling"
                        )
                        table.insert(levelEntities, spikeCeiling)
                    elseif entity["name"] == "spike_left" then
                        local spikeLeft = Spike:new(
                            entity["x"], entity["y"], 16, entity["height"], "left"
                        )
                        table.insert(levelEntities, spikeLeft)
                    elseif entity["name"] == "spike_right" then
                        local spikeRight = Spike:new(
                            entity["x"], entity["y"], 16, entity["height"], "right"
                        )
                        table.insert(levelEntities, spikeRight)
                    elseif entity["name"] == "star" then
                        local star = Star:new(
                            entity["x"] + 2, entity["y"] + 2,
                            entity["values"]["headingX"],
                            entity["values"]["headingY"]
                        )
                        table.insert(levelEntities, star)
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
                        table.insert(levelEntities, cameraZone)
                    end
                end
            end
        end
        for _, entity in ipairs(levelEntities) do
            entity.y = entity.y + heightOffset
            table.insert(self.entities, entity)
        end
        heightOffset = heightOffset + jsonData["height"]
    end

    -- set graphic
    self.graphic = Tilemap:new("tiles.png", 16, 16)
    for tileY = 1, self.mask.rows do
        for tileX = 1, self.mask.columns do
            if self.mask:getTile(tileX, tileY) then
                -- tile placing logic
                if (
                    not self.mask:getTile(tileX + 1, tileY)
                    and not self.mask:getTile(tileX - 1, tileY)
                    and not self.mask:getTile(tileX, tileY + 1)
                    and not self.mask:getTile(tileX, tileY - 1)
                ) then
                    -- standalone 1x1
                    self.graphic:setTile(tileX, tileY, 23)
                elseif (
                    self.mask:getTile(tileX + 1, tileY)
                    and not self.mask:getTile(tileX - 1, tileY)
                    and not self.mask:getTile(tileX, tileY + 1)
                    and not self.mask:getTile(tileX, tileY - 1)
                ) then
                    -- left edge of 1-tall
                    self.graphic:setTile(tileX, tileY, 14)
                elseif (
                    self.mask:getTile(tileX - 1, tileY)
                    and not self.mask:getTile(tileX + 1, tileY)
                    and not self.mask:getTile(tileX, tileY + 1)
                    and not self.mask:getTile(tileX, tileY - 1)
                ) then
                    -- right edge of 1-tall
                    self.graphic:setTile(tileX, tileY, 16)
                elseif (
                    self.mask:getTile(tileX, tileY + 1)
                    and not self.mask:getTile(tileX - 1, tileY)
                    and not self.mask:getTile(tileX + 1, tileY)
                    and not self.mask:getTile(tileX, tileY - 1)
                ) then
                    -- top edge of 1-wide
                    self.graphic:setTile(tileX, tileY, 13)
                elseif (
                    self.mask:getTile(tileX, tileY - 1)
                    and not self.mask:getTile(tileX - 1, tileY)
                    and not self.mask:getTile(tileX + 1, tileY)
                    and not self.mask:getTile(tileX, tileY + 1)
                ) then
                    -- bottom edge of 1-wide
                    self.graphic:setTile(tileX, tileY, 29)
                elseif (
                    self.mask:getTile(tileX + 1, tileY)
                    and self.mask:getTile(tileX - 1, tileY)
                    and not self.mask:getTile(tileX, tileY + 1)
                    and not self.mask:getTile(tileX, tileY - 1)
                ) then
                    -- middle of 1-tall
                    self.graphic:setTile(tileX, tileY, 15)
                elseif (
                    not self.mask:getTile(tileX + 1, tileY)
                    and not self.mask:getTile(tileX - 1, tileY)
                    and self.mask:getTile(tileX, tileY + 1)
                    and self.mask:getTile(tileX, tileY - 1)
                ) then
                    -- middle of 1-wide
                    self.graphic:setTile(tileX, tileY, 21)
                elseif (
                    self.mask:getTile(tileX + 1, tileY)
                    and self.mask:getTile(tileX, tileY + 1)
                    and not self.mask:getTile(tileX - 1, tileY)
                    and not self.mask:getTile(tileX, tileY - 1)
                ) then
                    -- top left corner
                    self.graphic:setTile(tileX, tileY, 1)
                elseif (
                    self.mask:getTile(tileX - 1, tileY)
                    and self.mask:getTile(tileX, tileY + 1)
                    and not self.mask:getTile(tileX + 1, tileY)
                    and not self.mask:getTile(tileX, tileY - 1)
                ) then
                    -- top right corner
                    self.graphic:setTile(tileX, tileY, 4)
                elseif (
                    self.mask:getTile(tileX + 1, tileY)
                    and self.mask:getTile(tileX, tileY - 1)
                    and not self.mask:getTile(tileX - 1, tileY)
                    and not self.mask:getTile(tileX, tileY + 1)
                ) then
                    -- bottom left corner
                    self.graphic:setTile(tileX, tileY, 25)
                elseif (
                    self.mask:getTile(tileX - 1, tileY)
                    and self.mask:getTile(tileX, tileY - 1)
                    and not self.mask:getTile(tileX + 1, tileY)
                    and not self.mask:getTile(tileX, tileY + 1)
                ) then
                    -- bottom right corner
                    self.graphic:setTile(tileX, tileY, 28)
                elseif (
                    self.mask:getTile(tileX - 1, tileY)
                    and self.mask:getTile(tileX + 1, tileY)
                    and self.mask:getTile(tileX, tileY + 1)
                    and self.mask:getTile(tileX, tileY - 1)
                    and not self.mask:getTile(tileX - 1, tileY - 1)
                ) then
                    -- top left inner corner
                    self.graphic:setTile(tileX, tileY, 10)
                elseif (
                    self.mask:getTile(tileX - 1, tileY)
                    and self.mask:getTile(tileX + 1, tileY)
                    and self.mask:getTile(tileX, tileY + 1)
                    and self.mask:getTile(tileX, tileY - 1)
                    and not self.mask:getTile(tileX + 1, tileY - 1)
                ) then
                    -- top right inner corner
                    self.graphic:setTile(tileX, tileY, 11)
                elseif (
                    self.mask:getTile(tileX - 1, tileY)
                    and self.mask:getTile(tileX + 1, tileY)
                    and self.mask:getTile(tileX, tileY + 1)
                    and self.mask:getTile(tileX, tileY - 1)
                    and not self.mask:getTile(tileX - 1, tileY + 1)
                ) then
                    -- bottom left inner corner
                    self.graphic:setTile(tileX, tileY, 18)
                elseif (
                    self.mask:getTile(tileX - 1, tileY)
                    and self.mask:getTile(tileX + 1, tileY)
                    and self.mask:getTile(tileX, tileY + 1)
                    and self.mask:getTile(tileX, tileY - 1)
                    and not self.mask:getTile(tileX + 1, tileY + 1)
                ) then
                    -- bottom right inner corner
                    self.graphic:setTile(tileX, tileY, 19)
                elseif (
                    self.mask:getTile(tileX - 1, tileY)
                    and self.mask:getTile(tileX + 1, tileY)
                    and self.mask:getTile(tileX, tileY + 1)
                    and not self.mask:getTile(tileX, tileY - 1)
                ) then
                    -- top edge
                    self.graphic:setTile(tileX, tileY, 2)
                elseif (
                    self.mask:getTile(tileX - 1, tileY)
                    and self.mask:getTile(tileX + 1, tileY)
                    and not self.mask:getTile(tileX, tileY + 1)
                    and self.mask:getTile(tileX, tileY - 1)
                ) then
                    -- bottom edge
                    self.graphic:setTile(tileX, tileY, 26)
                elseif (
                    not self.mask:getTile(tileX - 1, tileY)
                    and self.mask:getTile(tileX + 1, tileY)
                    and self.mask:getTile(tileX, tileY + 1)
                    and self.mask:getTile(tileX, tileY - 1)
                ) then
                    -- left edge
                    self.graphic:setTile(tileX, tileY, 9)
                elseif (
                    self.mask:getTile(tileX - 1, tileY)
                    and not self.mask:getTile(tileX + 1, tileY)
                    and self.mask:getTile(tileX, tileY + 1)
                    and self.mask:getTile(tileX, tileY - 1)
                ) then
                    -- right edge
                    self.graphic:setTile(tileX, tileY, 12)
                else
                    -- center
                    self.graphic:setTile(tileX, tileY, 5)
                end
            end
        end
    end

    self.layer = -3
end

function Level:update(dt)
end
