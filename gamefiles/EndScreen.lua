EndScreen = class("EndScreen", World)

--MainMenu.static.CAMERA_SPEED = 1.5

local endAnimation

function EndScreen:initialize()
    World.initialize(self)
    -- local level1, level2 = Level:new(GameWorld.FIRST_TOWER, true), Level:new(GameWorld.SECOND_TOWER, true)
    -- local totalNumberOfItems = #level1.items + #level2.items
    local totalNumberOfItems = 1
    local collectedItems = 0
    local totalTime = 0
    if saveData.exists("currentCheckpoint") then
        local loadedCheckpoint = saveData.load("currentCheckpoint")
        totalTime = loadedCheckpoint["time"]
        -- totalTime = 13231.3124
        collectedItems = #saveData.load("itemIds")
    end
    local completionPercentage = tostring(math.floor(collectedItems / totalNumberOfItems * 100)) .. "%"
    local message = Text:new(
        "\n\nTime: " .. self:formatTotalTime(totalTime) .. "\nCompletion: " .. completionPercentage, 16, "arial.ttf", {1, 1, 1}, 320, "center"
    )
    --timerText:setText(string.format("%.2f", self.world.timer))
    endAnimation = Sprite:new("endscreenanimation.png", 320, 180)
    endAnimation:add("sink", {
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
        32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
        33, 33, 33, 33, 33, 33, 33, 33, 33, 33
    }, 10, false, function()
        endAnimation:play("idle")
    end)
    endAnimation:add("idle", {34, 35}, 1)
    endAnimation:play("sink")
    self:addGraphic(endAnimation)
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
