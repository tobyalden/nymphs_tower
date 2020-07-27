Curtain = class("Curtain", Entity)

function Curtain:initialize()
    Entity.initialize(self)
    self.graphic = Backdrop:new("curtain.png")
    self.graphic.scroll = 0
    self.layer = -999
    self.graphic.alpha = 1
    self.isFadingOut = false
end

function Curtain:fadeOut()
    self.isFadingOut = true
end

function Curtain:fadeIn()
    self.isFadingOut = false
end

function Curtain:update(dt)
    if self.isFadingOut then
        self.graphic.alpha = self.graphic.alpha - 0.5 * dt
    else
        self.graphic.alpha = self.graphic.alpha + 0.5 * dt
    end
    self.graphic.alpha = math.clamp(self.graphic.alpha, 0, 1)
    Entity.update(self, dt)
end
