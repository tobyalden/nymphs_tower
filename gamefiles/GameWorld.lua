GameWorld = class("GameWorld", World)

GameWorld.static.CAMERA_SPEED = 1.5
GameWorld.static.CAMERA_BUFFER_X = 60
GameWorld.static.CAMERA_BUFFER_Y = 30
GameWorld.static.MUSIC_FADE_SPEED = 0.2
GameWorld.static.ALL_INDOORS_MUSIC = {
    "explore1", "explore2", "explore3", "explore4", "silence"
}

function GameWorld:initialize()
    World.initialize(self)
    self.flags = {}
    self.itemIds = {}
    self.level = Level:new({
        "level_1.json",
        "level_2.json",
        "level_3.json",
        "level_4.json"
        --"level.json"
    })
    self:add(self.level)
    for name, entity in pairs(self.level.entities) do
        if name == "player" then
            self.player = entity
            if saveData.exists("currentCheckpoint") then
                --self:loadGame()
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
                end
            end
        end
    end
    self.ui = UI:new()
    self:add(self.ui)
    local cave = Background:new("background.png", 2, 1, 0, true)
    self:add(cave)
    local clouds = Background:new("clouds.png", 2, 0.2, 50, false)
    self:add(clouds)
    local fog = Background:new("fog.png", 1, 0.4, 100, false)
    self:add(fog)
    self:loadSfx({
        "insideambience.wav", "outsideambience.wav",
        "explore1.ogg", "explore2.ogg", "explore3.ogg", "explore4.ogg",
        "boss1.ogg", "boss2.ogg", "boss3.ogg",
        "outside.ogg", "silence.wav"
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
    self.isHardMode = false
    self.curtain = Curtain:new()
    self:add(self.curtain)
    self.curtain:addTween(Alarm:new(1, function()
        self.curtain:fadeOut()
    end), true)
end

function GameWorld:clearSave()
    saveData.clear("currentCheckpoint")
    saveData.clear("currentFlags")
    saveData.clear("itemIds")
    saveData.clear("acidLevels")
end

function GameWorld:saveGame(saveX, saveY)
    local currentCheckpoint = {}
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
    --print('saving acid levels: '..inspect(acidLevels))
    saveData.save(acidLevels, "acidLevels")
end

function GameWorld:loadGame()
    local loadedCheckpoint = saveData.load("currentCheckpoint")
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

    self.flags = {}
    for _, flag in pairs(saveData.load("currentFlags")) do
        self:addFlag(flag)
    end

    self.itemIds = saveData.load("itemIds")
    --print('loaded itemIds: ' .. inspect(self.itemIds))

    local acidLevels = saveData.load("acidLevels")
    --print('loading acid levels: '..inspect(acidLevels))
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

function GameWorld:hasFlag(flag)
    return self.flags[flag] ~= false and self.flags[flag] ~= nil
end

function GameWorld:addFlag(flag)
    if flag == "" then return end
    print('adding flag ' .. flag)
    self.flags[flag] = true
end

function GameWorld:removeFlag(flag)
    print('removing flag ' .. flag)
    local element = self.flags[flag]
    self.flags[flag] = nil
end

function GameWorld:pauseLevel()
    for v in self._updates:iterate() do
        v.paused = true
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
    for _, cameraZone in pairs(cameraZones) do
        if (
            playerCenter.x >= cameraZone.x
            and playerCenter.x < cameraZone.x + cameraZone.mask.width
            and playerCenter.y >= cameraZone.y
            and playerCenter.y < cameraZone.y + cameraZone.mask.height
        ) then
            return cameraZone
        end
    end
end

function GameWorld:onDeath()
    self.curtain:fadeOut()
    self:doSequence({
        {1, function() self.curtain:fadeIn() end},
        {4, function() ammo.world = GameWorld:new() end}
    })
end

function GameWorld:update(dt)
    self.previousPlayerFlipX = self.player.graphic.flipX
    self.previousCameraZone = self:getCurrentCameraZone()
    World.update(self, dt)
    self:updateSounds(dt)
    self:updateCamera(dt)
    if input.pressed("reset") then
        self:clearSave()
        ammo.world = GameWorld:new()
    end
end

function GameWorld:updateSounds(dt)
    -- update ambience
    if self.player:isInside() then
        self.sfx["insideambience"]:setVolume(
            math.approach(self.sfx["insideambience"]:getVolume(), 1, dt)
        )
        self.sfx["outsideambience"]:setVolume(
            math.approach(self.sfx["outsideambience"]:getVolume(), 0, dt)
        )
    else
        self.sfx["insideambience"]:setVolume(
            math.approach(self.sfx["insideambience"]:getVolume(), 0, dt)
        )
        self.sfx["outsideambience"]:setVolume(
            math.approach(self.sfx["outsideambience"]:getVolume(), 1, dt)
        )
    end

    -- update music
    if self.player:isInside() then
        local musicName = self.player:collide(
            self.player.x, self.player.y, {"inside"}
        )[1].musicName
        self.sfx[musicName]:fadeIn(dt * GameWorld.MUSIC_FADE_SPEED)
        self.sfx["outside"]:fadeOut(dt * GameWorld.MUSIC_FADE_SPEED)
    else
        self.sfx["outside"]:fadeIn(dt * GameWorld.MUSIC_FADE_SPEED)
        for _, v in ipairs(GameWorld.ALL_INDOORS_MUSIC) do
            self.sfx[v]:fadeOut(dt * GameWorld.MUSIC_FADE_SPEED)
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
    end

    self.camera.x = math.round(self.camera.x)
    self.camera.y = math.round(self.camera.y)
end
