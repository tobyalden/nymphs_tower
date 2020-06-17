Text = class("Text")

function Text:initialize(text, size, fontPath)
    fontPath = fontPath or "arial.ttf"
    self.text = text
    self.font = love.graphics.newFont(fontPath, size, "mono")
    self.image = love.graphics.newText(self.font, self.text)
end
