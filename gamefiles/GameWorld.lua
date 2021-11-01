GameWorld = class("GameWorld", World)

GameWorld.static.CAMERA_SPEED = 1.5
GameWorld.static.CAMERA_BUFFER_X = 60
GameWorld.static.CAMERA_BUFFER_Y = 30
GameWorld.static.MUSIC_FADE_SPEED = 0.2
GameWorld.static.ALL_INDOORS_MUSIC = {
    "explore1", "explore2", "explore3", "explore4", "explore5", "explore1remix", "explore2remix", "explore3remix", "silence", "toxic_waste", "top"
}

GameWorld.static.ALL_BOSS_MUSIC = {
    pig = "boss1",
    wizard = "boss1",
    miku = "boss1",
    finalboss = "boss2",
    secret_boss = "boss3andintro",
    pig_remix = "boss1remix",
    wizard_remix = "boss1remix",
    miku_remix = "boss1remix",
    finalboss_remix = "boss2remix",
    secret_boss_remix = "boss4"
}

GameWorld.static.SECOND_TOWER = {
    "bonus0.json",
    "bonus1.json",
    "bonus2.json",
    "bonus3.json",
    "bonus4.json"
}

GameWorld.static.FIRST_TOWER = {
    "level_1.json",
    "level_2.json",
    "level_3.json",
    "level_4.json"
}

GameWorld.static.isSecondTower = false

GameWorld.static.DEBUG_MODE = true

function GameWorld:initialize(levelStack, saveOnEntry)
    pauseTweens = true
    love.math.setRandomSeed(1)
    World.initialize(self)

    self.timer = 0
    self.flags = {}
    self.itemIds = {}
    self.level = Level:new(levelStack)
    self:add(self.level)
    local startX, startY
    local isStartOfGame = true
    self.isTeleporting = false
    for name, entity in pairs(self.level.entities) do
        if name == "player" then
            self.player = entity
            startX = entity.x
            startY = entity.y
            if saveData.exists("currentCheckpoint") then
                isStartOfGame = false
                self:loadGame()
            end
            if self:hasFlag("teleporting_back") then
                self:removeFlag("teleporting_back")
                startX = 2530
                startY = 4891
            end
            self:add(entity)
        end
    end
    for name, entity in pairs(self.level.entities) do
        if name ~= "player" then
            if not entity.uniqueId then
                self:add(entity)
            else
                local isCollected = false
                for _, itemId in pairs(self.itemIds) do
                    if itemId == entity.uniqueId then
                        isCollected = true
                        break
                    end
                end
                if not isCollected then
                    self:add(entity)
                else
                    for i, item in ipairs(self.level.items) do
                        if item.uniqueId == entity.uniqueId then
                            table.remove(self.level.items, i)
                        end
                    end
                end
            end
        end
    end
    self.ui = UI:new(self.level)
    self:add(self.ui)
    local cave
    if GameWorld.static.isSecondTower then
        cave = Background:new("background_light2.png", 3, 1, 0, true)
    else
        cave = Background:new("background_light.png", 3, 1, 0, true)
    end
    self:add(cave)
    local light = Background:new("shadows.png", 2, 0.6, 2, true)
    self:add(light)
    local tileset = ""
    if GameWorld.static.isSecondTower then
        tileset = "2"
    end
    local clouds = Background:new("clouds" .. tileset .. ".png", 30, 0.2, 50, false)
    self:add(clouds)
    local fog = Background:new("fog.png", 20, 0.4, 100, false)
    self:add(fog)
    local fog2 = Background:new("fog.png", 10, 0.2, 70, false)
    self:add(fog2)
    self:loadSfx({
        -- ambience
        "insideambience.wav", "outsideambience.wav",
        -- inside music
        "explore1.ogg", "explore2.ogg", "explore3.ogg", "explore4.ogg", "explore5.ogg",
        "explore1remix.ogg", "explore2remix.ogg", "explore3remix.ogg", "silence.ogg",
        "toxic_waste.ogg", "top.ogg",
        -- boss music
        "boss1.ogg", "boss2.ogg", "boss3andintro.ogg", "boss4.ogg", "boss1remix.ogg", "boss2remix.ogg", "boss3remix.ogg",
        -- outside
        "outside.ogg", "outside_remix.ogg",
        -- misc
        "silence.wav", "restart.wav", "teleport.wav"
    })
    self.sfx["insideambience"]:loop()
    self.sfx["outsideambience"]:loop()
    self.cameraVelocity = Vector:new(0, 0)
    self.camera.x = self.player.x + self.player.mask.width / 2 - gameWidth / 4
    self.cameraStartX = self.camera.x
    self.lerpTimerX = 0
    self.previousPlayerFlipX = false
    self.previousCameraZone = nil
    self.currentBoss = nil
    self.currentMusic = nil
    self.isHardMode = GameWorld.static.isSecondTower
    self.curtain = Curtain:new()
    self:add(self.curtain)
    self.curtain:addTween(Alarm:new(3, function()
        self.curtain:fadeOut()
        self.curtain:addTween(Alarm:new(2, function()
            self.player.canMove = true
            if isStartOfGame then
                -- do nothing
            end
        end), true)
    end), true)
    if saveOnEntry then
        self.player.x = startX
        self.player.y = startY
        self:saveGame(self.player.x, self.player.y)
    end
    pauseTweens = false
