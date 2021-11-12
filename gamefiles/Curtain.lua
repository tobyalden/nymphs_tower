Curtain = class("Curtain", Entity)

local blackScreen
local curtainMessage

function Curtain:initialize()
    Entity.initialize(self)
    blackScreen = Backdrop:new("curtain.png")
    curtainMessage = Text:new("", 12, "arial.ttf", {1, 1, 1}, 320, "center")
    curtainMessage.offsetY = 80
    self.graphic = Graphiclist:new({blackScreen, curtainMessage})
    self.layer = -999
    blackScreen.alpha = 1
    curtainMessage.alpha = 1
    self.graphic.scroll = 0
    self.isFadingOut = false
end

function Curtain:setMessage(message)
    curtainMessage:setText(message)
end

function Curtain:fadeOut()
    self.isFadingOut = true
end

function Curtain:fadeIn()
    self.isFadingOut = false
end

function Curtain:fadeInInstantly()
    self.isFadingOut = false
    blackScreen.alpha = 1
    curtainMessage.alpha = 1
end

function Curtain:update(dt)
    local curtainSpeed = 0.5
    if self.isFadingOut then
        blackScreen.alpha = blackScreen.alpha - curtainSpeed * dt
        curtainMessage.alpha = curtainMessage.alpha - curtainSpeed * dt
    else
        blackScreen.alpha = blackScreen.alpha + curtainSpeed * dt
        curtainMessage.alpha = curtainMessage.alpha + curtainSpeed * dt
    end
    blackScreen.alpha = math.clamp(blackScreen.alpha, 0, 1)
    curtainMessage.alpha = math.clamp(curtainMessage.alpha, 0, 1)
    Entity.update(self, dt)
end
