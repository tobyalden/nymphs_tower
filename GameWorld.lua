GameWorld = class("GameWorld", World)

GameWorld.static.CAMERA_SPEED = 0.15
GameWorld.static.CAMERA_BUFFER_X = 60
GameWorld.static.CAMERA_BUFFER_Y = 30

local currentCheckpoint = nil

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
    self.lerpTimerX = 0
    self.previousPlayerFlipX = false
    self.previousCameraZone = nil
    self.currentBoss = nil
    print(inspect(self.flags))
end

function GameWorld:saveGame(saveX, saveY)
    currentCheckpoint = {}
    currentCheckpoint["saveX"] = saveX
    currentCheckpoint["saveY"] = saveY
    currentCheckpoint["flipX"] = self.player.graphic.flipX
    currentCheckpoint["hasGun"] = self.player.hasGun
    currentCheckpoint["healthUpgrades"] = self.player.healthUpgrades
    currentCheckpoint["fuelUpgrades"] = self.player.fuelUpgrades
    currentCheckpoint["flags"] = {}
    for flag, _ in pairs(self.flags) do
        currentCheckpoint["flags"][flag] = true
    end
    self.player:restoreHealth()
end

function GameWorld:loadGame()
    self.player.x = currentCheckpoint["saveX"]
    self.player.y = currentCheckpoint["saveY"]
    self.player.graphic.flipX = currentCheckpoint["flipX"]
    self.player.hasGun = currentCheckpoint["hasGun"]
    self.player.healthUpgrades = currentCheckpoint["healthUpgrades"]
    self.player.fuelUpgrades = currentCheckpoint["fuelUpgrades"]
    self.player:restoreHealth()
    self.flags = {}
    for flag, _ in pairs(currentCheckpoint["flags"]) do
        self:addFlag(flag)
    end
end

function GameWorld:hasFlag(flag)
    return self.flags[flag] ~= false and self.flags[flag] ~= nil
end

function GameWorld:addFlag(flag)
    print('adding flag ' .. flag)
    self.flags[flag] = true
end

function GameWorld:removeFlag(flag)
    print('removing flag ' .. flag)
    local element = self.flags[flag]
    self.flags[flag] = nil
end

function GameWorld:pauseLevel()
    for _, entity in pairs(self.level.entities) do
        entity.paused = true
    end
end

function GameWorld:unpauseLevel()
    for _, entity in pairs(self.level.entities) do
        entity.paused = false
    end
end

function GameWorld:getCurrentCameraZone()
    local cameraZones = self.player:collide(
        self.player.x, self.player.y, {"camera_zone"}
    )
    local playerCenter = Vector:new(
        self.player.x + self.player.mask.width / 2,
        self.player.y + self.player.mask.height / 2
    )
    for _, cameraZone in pairs(cameraZones) do
        if (
            playerCenter.x > cameraZone.x
            and playerCenter.x < cameraZone.x + cameraZone.mask.width
        ) then
            return cameraZone
        end
    end
end

function GameWorld:onDeath()
    ammo.world = GameWorld:new()
end

function GameWorld:update(dt)
    local wasCameraOnTargetX = self.camera.x == self.cameraTargetX

    self.previousPlayerFlipX = self.player.graphic.flipX
    self.previousCameraZone = self:getCurrentCameraZone()
    World.update(self, dt)
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
    if not self.cameraTargetX then
        self.cameraTargetX = cameraBoundRight
    end
    if self.player.velocity.x > 0 then
        self.cameraTargetX = cameraBoundRight
    elseif self.player.velocity.x < 0 then
        self.cameraTargetX = cameraBoundLeft
    end
    --self.cameraTargetX = math.floor(self.cameraTargetX)
    local canSnapToTargetX = true
    if (
        self.previousPlayerFlipX ~= self.player.graphic.flipX
        or self.previousCameraZone ~= cameraZone
    ) then
        self.lerpTimerX = 0
        canSnapToTargetX = false
    end
    --if wasCameraOnTargetX and canSnapToTargetX then
        --self.camera.x = self.cameraTargetX
    --else
    self.camera.x = math.lerp(
        self.camera.x,
        self.cameraTargetX,
        math.min(self.lerpTimerX * GameWorld.CAMERA_SPEED, 1)
    )
    --end
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

    --self.camera.x = math.floor(self.camera.x)
    --self.camera.y = math.floor(self.camera.y)
end