end

function GameWorld:teleportToSecondTower()
    self.isTeleporting = true
    self.curtain:setMessage("TRAVELING TO HOME WORLD...")
    self.player.canMove = false
    self:doSequence({
        {1, function() self.curtain:fadeIn() end},
        {4, function()
            self.sfx["teleport"]:play()
            GameWorld.static.isSecondTower = true
            self.player:loseItems()
            self:saveGame(self.player.x, self.player.y)
            ammo.world = GameWorld:new(GameWorld.SECOND_TOWER, true)
        end}
    })
end

function GameWorld:teleportToFirstTower()
    self.isTeleporting = true
    self.curtain:setMessage("TRAVELING TO OUTPOST...")
    self.player.canMove = false
    self:doSequence({
        {1, function() self.curtain:fadeIn() end},
        {4, function()
            self.sfx["teleport"]:play()
            GameWorld.static.isSecondTower = false
            self.player.hasHarmonica = false
            self:addFlag("harmonica_broken")
            self:addFlag("teleporting_back")
            self:saveGame(self.player.x, self.player.y)
            ammo.world = GameWorld:new(GameWorld.FIRST_TOWER, true)
        end}
    })
end

function GameWorld:saveGame(saveX, saveY)
    local currentCheckpoint = {}
    if GameWorld.static.isSecondTower == true then
        currentCheckpoint["isSecondTower"] = "true"
    end

    currentCheckpoint["saveX"] = saveX
    currentCheckpoint["saveY"] = saveY

    if self.player.graphic.flipX then
        currentCheckpoint["flipX"] = "true"
    end
    if self.player.hasGun then
        currentCheckpoint["hasGun"] = "true"
    end
    if self.player.hasGravityBelt then
        currentCheckpoint["hasGravityBelt"] = "true"
    end
    if self.player.isGravityBeltEquipped then
        currentCheckpoint["isGravityBeltEquipped"] = "true"
    end
    if self.player.hasHarmonica then
        currentCheckpoint["hasHarmonica"] = "true"
    end
    if self.player.hasHazardSuit then
        currentCheckpoint["hasHazardSuit"] = "true"
    end

    currentCheckpoint["time"] = self.timer

    currentCheckpoint["healthUpgrades"] = self.player.healthUpgrades
    currentCheckpoint["fuelUpgrades"] = self.player.fuelUpgrades
    saveData.save(currentCheckpoint, "currentCheckpoint")

    local currentFlags = {}
    for flag, _ in pairs(self.flags) do
        table.insert(currentFlags, flag)
    end
    saveData.save(currentFlags, "currentFlags")

    saveData.save(self.itemIds, "itemIds")

    self.player:restoreHealth()
    self.player:restoreFuel()

    local acidLevels = {}
    for _, entity in pairs(self.level.entities) do
        local isAcid = false
        for _, entityType in pairs(entity.types) do
            if entityType == "acid" then
                isAcid = true
                break
            end
        end
        if isAcid then
            acidLevels[entity.uniqueId] = entity.riseTo
        end
    end
    saveData.save(acidLevels, "acidLevels")
end

function GameWorld:loadGame()
    local loadedCheckpoint = saveData.load("currentCheckpoint")
    GameWorld.static.isSecondTower = loadedCheckpoint["isSecondTower"] == "true"
    self.player.x = loadedCheckpoint["saveX"]
    self.player.y = loadedCheckpoint["saveY"]
    self.player.graphic.flipX = loadedCheckpoint["flipX"]
    self.player.hasGun = loadedCheckpoint["hasGun"]
    self.player.healthUpgrades = loadedCheckpoint["healthUpgrades"]
    self.player.fuelUpgrades = loadedCheckpoint["fuelUpgrades"]

    self.player.hasGravityBelt = loadedCheckpoint["hasGravityBelt"] == "true"
    self.player.isGravityBeltEquipped = loadedCheckpoint["isGravityBeltEquipped"] == "true"
    self.player.graphic.flipX = loadedCheckpoint["flipX"] == "true"
    self.player.hasGun = loadedCheckpoint["hasGun"] == "true"
    self.player.hasHarmonica = loadedCheckpoint["hasHarmonica"] == "true"
    self.player.hasHazardSuit = loadedCheckpoint["hasHazardSuit"] == "true"

    self.timer = loadedCheckpoint["time"]

    self.flags = {}
    for _, flag in pairs(saveData.load("currentFlags")) do
        self:addFlag(flag)
    end

    self.itemIds = saveData.load("itemIds")

    local acidLevels = saveData.load("acidLevels")
    for _, entity in pairs(self.level.entities) do
        local isAcid = false
        for _, entityType in pairs(entity.types) do
            if entityType == "acid" then
                isAcid = true
                break
            end
        end
        if isAcid then
            for uniqueId, riseTo in pairs(acidLevels) do
                if entity.uniqueId == uniqueId then
                    entity.riseTo = riseTo
                end
            end
        end
    end

    self.player:restoreHealth()
