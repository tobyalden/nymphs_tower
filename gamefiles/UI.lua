UI = class("UI", Entity)
UI.static.MAP_SCROLL_SPEED = 100

local healthBar
local healthText
local fuelBar
local fuelText
local messageBar
local message
local gravityBelt
local hazardSuit
local harmonica
local timerText
local map
local mapIcon
local compassIcon
local crownIcon

local playerPing
local bossPings
local itemPings

local mapBorder = 8

function UI:initialize(level)
    Entity.initialize(self)
    self.types = {"ui"}
    healthBar = Sprite:new("healthbar.png")
    healthText = Text:new("HP", 12)
    fuelBar = Sprite:new("fuelbar.png")
    fuelText = Text:new("FUEL", 12)
    healthBar.offsetX = 5
    healthBar.offsetY = 5
    healthBar.alpha = 0.5
    healthText.offsetX = 5
    healthText.offsetY = 2
    fuelBar.offsetX = 5
    fuelBar.offsetY = 20
    fuelBar.alpha = 0.75
    fuelText.offsetX = 5
    fuelText.offsetY = 17

    gravityBelt = Sprite:new("gravitybelticon.png", 16, 16)
    gravityBelt:add("off", {1})
    gravityBelt:add("on", {2})
    gravityBelt.offsetY = fuelBar.offsetY + 10

    hazardSuit = Sprite:new("hazardsuiticon.png")
    hazardSuit.offsetY = fuelBar.offsetY + 10

    harmonica = Sprite:new("harmonicaicon.png")
    harmonica.offsetY = fuelBar.offsetY + 10

    mapIcon = Sprite:new("mapicon.png")
    mapIcon.offsetY = fuelBar.offsetY + 10

    compassIcon = Sprite:new("compassicon.png")
    compassIcon.offsetY = fuelBar.offsetY + 10

    crownIcon = Sprite:new("crownicon.png")
    crownIcon.offsetY = fuelBar.offsetY + 10

    playerPing = Sprite:new("playerping.png")
    bossPings = {}
    itemPings = {}
    for i = 1, 5 do
        table.insert(bossPings, Sprite:new("bossping.png"))
    end
    for i = 1, 50 do
        table.insert(itemPings, Sprite:new("itemping.png"))
    end

    allPings = {playerPing}
    for _, v in pairs(bossPings) do
        table.insert(allPings, v)
    end
    for _, v in pairs(itemPings) do
        table.insert(allPings, v)
    end

    self.pingTimer = self:addTween(Alarm:new(
        1,
        function()
            -- do nothing
        end,
        "looping"
    ))

    messageBar = Sprite:new("messagebar.png")
    messageBar.offsetX = 10
    messageBar.offsetY = 180 - 24 - 9 + 9

    message = Text:new("YOU GOT THE RAYGUN", 12, "arial.ttf", {1, 1, 1}, 300, "center")
    message.offsetX = 10 + 3
    message.offsetY = 180 - 24 - 10 + 9 + 1

    bossBar = Sprite:new("bossbar.png")
    bossBar.offsetX = 10
    bossBar.offsetY = 180 - 16
    bossBar.alpha = 0.5

    bossName = Text:new("BOSS", 12, "arial.ttf", {1, 1, 1}, 300, "left")
    bossName.offsetX = 10
    bossName.offsetY = 180 - 19

    timerText = Text:new("0.000", 12, "arial.ttf", {0, 1, 1}, 300, "right")
    timerText.offsetX = 15
    timerText.offsetY = 1
    if GameWorld.isSpeedrunMode then
        timerText.alpha = 0.5
    else
        timerText.alpha = 0
    end

    map = Tilemap:new("maptiles.png", 1, 1)
    for tileY = 1, level.mask.rows + mapBorder * 2 do
        for tileX = 1, level.mask.columns + mapBorder * 2 do
            if GameWorld.static.isSecondTower then
                if self:isTileOnTornMap(level, tileX, tileY) then
                    map:setTile(tileX, tileY, 1)
                end
            else
                map:setTile(tileX, tileY, 1)
            end
        end
    end
    for tileY = 1, level.mask.rows do
        for tileX = 1, level.mask.columns do
            if not GameWorld.static.isSecondTower or self:isTileOnTornMap(level, tileX + mapBorder, tileY + mapBorder) then
                if level.mask:getTile(tileX, tileY) then
                    map:setTile(tileX + mapBorder, tileY + mapBorder, 1)
                else
                    map:setTile(tileX + mapBorder, tileY + mapBorder, 2)
                end
            end
        end
    end
    map.scaleX = 0.5
    map.scaleY = 0.5

    local allGraphics = {
        healthBar, fuelBar, healthText, fuelText, messageBar, message, bossBar,
        bossName, gravityBelt, hazardSuit, harmonica, timerText, mapIcon,
        compassIcon, crownIcon, map
    }
    for _, v in pairs(allPings) do
        table.insert(allGraphics, v)
    end
    self.graphic = Graphiclist:new(allGraphics)
    self.layer = -99
    self.graphic.scroll = 0
    self:hideMessage()
    self.currentSequence = {}
end

function UI:isTileOnTornMap(level, tileX, tileY)
    return (
        --tileX * 1.3 + tileY * 1.5 >= (level.mask.rows + level.mask.columns) / 3
        tileX * 0.4 + (level.mask.rows - tileY) * 2 >= (level.mask.rows + level.mask.columns) / 5
    )
end

