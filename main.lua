require("ammo")
require("ammo/all")
require("GameWorld")
require("Player")
require("Enemy")
require("Level")

function love.load()
    love.window.setMode(320, 180)
    ammo.world = GameWorld:new()
end
