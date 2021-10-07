
Tutorial = class("Tutorial", Entity)

function Tutorial:initialize(x, y, text)
    Entity.initialize(self, x, y)
    self.types = {"tutorial"}
    self.graphic = Text:new(text, 12)
end
