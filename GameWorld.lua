GameWorld = class("GameWorld", World)

GameWorld.static.CAMERA_SPEED = 1.5
GameWorld.static.CAMERA_BUFFER_X = 60
GameWorld.static.CAMERA_BUFFER_Y = 30

local currentCheckpoint = nil
local saveData = require("saveData")

function GameWorld:initialize()
    World.initialize(self)
    self.flags = {}
    self.level = Level:new("level.json")
    self:add(self.level)
    for name, entity in pairs(self.level.entities) do
        self:add(entity)
        if name == "player" then
            self.player = entity
            if currentCheckpoint then
                self:loadGame()
            end
        end
    end
    self.ui = UI:new()
    self:add(self.ui)
    local background = Background:new()
    self:add(background)
    --self:loadSfx({"longmusic.ogg"})
    --self.sfx["longmusic"]:loop()
    self.cameraVelocity = Vector:new(0, 0)
    self.camera.x = self.player.x + self.player.mask.width / 2 - gameWidth / 4
    self.cameraStartX = self.camera.x
    self.lerpTimerX = 0
    self.previousPlayerFlipX = false
    self.previousCameraZone = nil
    self.currentBoss = nil
    self.isHardMode = true
    self.curtain = Curtain:new()
    self:add(self.curtain)
    self.curtain:addTween(Alarm:new(1, function()
        self.curtain:fadeOut()
    end), true)
end

function GameWorld:saveGame(saveX, saveY)
    currentCheckpoint = {}
    currentCheckpoint["saveX"] = saveX
    currentCheckpoint["saveY"] = saveY

    if self.player.graphic.flipX then
        currentCheckpoint["flipX"] = "true"
    end
    if self.player.hasGun then
        currentCheckpoint["hasGun"] = "true"
    end

    currentCheckpoint["healthUpgrades"] = self.player.healthUpgrades
    currentCheckpoint["fuelUpgrades"] = self.player.fuelUpgrades
    saveData.save(currentCheckpoint, "currentCheckpoint")

    local currentFlags = {}
    for flag, _ in pairs(self.flags) do
        table.insert(currentFlags, flag)
    end
    saveData.save(currentFlags, "currentFlags")

    self.player:restoreHealth()
end

function GameWorld:loadGame()
    local loadedCheckpoint = saveData.load("currentCheckpoint")
    self.player.x = loadedCheckpoint["saveX"]
    self.player.y = loadedCheckpoint["saveY"]
    self.player.graphic.flipX = loadedCheckpoint["flipX"]
    self.player.hasGun = loadedCheckpoint["hasGun"]
    self.player.healthUpgrades = loadedCheckpoint["healthUpgrades"]
    self.player.fuelUpgrades = loadedCheckpoint["fuelUpgrades"]

    self.player.graphic.flipX = currentCheckpoint["flipX"] == "true"
    self.player.hasGun = currentCheckpoint["hasGun"] == "true"

    self.flags = {}
    for _, flag in pairs(saveData.load("currentFlags")) do
        self:addFlag(flag)
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
    self:updateCamera(dt)
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