function UI:update(dt)
    local items = {}
    if self.world.player.hasGravityBelt then
        gravityBelt.alpha = 1
        if self.world.player.isGravityBeltEquipped then
            gravityBelt:play("on")
        else
            gravityBelt:play("off")
        end
        table.insert(items, gravityBelt)
    else
        gravityBelt.alpha = 0
    end
    if self.world.player.hasMap then
        mapIcon.alpha = 1
        table.insert(items, mapIcon)
    else
        mapIcon.alpha = 0
    end
    if self.world.player.hasCompass then
        compassIcon.alpha = 1
        table.insert(items, compassIcon)
    else
        compassIcon.alpha = 0
    end
    if self.world.player.hasHazardSuit then
        hazardSuit.alpha = 1
        table.insert(items, hazardSuit)
    else
        hazardSuit.alpha = 0
    end
    if self.world.player.hasHarmonica then
        harmonica.alpha = 1
        table.insert(items, harmonica)
    else
        harmonica.alpha = 0
    end
    if self.world.player.hasCrown then
        crownIcon.alpha = 1
        table.insert(items, crownIcon)
    else
        crownIcon.alpha = 0
    end
    for i, item in ipairs(items) do
        item.offsetX = 5 + 16 * (i - 1)
    end

    if self.world.currentBoss then
        bossBar.alpha = 0.75
        bossName.alpha = 1
        bossBar.scaleX = (
            self.world.currentBoss.health / self.world.currentBoss.startingHealth
        )
        bossName:setText(self.world.currentBoss.displayName)
    else
        bossBar.alpha = 0
        bossName.alpha = 0
    end
    fuelBar.scaleX = (
        self.world.player.fuel / Player.STARTING_FUEL
    ) / 2
    healthBar.scaleX = (
        self.world.player.health / Player.STARTING_HEALTH
    ) / 2
    --timerText:setText(string.format("%.2f", self.world.timer))
    timerText:setText(formatTime(self.world.timer))

    for _, v in pairs(allPings) do
        v.alpha = map.alpha
        if self.world.player.isLookingAtMap then
            playerPing.alpha = 1 - self.pingTimer:getPercentComplete()
        end
    end

    if self.world.player.isLookingAtMap then
        if self.world.player.hasMap then
            map.alpha = 1
        end
        if input.down("up") then
            map.offsetY = map.offsetY + UI.MAP_SCROLL_SPEED * dt
        elseif input.down("down") then
            map.offsetY = map.offsetY - UI.MAP_SCROLL_SPEED * dt
        end
        map.offsetY = math.clamp(
            map.offsetY,
            -self.world.level.mask.rows * map.scaleY + 180 - 180 / 4,
            180 / 4
        )
        map.offsetY = math.round(map.offsetY)

        if not self.pingTimer.active then
            self.pingTimer:start(1)
        end

        self:updateCompass()
    else
        map.offsetX = 320 / 2 - self.world.level.mask.columns * map.scaleX / 2
        if self.world.player.hasCompass then
            map.offsetY = -self.world.player.y / 16 * map.scaleY + 180 / 2
        end
        map.alpha = 0
        self.pingTimer.active = false
        playerPing.alpha = 0
        for i = 1, 5 do
            bossPings[i].alpha = 0
        end
        for i = 1, 50 do
            itemPings[i].alpha = 0
        end
    end

    Entity.update(self, dt)
end

function UI:updateCompass()
    if not self.world.player.hasCompass then
        playerPing.alpha = 0
        for i = 1, 5 do
            bossPings[i].alpha = 0
        end
        for i = 1, 50 do
            itemPings[i].alpha = 0
        end
        return
    end

    self:updatePing(playerPing, self.world.player)
    for i = 1, 5 do
        if self.world.level.bosses[i] then
            local boss = self.world.level.bosses[i]
            local defeatedFlag
            if GameWorld.static.isSecondTower then
                defeatedFlag = boss.flag .. '_defeated_again'
            else
                defeatedFlag = boss.flag .. '_defeated'
            end
            if self.world:hasFlag(defeatedFlag) then
                bossPings[i].alpha = 0
            else
                bossPings[i].alpha = 1 - self.pingTimer:getPercentComplete()
                self:updatePing(bossPings[i], boss)
            end
        else
            bossPings[i].alpha = 0
        end
    end
    if self.world.level.items[1] then
        for i = 1, 50 do
            local item = self.world.level.items[i]
            if not item or self.world:hasItem(item.uniqueId) then
                itemPings[i].alpha = 0
            else
                itemPings[i].alpha = 1
                self:updatePing(itemPings[i], item)
            end
        end
    end
end

function UI:updatePing(ping, entity)
    local tileX = math.round(entity.x / 16)
    local tileY = math.round(entity.y / 16)
    ping.offsetX = map.offsetX + tileX * map.scaleX + 3
    ping.offsetY = map.offsetY + tileY * map.scaleY + 3
end

function UI:showMessageSequence(messageSequence, messageHang)
    messageHang = messageHang or 3
    for _, timer in pairs(self.currentSequence) do
        timer.active = false
    end
    self.currentSequence = {}
    local totalTime = 0
    local sequenceSteps = {}
    for i, message in ipairs(messageSequence) do
        local messageDelay = 0.25
        local messageTotal = messageHang + messageDelay * 2
        table.insert(sequenceSteps, {
            messageDelay * (i - 1) + (i - 1) * messageTotal,
            function()
                self:showMessage(message)
            end}
        )
        table.insert(sequenceSteps, {
            messageDelay * (i - 1) + messageHang + (i - 1) * messageTotal,
            function()
                self:hideMessage()
            end}
        )
        totalTime = messageDelay + messageHang + (i - 1) * messageTotal
    end
    self.currentSequence = self.world:doSequence(sequenceSteps)
    return totalTime
end

function UI:showMessage(messageText)
    message.alpha = 1
    messageBar.alpha = 1
    message:setText(messageText)
end

function UI:hideMessage(messageText)
    message.alpha = 0
    messageBar.alpha = 0
end
