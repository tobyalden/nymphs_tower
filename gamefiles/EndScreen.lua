EndScreen = class("EndScreen", World)

--MainMenu.static.CAMERA_SPEED = 1.5

local endAnimation

function EndScreen:initialize(isTrueEnd)
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
        36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
        32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
        33, 33, 33, 33, 33, 33, 33, 33, 33, 33
    }, 10, false, function()
        endAnimation:play("sink_idle")
    end)
    endAnimation:add("idle", {1, 36}, 1)
    endAnimation:add("sink_idle", {34, 35}, 1)
    self:loadSfx({"ocean.wav", "towersink.wav"})
    self.sfx["ocean"]:loop(0)
    if isTrueEnd then
        endAnimation:play("sink")
        self.sfx["towersink"]:play()
    else
        endAnimation:play("idle")
    end
    self:addGraphic(endAnimation)
    self:addGraphic(message)
    self.curtain = Curtain:new()
    self:add(self.curtain)
    self.curtain:fadeOut()
    self.canReturnToMainMenu = false
    self.curtain:addTween(Alarm:new(3, function()
        self.canReturnToMainMenu = true
    end), true)
    self.mainMenuTimer = self.curtain:addTween(Alarm:new(5, function()
        ammo.world = MainMenu:new()
    end))
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
    if self.mainMenuTimer.active then
        self.sfx["ocean"]:fadeOut(dt)
    else
        self.sfx["ocean"]:fadeIn(dt)
    end
    if input.pressed("jump") and self.canReturnToMainMenu and not self.mainMenuTimer.active then
        print('exit')
        self:fadeToMainMenu()
    end
    World.update(self, dt)
end

function EndScreen:fadeToMainMenu()
    self.curtain:fadeIn()
    self.mainMenuTimer:start()
end
