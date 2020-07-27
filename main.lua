local tick = require 'tick'
push = require "push"

inspect = require "inspect"

require("ammo")
require("ammo/all")
require("Boss")
require("GameWorld")
require("MainMenu")
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
require("Checkpoint")
require("Wizard")
require("Spike")
require("EnemyBullet")
require("Star")
require("Miku")
require("FinalBoss")
require("SecretBoss")
require("GravityBelt")

gameWidth, gameHeight = 320, 180
local windowWidth, windowHeight = love.window.getDesktopDimensions()
local fullscreen = false
local windowedScale = 2

function love.load()
    input.define("up", "up")
    input.define("down", "down")
    input.define("left", "left", "[")
    input.define("right", "right", "]")
    input.define("jump", "z")
    input.define("shoot", "x")

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
    ammo.world = MainMenu:new()
end
