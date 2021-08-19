EndScreen = class("EndScreen", World)

--MainMenu.static.CAMERA_SPEED = 1.5

function EndScreen:initialize()
    World.initialize(self)
    local level1, level2 = Level:new(GameWorld.FIRST_TOWER, true), Level:new(GameWorld.SECOND_TOWER, true)
    local totalNumberOfItems = #level1.items + #level2.items
    local collectedItems = 0
    if saveData.exists("itemIds") then
        collectedItems = #saveData.load("itemIds")
    end
    local completionPercentage = tostring(math.floor(collectedItems / totalNumberOfItems * 100)) .. "%"
    local message = Text:new(
        "\n\nTime: 1:23:45\nCompletion: " .. completionPercentage, 16, "arial.ttf", {1, 1, 1}, 320, "center"
    )
    self:addGraphic(Sprite:new("endscreen.png"))
    self:addGraphic(message)
    self.curtain = Curtain:new()
    self:add(self.curtain)
    self.curtain:fadeOut()
end

function EndScreen:update(dt)
    World.update(self, dt)
end
