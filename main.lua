require("ammo")
require("ammo/all")
require("GameWorld")
require("Player")
require("Enemy")

function love.load()
    ammo.world = GameWorld:new()
end
