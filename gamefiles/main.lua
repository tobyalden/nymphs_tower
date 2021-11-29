local tick = require 'tick'
push = require "push"

inspect = require "inspect"

saveData = require("saveData")

function clearSave()
    GameWorld.static.isSecondTower = false
    saveData.clear("currentCheckpoint")
    saveData.clear("currentFlags")
    saveData.clear("itemIds")
    saveData.clear("acidLevels")
    saveData.clear("totalTime")
end

function formatTime(totalTime)
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
    local displaySeconds = string.format("%04.2f", totalTime)
    if string.len(displaySeconds) == 4 then
        displaySeconds = '0' .. displaySeconds
    end
    local displayTime
    if hours > 0 then
        displayTime = hours .. ":" .. string.format("%02d", minutes) .. ":" .. displaySeconds
    else
        displayTime =  minutes .. ":" .. displaySeconds
    end
    return displayTime
end


require("ammo")
require("ammo/all")
require("Boss")
require("GameWorld")
require("MainMenu")
require("EndScreen")
require("Menu")
require("Player")
require("Level")
require("UI")
require("Background")
require("Acid")
require("CameraZone")
require("PlayerBullet")
require("Gun")
require("HealthUpgrade")
require("FuelUpgrade")
require("Block")
require("Pig")
require("Lock")
require("FlagTrigger")
require("AcidTrigger")
require("Checkpoint")
require("Wizard")
require("Curtain")
require("Spike")
require("EnemyBullet")
require("Star")
require("Miku")
require("FinalBoss")
require("SecretBoss")
require("GravityBelt")
require("Particle")
require("Harmonica")
require("HazardSuit")
require("Inside")
require("Crown")
require("Map")
require("Compass")
require("Decoration")
require("Boat")
require("Tutorial")
require("Options")
require("OptionsMenu")
require("Credits")

io.stdout:setvbuf("no")

gameWidth, gameHeight = 320, 180
windowedScale = 2
local windowWidth, windowHeight = love.window.getDesktopDimensions()
GameWorld.isSpeedrunMode = false
joystick = nil

function love.globalUpdate()
    if input.pressed("quit") then
        love.event.quit()
    end
end

function love.joystickadded(newJoystick)
    print('joystick connected')
    if not joystick then
        joystick = newJoystick
    end
end

function love.load()
    love.mouse.setVisible(false)

    input.define("up", "up")
    input.define("down", "down")
    input.define("left", "left", "[")
    input.define("right", "right", "]")
    input.define("jump", "z", "space")
    input.define("shoot", "x")
    input.define("reset", "r")
    input.define("map", "return")
    input.define("quit", "escape")
    
    input.define("shift", "lshift")
    input.define("debug_teleport", "t")
    input.define("debug_allitems", "i")
    input.define("debug_print", "p")
    input.define("debug_up", "w")
    input.define("debug_down", "s")
    input.define("debug_left", "a")
    input.define("debug_right", "d")

    local joysticks = love.joystick.getJoysticks()
    joystick = joysticks[1]

    love.window.setTitle("Nymph's Tower")

    tick.framerate = -1
    tick.rate = 1 / 60
    love.graphics.setDefaultFilter("nearest", "nearest", 1)

    globalSfx = {}

    local dir = ""
    local files = love.filesystem.getDirectoryItems(dir)
    for k, file in ipairs(files) do
        local sfxName = string.sub(file, 1, string.len(file) - 4)
        if string.sub(file, -4) == '.wav' then
            globalSfx[sfxName] = Sound:new(file)
        end
    end

    local fullscreen = true
    if saveData.exists("options") then
        local loadedOptions = saveData.load("options")
        fullscreen = loadedOptions["isFullscreen"] == "true"
        GameWorld.isSpeedrunMode = loadedOptions["isSpeedrunMode"] == "true"
    end

    if fullscreen then
        push:setupScreen(
            gameWidth, gameHeight, windowWidth, windowHeight,
            {fullscreen = true, pixelperfect = true}
        )
    else
        push:setupScreen(
            gameWidth, gameHeight,
            gameWidth * windowedScale, gameHeight * windowedScale,
            {fullscreen = false, pixelperfect = true, resizable = false}
        )
    end
     -- ammo.world = Options:new()
     ammo.world = MainMenu:new()
      --ammo.world = EndScreen:new(true)
      --ammo.world = Credits:new()
     
    --if saveData.exists("currentCheckpoint") then
        --local loadedCheckpoint = saveData.load("currentCheckpoint")
        --if loadedCheckpoint["isSecondTower"] then
            --GameWorld.static.isSecondTower = true
        --end
    --end
    --local tower = GameWorld.FIRST_TOWER
    --if GameWorld.static.isSecondTower then
        --tower = GameWorld.SECOND_TOWER
    --end
     --ammo.world = GameWorld:new(tower)
    -- ammo.world = GameWorld:new({'test.json'})
end
