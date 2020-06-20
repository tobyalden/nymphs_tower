Text = class("Text")

function Text:initialize(text, size, fontPath, color)
    fontPath = fontPath or "arial.ttf"
    self.color = color or {1, 1, 1}
    self.offsetX = 0
    self.offsetY = 0
    self.text = text
    self.font = love.graphics.newFont(fontPath, size, "mono")
    self.image = love.graphics.newText(self.font, self.text)
end
