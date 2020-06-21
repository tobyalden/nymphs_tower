Text = class("Text")

function Text:initialize(text, size, fontPath, color, wrapWidth, alignType)
    size = size or 16
    fontPath = fontPath or "arial.ttf"
    self.wrapWidth = wrapWidth or math.huge
    self.alignType = alignType or "left"
    self.color = color or {1, 1, 1}
    self.offsetX = 0
    self.offsetY = 0
    self.text = text
    self.font = love.graphics.newFont(fontPath, size, "mono")
    self.image = love.graphics.newText(self.font, self.text)
    self:setText(self.text)
end

function Text:setText(text)
    self.image:setf(text, self.wrapWidth, self.alignType)
end
