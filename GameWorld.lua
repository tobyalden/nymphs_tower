GameWorld = class("GameWorld", World)

GameWorld.static.CAMERA_SPEED = 0.15
GameWorld.static.CAMERA_BUFFER_X = 60

function GameWorld:initialize()
    World.initialize(self)
    local level = Level:new("level.json")
    self:add(level)
    for name, entity in pairs(level.entities) do
        self:add(entity)
        if name == "player" then
            self.player = entity
        end
    end
    local ui = UI:new()
    self:add(ui)
    local background = Background:new()
    self:add(background)
    self:loadSfx({"longmusic.ogg"})
    self.sfx["longmusic"]:loop()
    self.cameraVelocity = Vector:new(0, 0)
    self.camera.x = self.player.x + self.player.mask.width / 2 - gameWidth / 4
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

local cameraTargetX
local lerpTimer = 0
local previousPlayerFlipX = false
function GameWorld:update(dt)
    previousPlayerFlipX = self.player.graphic.flipX
    World.update(self, dt)
    lerpTimer = lerpTimer + dt
    local cameraZone = self:getCurrentCameraZone()
    local cameraBoundLeft = (
        self.player.x + self.player.mask.width / 2 - gameWidth / 2
        - GameWorld.CAMERA_BUFFER_X
    )
    local cameraBoundRight = (
        self.player.x + self.player.mask.width / 2 - gameWidth / 2
        + GameWorld.CAMERA_BUFFER_X
    )
    if cameraZones then
        cameraBoundLeft = math.max(cameraZone.x, cameraBoundLeft)
        cameraBoundRight = math.min(
            cameraZone.x + cameraZone.mask.width - gameWidth, cameraBoundRight
        )
    end
    if not cameraTargetX then
        cameraTargetX = cameraBoundRight
    end
    if self.player.velocity.x > 0 then
        cameraTargetX = cameraBoundRight
    elseif self.player.velocity.x < 0 then
        cameraTargetX = cameraBoundLeft
    end
    if previousPlayerFlipX ~= self.player.graphic.flipX then
        lerpTimer = 0
    end
    self.camera.x = math.lerp(
        self.camera.x,
        cameraTargetX,
        math.min(lerpTimer * GameWorld.CAMERA_SPEED, 1)
    )
    if cameraZone then
        self.camera.x = math.clamp(
            self.camera.x,
            cameraZone.x,
            cameraZone.x + cameraZone.mask.width - gameWidth
        )
    end
end
