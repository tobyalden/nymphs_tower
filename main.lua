push = require "push"

require("ammo")
require("ammo/all")
require("GameWorld")
require("Player")
require("Enemy")
require("Level")

local gameWidth, gameHeight = 320, 180
local windowWidth, windowHeight = love.window.getDesktopDimensions()
local fullscreen = false
local windowedScale = 3

function love.load()
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
    ammo.world = GameWorld:new()
end
