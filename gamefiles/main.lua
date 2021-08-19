local tick = require 'tick'
push = require "push"

inspect = require "inspect"

saveData = require("saveData")

function clearSave()
    GameWorld.isSecondTower = false
    saveData.clear("currentCheckpoint")
    saveData.clear("currentFlags")
    saveData.clear("itemIds")
    saveData.clear("acidLevels")
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

io.stdout:setvbuf("no")

gameWidth, gameHeight = 320, 180
local windowWidth, windowHeight = love.window.getDesktopDimensions()
local fullscreen = false
local windowedScale = 2

function love.globalUpdate()
    if input.pressed("quit") then
        love.event.quit()
    end
end

function love.load()
    input.define("up", "up")
    input.define("down", "down")
    input.define("left", "left", "[")
    input.define("right", "right", "]")
    input.define("jump", "z")
    input.define("shoot", "x")
    input.define("reset", "r")
    input.define("teleport", "t")
    input.define("test", "p")
    input.define("map", "return")
    input.define("quit", "escape")
    input.define("shift", "lshift")

    love.window.setTitle("Nymph's Tower")

    tick.framerate = -1
    tick.rate = 1 / 60
    love.graphics.setDefaultFilter("nearest", "nearest", 1)
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
     --ammo.world = MainMenu:new()
     ammo.world = EndScreen:new()
     --ammo.world = GameWorld:new(GameWorld.FIRST_TOWER)
end
