UI = class("UI", Entity)

function UI:initialize()
    Entity.initialize(self, 40, 50)
    self.graphic = Text:new("Hello world", 32)
end

function UI:update(dt)
    Entity.update(self, dt)
end

