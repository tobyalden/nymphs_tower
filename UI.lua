UI = class("UI", Entity)

function UI:initialize()
    Entity.initialize(self, 10, 10)
    self.graphic = Sprite:new("healthbar.png")
    --self.graphic = Text:new("Hello world", 32)
    self.layer = -99
    self.graphic.scroll = 0
end

function UI:update(dt)
    Entity.update(self, dt)
end

