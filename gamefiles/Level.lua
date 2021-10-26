json = require "json"
Level = class("Level", Entity)

function Level:initialize(paths, onlyItems)
    onlyItems = onlyItems or false

    Entity.initialize(self, 0, 0)
    self.types = {"walls"}

    self.entities = {}
    self.bosses = {}
    self.items = {}
    self.spikeIndex = {}

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
    if string.find(paths[1], "bonus") then
        uniqueId = 10000
    end
    heightOffset = 0

    for _, path in pairs(paths) do
        local levelEntities = {}
        local raw = love.filesystem.read(path)
        local jsonData = json.decode(raw)
        local sliceHeight
        for _, layer in pairs(jsonData["layers"]) do
            -- set mask
            if layer["name"] == "walls" then
                local columns = math.ceil(jsonData["width"] / 16)
                local rows = math.ceil(jsonData["height"] / 16)
                sliceHeight = rows * 16
                if not onlyItems then
                    for tileX = 1, columns do
                        for tileY = 1, rows do
                            local tileHeightOffset = math.ceil(heightOffset / 16)
                            self.mask:setTile(
                                tileX, tileY + tileHeightOffset, layer["grid2D"][tileY][tileX] == "1"
                            )
                        end
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
                        table.insert(self.items, gun)
                        uniqueId = uniqueId + 1
                    elseif entity["name"] == "map" then
                        local map = Map:new(entity["x"], entity["y"], uniqueId)
                        table.insert(levelEntities, map)
                        table.insert(self.items, map)
                        uniqueId = uniqueId + 1
                    elseif entity["name"] == "compass" then
                        local compass = Compass:new(entity["x"], entity["y"], uniqueId)
                        table.insert(levelEntities, compass)
                        table.insert(self.items, compass)
                        uniqueId = uniqueId + 1
                    elseif entity["name"] == "crown" then
                        local crown = Crown:new(entity["x"], entity["y"], uniqueId)
                        table.insert(levelEntities, crown)
                        table.insert(self.items, crown)
                        uniqueId = uniqueId + 1
                    elseif entity["name"] == "harmonica" then
                        local harmonica = Harmonica:new(
                            entity["x"], entity["y"], uniqueId
                        )
                        table.insert(levelEntities, harmonica)
                        table.insert(self.items, harmonica)
                        uniqueId = uniqueId + 1
                    elseif entity["name"] == "gravity_belt" then
                        local gravityBelt = GravityBelt:new(
                            entity["x"], entity["y"], uniqueId
                        )
                        table.insert(levelEntities, gravityBelt)
                        table.insert(self.items, gravityBelt)
                        uniqueId = uniqueId + 1
                    elseif entity["name"] == "hazard_suit" then
                        local hazardSuit = HazardSuit:new(
                            entity["x"], entity["y"], uniqueId
                        )
                        table.insert(levelEntities, hazardSuit)
                        table.insert(self.items, hazardSuit)
                        uniqueId = uniqueId + 1
                    elseif entity["name"] == "health_upgrade" then
                        local healthUpgrade = HealthUpgrade:new(
                            entity["x"], entity["y"], uniqueId
                        )
                        table.insert(levelEntities, healthUpgrade)
                        table.insert(self.items, healthUpgrade)
                        uniqueId = uniqueId + 1
                    elseif entity["name"] == "fuel_upgrade" then
                        local fuelUpgrade = FuelUpgrade:new(
                            entity["x"], entity["y"],
                            entity["values"]["add_flag"], uniqueId
                        )
                        table.insert(levelEntities, fuelUpgrade)
                        table.insert(self.items, fuelUpgrade)
                        uniqueId = uniqueId + 1
                    elseif entity["name"] == "decoration" then
                        local decoration = Decoration:new(
                            entity["x"], entity["y"],
                            entity["values"]["path"],
                            entity["values"]["layer"]
                        )
                        table.insert(levelEntities, decoration)
                    elseif entity["name"] == "boat" then
                        local boat = Boat:new(entity["x"], entity["y"], false)
                        table.insert(levelEntities, boat)
                        local boatBackground = Boat:new(entity["x"], entity["y"], true)
                        table.insert(levelEntities, boatBackground)
                    elseif entity["name"] == "block" then
                        local block = Block:new(entity["x"], entity["y"])
                        table.insert(levelEntities, block)
                    elseif entity["name"] == "tutorial" then
                        local tutorial = Tutorial:new(
                            entity["x"], entity["y"],
                            entity["values"]["text"],
                            entity["values"]["require_flag"]
                        )
                        table.insert(levelEntities, tutorial)
                    elseif entity["name"] == "pig" then
                        local pig = Pig:new(entity["x"], entity["y"] + 5)
                        table.insert(levelEntities, pig)
                        table.insert(self.bosses, pig)
                    elseif entity["name"] == "wizard" then
                        local wizard = Wizard:new(
                            entity["x"], entity["y"], entity["nodes"]
                        )
                        table.insert(levelEntities, wizard)
                        table.insert(self.bosses, wizard)
                    elseif entity["name"] == "miku" then
                        local miku = Miku:new(
                            entity["x"], entity["y"], entity["nodes"]
                        )
                        table.insert(levelEntities, miku)
                        table.insert(self.bosses, miku)
                    elseif entity["name"] == "finalboss" then
                        local finalBoss = FinalBoss:new(
                            entity["x"], entity["y"], entity["nodes"]
                        )
                        table.insert(levelEntities, finalBoss)
                        table.insert(self.bosses, finalBoss)
                    elseif entity["name"] == "secret_boss" then
                        local secretBoss = SecretBoss:new(
                            entity["x"], entity["y"], entity["nodes"]
                        )
                        table.insert(levelEntities, secretBoss)
                        table.insert(self.bosses, secretBoss)
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

            -- load camera zones
            if layer["name"] == "sound_zones" then
                for _, entity in pairs(layer["entities"]) do
                    if entity["name"] == "inside" then
                        local inside = Inside:new(
                            entity["x"], entity["y"],
                            entity["width"], entity["height"],
                            entity["values"]["music"]
                        )
                        table.insert(levelEntities, inside)
                    end
                end
            end

        end
        for _, entity in ipairs(levelEntities) do
            entity.y = entity.y + heightOffset
            if entity.class == Spike then
                self:indexSpike(entity)
            elseif entity.class == Acid then
                entity.originalY = entity.originalY + heightOffset
            elseif (
                entity.class == Wizard
                or entity.class == Miku
                or entity.class == FinalBoss
                or entity.class == SecretBoss
            ) then
                for _, node in ipairs(entity.nodes) do
                    node.y = node.y + heightOffset
                end
                if entity.class == SecretBoss then
                    entity.highestNodeY = entity.highestNodeY + heightOffset
                end
            end
            table.insert(self.entities, entity)
        end
        heightOffset = heightOffset + sliceHeight
        -- TODO: This may be bugged in how it messes with Acid.y but not Acid.originalY after the fact
    end

    -- set graphic
    local allTopEdgeTiles = generateNonrepeatingSequence({2, 3, 7}, self.mask.columns)
    local allBottomEdgeTiles = generateNonrepeatingSequence({26, 27, 32}, self.mask.columns)
    local allLeftEdgeTiles = generateNonrepeatingSequence({9, 17, 6}, self.mask.rows)
    local allRightEdgeTiles = generateNonrepeatingSequence({12, 20, 8}, self.mask.rows)
    local tileset = "tiles.png"
    if GameWorld.static.isSecondTower then
        tileset = "tiles2.png"
    end
    self.graphic = Tilemap:new(tileset, 16, 16)
    for tileY = 1, self.mask.rows do
        for tileX = 1, self.mask.columns do
            if self.mask:getTile(tileX, tileY) then
                -- tile placing logic
                if (
                    not self:getTileOrSpike(tileX + 1, tileY, {'left'})
                    and not self:getTileOrSpike(tileX - 1, tileY, {'right'})
                    and not self:getTileOrSpike(tileX, tileY + 1, {'ceiling'})
                    and not self:getTileOrSpike(tileX, tileY - 1, {'floor'})
                ) then
                    -- standalone 1x1
                    self.graphic:setTile(tileX, tileY, 23)
                elseif (
                    self:getTileOrSpike(tileX + 1, tileY, {'left'})
                    and not self:getTileOrSpike(tileX - 1, tileY, {'right'})
                    and not self:getTileOrSpike(tileX, tileY + 1, {'ceiling'})
                    and not self:getTileOrSpike(tileX, tileY - 1, {'floor'})
                ) then
                    -- left edge of 1-tall
                    self.graphic:setTile(tileX, tileY, 14)
                elseif (
                    self:getTileOrSpike(tileX - 1, tileY, {'right'})
                    and not self:getTileOrSpike(tileX + 1, tileY, {'left'})
                    and not self:getTileOrSpike(tileX, tileY + 1, {'ceiling'})
                    and not self:getTileOrSpike(tileX, tileY - 1, {'floor'})
                ) then
                    -- right edge of 1-tall
                    self.graphic:setTile(tileX, tileY, 16)
                elseif (
                    self:getTileOrSpike(tileX, tileY + 1, {'ceiling'})
                    and not self:getTileOrSpike(tileX - 1, tileY, {'right'})
                    and not self:getTileOrSpike(tileX + 1, tileY, {'left'})
                    and not self:getTileOrSpike(tileX, tileY - 1, {'floor'})
                ) then
                    -- top edge of 1-wide
                    self.graphic:setTile(tileX, tileY, 13)
                elseif (
                    self:getTileOrSpike(tileX, tileY - 1, {'floor'})
                    and not self:getTileOrSpike(tileX - 1, tileY, {'right'})
                    and not self:getTileOrSpike(tileX + 1, tileY, {'left'})
                    and not self:getTileOrSpike(tileX, tileY + 1, {'ceiling'})
                ) then
                    -- bottom edge of 1-wide
                    self.graphic:setTile(tileX, tileY, 29)
                elseif (
                    self:getTileOrSpike(tileX + 1, tileY, {'left'})
                    and self:getTileOrSpike(tileX - 1, tileY, {'right'})
                    and not self:getTileOrSpike(tileX, tileY + 1, {'ceiling'})
                    and not self:getTileOrSpike(tileX, tileY - 1, {'floor'})
                ) then
                    -- middle of 1-tall
                    self.graphic:setTile(tileX, tileY, 15)
                elseif (
                    not self:getTileOrSpike(tileX + 1, tileY, {'left'})
                    and not self:getTileOrSpike(tileX - 1, tileY, {'right'})
                    and self:getTileOrSpike(tileX, tileY + 1, {'ceiling'})
                    and self:getTileOrSpike(tileX, tileY - 1, {'floor'})
                ) then
                    -- middle of 1-wide
                    self.graphic:setTile(tileX, tileY, 21)
                elseif (
                    self:getTileOrSpike(tileX + 1, tileY, {'left'})
                    and self:getTileOrSpike(tileX, tileY + 1, {'ceiling'})
                    and not self:getTileOrSpike(tileX - 1, tileY, {'right'})
                    and not self:getTileOrSpike(tileX, tileY - 1, {'floor'})
                ) then
                    -- top left corner
                    self.graphic:setTile(tileX, tileY, 1)
                elseif (
                    self:getTileOrSpike(tileX - 1, tileY, {'right'})
                    and self:getTileOrSpike(tileX, tileY + 1, {'ceiling'})
                    and not self:getTileOrSpike(tileX + 1, tileY, {'left'})
                    and not self:getTileOrSpike(tileX, tileY - 1, {'floor'})
                ) then
                    -- top right corner
                    self.graphic:setTile(tileX, tileY, 4)
                elseif (
                    self:getTileOrSpike(tileX + 1, tileY, {'left'})
                    and self:getTileOrSpike(tileX, tileY - 1, {'floor'})
                    and not self:getTileOrSpike(tileX - 1, tileY, {'right'})
                    and not self:getTileOrSpike(tileX, tileY + 1, {'ceiling'})
                ) then
                    -- bottom left corner
                    self.graphic:setTile(tileX, tileY, 25)
                elseif (
                    self:getTileOrSpike(tileX - 1, tileY, {'right'})
                    and self:getTileOrSpike(tileX, tileY - 1, {'floor'})
                    and not self:getTileOrSpike(tileX + 1, tileY, {'left'})
                    and not self:getTileOrSpike(tileX, tileY + 1, {'ceiling'})
                ) then
                    -- bottom right corner
                    self.graphic:setTile(tileX, tileY, 28)
                elseif (
                    self:getTileOrSpike(tileX - 1, tileY, {'right'})
                    and self:getTileOrSpike(tileX + 1, tileY, {'left'})
                    and self:getTileOrSpike(tileX, tileY + 1, {'ceiling'})
                    and self:getTileOrSpike(tileX, tileY - 1, {'floor'})
                    and not self:getTileOrSpike(tileX - 1, tileY - 1, {'floor', 'right'})
                    and self:getTileOrSpike(tileX + 1, tileY - 1)
                    and self:getTileOrSpike(tileX - 1, tileY + 1)
                    and self:getTileOrSpike(tileX + 1, tileY + 1)
                ) then
                    -- top left inner corner
                    self.graphic:setTile(tileX, tileY, 10)
                elseif (
                    self:getTileOrSpike(tileX - 1, tileY, {'right'})
                    and self:getTileOrSpike(tileX + 1, tileY, {'left'})
                    and self:getTileOrSpike(tileX, tileY + 1, {'ceiling'})
                    and self:getTileOrSpike(tileX, tileY - 1, {'floor'})
                    and not self:getTileOrSpike(tileX + 1, tileY - 1, {'floor', 'left'})
                    and self:getTileOrSpike(tileX - 1, tileY - 1)
                    and self:getTileOrSpike(tileX - 1, tileY + 1)
                    and self:getTileOrSpike(tileX + 1, tileY + 1)
                ) then
                    -- top right inner corner
                    self.graphic:setTile(tileX, tileY, 11)
                elseif (
                    self:getTileOrSpike(tileX - 1, tileY, {'right'})
                    and self:getTileOrSpike(tileX + 1, tileY, {'left'})
                    and self:getTileOrSpike(tileX, tileY + 1, {'ceiling'})
                    and self:getTileOrSpike(tileX, tileY - 1, {'floor'})
                    and not self:getTileOrSpike(tileX - 1, tileY + 1, {'ceiling', 'right'})
                    and self:getTileOrSpike(tileX - 1, tileY - 1)
                    and self:getTileOrSpike(tileX + 1, tileY - 1)
                    and self:getTileOrSpike(tileX + 1, tileY + 1)
                ) then
                    -- bottom left inner corner
                    self.graphic:setTile(tileX, tileY, 18)
                elseif (
                    self:getTileOrSpike(tileX - 1, tileY, {'right'})
                    and self:getTileOrSpike(tileX + 1, tileY, {'left'})
                    and self:getTileOrSpike(tileX, tileY + 1, {'ceiling'})
                    and self:getTileOrSpike(tileX, tileY - 1, {'floor'})
                    and not self:getTileOrSpike(tileX + 1, tileY + 1, {'ceiling', 'left'})
                    and self:getTileOrSpike(tileX - 1, tileY - 1)
                    and self:getTileOrSpike(tileX + 1, tileY - 1)
                    and self:getTileOrSpike(tileX - 1, tileY + 1)
                ) then
                    -- bottom right inner corner
                    self.graphic:setTile(tileX, tileY, 19)
                elseif (
                    self:getTileOrSpike(tileX - 1, tileY, {'right'})
                    and self:getTileOrSpike(tileX + 1, tileY, {'left'})
                    and self:getTileOrSpike(tileX, tileY + 1, {'ceiling'})
                    and not self:getTileOrSpike(tileX, tileY - 1, {'floor'})
                ) then
                    -- top edge
                    self.graphic:setTile(tileX, tileY, allTopEdgeTiles[tileX])
                elseif (
                    self:getTileOrSpike(tileX - 1, tileY, {'right'})
                    and self:getTileOrSpike(tileX + 1, tileY, {'left'})
                    and not self:getTileOrSpike(tileX, tileY + 1, {'ceiling'})
                    and self:getTileOrSpike(tileX, tileY - 1, {'floor'})
                ) then
                    -- bottom edge
                    self.graphic:setTile(tileX, tileY, allBottomEdgeTiles[tileX])
                elseif (
                    not self:getTileOrSpike(tileX - 1, tileY, {'right'})
                    and self:getTileOrSpike(tileX + 1, tileY, {'left'})
                    and self:getTileOrSpike(tileX, tileY + 1, {'ceiling'})
                    and self:getTileOrSpike(tileX, tileY - 1, {'floor'})
                ) then
                    -- left edge
                    self.graphic:setTile(tileX, tileY, allLeftEdgeTiles[tileY])
                elseif (
                    self:getTileOrSpike(tileX - 1, tileY, {'right'})
                    and not self:getTileOrSpike(tileX + 1, tileY, {'left'})
                    and self:getTileOrSpike(tileX, tileY + 1, {'ceiling'})
                    and self:getTileOrSpike(tileX, tileY - 1, {'floor'})
                ) then
                    -- right edge
                    self.graphic:setTile(tileX, tileY, allRightEdgeTiles[tileY])
                else
                    -- center
                    local allCenterTiles = {5, 5, 5, 5, 22, 30, 31}
                    if GameWorld.static.isSecondTower and (tileY % 7 > 3 or tileX % 7 < 4) then
                        allCenterTiles = {
                            33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44
                        }
                    end
                    self.graphic:setTile(tileX, tileY, allCenterTiles[love.math.random(#allCenterTiles)])
                end
            end
        end
    end
    self.layer = -4
end

function Level:indexSpike(spike)
    local tileX = math.round(spike.x / 16)
    local tileY = math.round(spike.y / 16)
    for subX = 1, math.ceil(spike.mask.width / 16) do
        for subY = 1, math.ceil(spike.mask.height / 16) do
            self.spikeIndex[
                tostring(tileX + subX)
                .. '-'
                .. tostring(tileY + subY)
                .. '-'
                .. spike.facing
            ] = true
        end
    end
end

function Level:getTileOrSpike(tileX, tileY, facings)
    facings = facings or {}
    if self.mask:getTile(tileX, tileY) then
        return true
    end
    for _, facing in ipairs(facings) do
        if self.spikeIndex[tileX .. '-' .. tileY .. '-' .. facing] then
            return true
        end
    end
    return false
end

function generateNonrepeatingSequence(numbersInSequence, length)
    local sequence = {}
    for i = 1, length do
        local numberToAdd = numbersInSequence[love.math.random(#numbersInSequence)]
        while numberToAdd == sequence[#sequence] do
            numberToAdd = numbersInSequence[love.math.random(#numbersInSequence)]
        end
        table.insert(sequence, numberToAdd)
    end
    return sequence
end