end

function GameWorld:hasItem(uniqueId)
    for _, itemId in pairs(self.itemIds) do
        if itemId == uniqueId then
            return true
        end
    end
    return false
end

function GameWorld:hasFlag(flag)
    return self.flags[flag] ~= false and self.flags[flag] ~= nil
end

function GameWorld:addFlag(flag)
    if flag == "" then return end
    self.flags[flag] = true
end

function GameWorld:removeFlag(flag)
    local element = self.flags[flag]
    self.flags[flag] = nil
end

function GameWorld:pauseLevel()
    for v in self._updates:iterate() do
        if v.types and not v:hasType("ui") then 
            v.paused = true
        end
    end
end

function GameWorld:unpauseLevel()
    for v in self._updates:iterate() do
        v.paused = false
    end
end

function GameWorld:getCurrentCameraZone()
    local cameraZones = self.player:collide(
        self.player.x, self.player.y, {"camera_zone"}
    )
    local playerCenter = self.player:getMaskCenter()
    local collidedCameraZones = {}
    for _, cameraZone in pairs(cameraZones) do
        if (
            playerCenter.x >= cameraZone.x
            and playerCenter.x < cameraZone.x + cameraZone.mask.width
            and playerCenter.y >= cameraZone.y
            and playerCenter.y < cameraZone.y + cameraZone.mask.height
        ) then
            table.insert(collidedCameraZones, cameraZone)
        end
    end
    local smallestCameraZone = nil
    for _, cameraZone in pairs(collidedCameraZones) do
        if not smallestCameraZone or cameraZone:getSize() < smallestCameraZone:getSize() then
            smallestCameraZone = cameraZone
        end
    end
    return smallestCameraZone
end

function GameWorld:onDeath()
    local tower = GameWorld.FIRST_TOWER
    if GameWorld.static.isSecondTower then
        tower = GameWorld.SECOND_TOWER
    end
    self:doSequence({
        {1, function()
            self.curtain:setMessage("RETURNING TO CHECKPOINT...")
            self.curtain:fadeIn()
        end},
        {4, function() ammo.world = GameWorld:new(tower) end}
    })
end

function GameWorld:update(dt)
    if self.player.canMove then
        self.timer = self.timer + dt
    end
    self.previousPlayerFlipX = self.player.graphic.flipX
    self.previousCameraZone = self:getCurrentCameraZone()
    World.update(self, dt)
    self:updateSounds(dt)
    self:updateCamera(dt)
    if input.pressed("reset") and GameWorld.isSpeedrunMode then
        self.curtain:setMessage("RESETTING...")
        self.curtain:fadeInInstantly()
        clearSave()
        for _, v in pairs(self.sfx) do
            v:stopLoops()
        end
        self.sfx["restart"]:play()
        local tower = GameWorld.FIRST_TOWER
        GameWorld.static.isSecondTower = false
        if input.down("shift") and GameWorld.DEBUG_MODE then
            GameWorld.static.isSecondTower = true
            tower = GameWorld.SECOND_TOWER
        end
        self:doSequence({
            {0.1, function()
                ammo.world = GameWorld:new(tower)
            end}
        })
    end
    if GameWorld.DEBUG_MODE then
        if input.pressed("debug_print") then
            if self.isHardMode then
                print('is hard mode')
            else
                print("is not hard mode")
            end
            print("player coordinates: (" .. self.player.x .. ", " .. self.player.y .. ")")
        end
        if input.pressed("debug_teleport") then
            self:teleportToSecondTower()
        end
        if input.pressed("debug_allitems") then
            self.player:giveAllItems()
        end
    end
end

