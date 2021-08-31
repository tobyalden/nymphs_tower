EndScreen = class("EndScreen", World)

--MainMenu.static.CAMERA_SPEED = 1.5

function EndScreen:initialize()
    World.initialize(self)
    local level1, level2 = Level:new(GameWorld.FIRST_TOWER, true), Level:new(GameWorld.SECOND_TOWER, true)
    local totalNumberOfItems = #level1.items + #level2.items
    local collectedItems = 0
    local totalTime = 0
    if saveData.exists("currentCheckpoint") then
        local loadedCheckpoint = saveData.load("currentCheckpoint")
        totalTime = loadedCheckpoint["time"]
        totalTime = 13231.3124
        collectedItems = #saveData.load("itemIds")
    end
    local completionPercentage = tostring(math.floor(collectedItems / totalNumberOfItems * 100)) .. "%"
    local message = Text:new(
        "\n\nTime: " .. self:formatTotalTime(totalTime) .. "\nCompletion: " .. completionPercentage, 16, "arial.ttf", {1, 1, 1}, 320, "center"
    )
    --timerText:setText(string.format("%.2f", self.world.timer))
    self:addGraphic(Sprite:new("endscreen.png"))
    self:addGraphic(message)
    self.curtain = Curtain:new()
    self:add(self.curtain)
    self.curtain:fadeOut()
end

function EndScreen:formatTotalTime(totalTime)
    local hours = 0
    local minutes = 0
    while totalTime >= 60 * 60 do
        hours = hours + 1
        totalTime = totalTime - 60 * 60
    end
    while totalTime >= 60 do
        minutes = minutes + 1
        totalTime = totalTime - 60
    end
    return hours .. ":" .. minutes .. ":" .. string.format("%.2f", totalTime)
    -- return minutes .. ":" .. string.format("%.2f", totalTime)
end

function EndScreen:update(dt)
    World.update(self, dt)
end
