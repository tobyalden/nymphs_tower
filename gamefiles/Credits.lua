Credits = class("Credits", World)

--MainMenu.static.CAMERA_SPEED = 1.5

function Credits:initialize()
    World.initialize(self)
    self.curtain = Curtain:new()
    self:add(self.curtain)
    self.curtain:fadeOut()
    local message = Text:new(
        "\n--- DESIGN ---\nToby Alden, John Thyer\n--- ART ---\nReshma Zachariah, John Bond, Sam Alden\n--- MUSIC ---\nMuxer\n\nThanks for playing!", 12, "arial.ttf", {1, 1, 1}, 320, "center"
    )
    message.offsetY = 10
    self:addGraphic(message)
    self.returnTimer = self.curtain:addTween(Alarm:new(2, function()
        ammo.world = MainMenu:new()
    end))
    self.isReturning = false
end

function Credits:update(dt)
    if input.pressed("jump") and not self.isReturning then
        self:fadeToMainMenu()
    end
    World.update(self, dt)
end

function Credits:fadeToMainMenu()
    globalSfx["menuback"]:play()
    self.isReturning = true
    self.curtain:fadeIn()
    self.returnTimer:start()
end
