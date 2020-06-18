GameWorld = class("GameWorld", World)

local wasDKeyDown = false
local player

function GameWorld:initialize()
    World.initialize(self)
    player = Player:new(30, 30, true)
    self:add(player)
    local level = Level:new("level.json")
    self:add(level)
    local ui = UI:new()
    self:add(ui)
    local background = Background:new()
    self:add(background)
    self:loadSfx({"longmusic.ogg"})
    self.sfx["longmusic"]:loop()
end

function GameWorld:update(dt)
    if love.keyboard.isDown("d") and not wasDKeyDown then
        ammo.world = GameWorld:new()
    end
    wasDKeyDown = love.keyboard.isDown("d")
    World.update(self, dt)
    self.camera.x = player.x + player.mask.width / 2 - gameWidth / 2
    self.camera.y = player.y + player.mask.height /2 - gameHeight / 2
    --self.camera.x = player.x - gameWidth / 2
    --self.camera.y = player.y - gameHeight / 2
end