function GameWorld:updateSounds(dt)
    local towerSuffix = ""
    if GameWorld.static.isSecondTower then
        towerSuffix = "_remix"
    end

    -- update ambience
    if self.player:isInside() then
        self.sfx["insideambience"]:fadeIn(dt)
        self.sfx["outsideambience"]:fadeOut(dt)
    else
        self.sfx["insideambience"]:fadeOut(dt)
        self.sfx["outsideambience"]:fadeIn(dt)
    end

    -- update music
    if self.player.isDead or self.isTeleporting then
        for _, v in pairs(self.sfx) do
            v:stopLoops()
        end
    elseif self.currentBoss ~= nil then
        self.currentMusic = self.sfx[GameWorld.ALL_BOSS_MUSIC[self.currentBoss.flag .. towerSuffix]]
        self.currentMusic:fadeIn(dt, 1)
        self.sfx["outside" .. towerSuffix]:fadeOut(dt)
        for _, v in ipairs(GameWorld.ALL_INDOORS_MUSIC) do
            self.sfx[v]:fadeOut(dt)
        end
    else
        for _, v in pairs(GameWorld.ALL_BOSS_MUSIC) do
            self.sfx[v]:fadeOut(dt)
        end
        if self.player:isInside() then
            local musicName = self.player:collide(
                self.player.x, self.player.y, {"inside"}
            )[1].musicName
            self.currentMusic = self.sfx[musicName]
            self.currentMusic:fadeIn(dt * GameWorld.MUSIC_FADE_SPEED, 1)
            self.sfx["outside" .. towerSuffix]:fadeOut(dt * GameWorld.MUSIC_FADE_SPEED)
        elseif self.player:isAtTop() then
            self.currentMusic = self.sfx["top"]
            self.currentMusic:fadeIn(dt * GameWorld.MUSIC_FADE_SPEED / 4, 1)
            self.sfx["outside" .. towerSuffix]:fadeOut(dt * GameWorld.MUSIC_FADE_SPEED / 4)
        else
            self.currentMusic = self.sfx["outside" .. towerSuffix]
            self.currentMusic:fadeIn(dt * GameWorld.MUSIC_FADE_SPEED)
            for _, v in ipairs(GameWorld.ALL_INDOORS_MUSIC) do
                self.sfx[v]:fadeOut(dt * GameWorld.MUSIC_FADE_SPEED)
            end
        end
    end

    if self.player.isPlayingHarmonica then
        if self.currentMusic ~= nil then
            self.currentMusic:fadeOut(dt * GameWorld.MUSIC_FADE_SPEED * 2, false)
        end
    end
end

function GameWorld:updateCamera(dt)
    self.lerpTimerX = self.lerpTimerX + dt

    local cameraZone = self:getCurrentCameraZone()

    local cameraBoundLeft = (
        self.player.x + self.player.mask.width / 2 - gameWidth / 2
        - GameWorld.CAMERA_BUFFER_X
    )
    local cameraBoundRight = (
        self.player.x + self.player.mask.width / 2 - gameWidth / 2
        + GameWorld.CAMERA_BUFFER_X
    )
    if cameraZone then
        cameraBoundLeft = math.max(cameraZone.x, cameraBoundLeft)
        cameraBoundRight = math.min(
            cameraZone.x + cameraZone.mask.width - gameWidth, cameraBoundRight
        )
    end
    if not self.player.graphic.flipX then
        self.cameraTargetX = cameraBoundRight
    else
        self.cameraTargetX = cameraBoundLeft
    end
    if (
        self.previousPlayerFlipX ~= self.player.graphic.flipX
        or self.previousCameraZone ~= cameraZone
    ) then
        self.lerpTimerX = 0
        self.cameraStartX = self.camera.x
    end
    local linearLerp = math.min(self.lerpTimerX * GameWorld.CAMERA_SPEED, 1)
    self.camera.x = math.lerp(
        self.cameraStartX,
        self.cameraTargetX,
        math.sin(linearLerp * math.pi / 2)
    )
    if cameraZone then
        self.camera.x = math.clamp(
            self.camera.x,
            cameraZone.x,
            cameraZone.x + cameraZone.mask.width - gameWidth
        )
    end

    self.camera.y = self.player.y + self.player.mask.width - gameHeight / 2
    if cameraZone then
        self.camera.y = math.clamp(
            self.camera.y,
            cameraZone.y,
            cameraZone.y + cameraZone.mask.height - gameHeight
        )
        -- print(
        --     'x is ' .. cameraZone.x ..
        --     ', y is ' .. cameraZone.y ..
        --     ', width is ' .. cameraZone.mask.width ..
        --     ', height is ' .. cameraZone.mask.height .. 
        --     ', size is ' .. cameraZone:getSize()
        -- )
    else
        -- print('no cam zone found')
    end

    self.camera.x = math.round(self.camera.x)
    self.camera.y = math.round(self.camera.y)
end
