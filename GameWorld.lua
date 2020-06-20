GameWorld = class("GameWorld", World)

--local player

function GameWorld:initialize()
    World.initialize(self)
    player = Player:new(30, 30, true)
    self:add(player)
    local level = Level:new("level.json")
    self:add(level)
    for _, entity in pairs(level.entities) do
        self:add(entity)
    end
    local ui = UI:new()
    self:add(ui)
    local background = Background:new()
    self:add(background)
    self:loadSfx({"longmusic.ogg"})
    self.sfx["longmusic"]:loop()
end

function GameWorld:update(dt)
    World.update(self, dt)
    self.camera.x = player.x + player.mask.width / 2 - gameWidth / 2
    --self.camera.y = player.y + player.mask.height /2 - gameHeight / 2
end
