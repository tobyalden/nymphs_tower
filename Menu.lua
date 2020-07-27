Menu = class("Menu", Entity)

function Menu:initialize(itemNames)
    Entity.initialize(self)
    self.x = 30
    self.y = 10
    self.graphic = Graphiclist:new({})
    for i, itemName in ipairs(itemNames) do
        local item = Text:new(itemName, 24)
        item.offsetY = 24 * (i - 1)
        self.graphic:add(item)
    end
    self.cursor = Sprite:new("cursor.png")
    self.cursorIndex = 1
    self.cursor.offsetX = -16
    self.cursor.offsetY = 5 + (self.cursorIndex - 1) * 24
    self.graphic:add(self.cursor)
    self.startTimer = self:addTween(Alarm:new(3, function()
        ammo.world = GameWorld:new()
    end))
end

function Menu:update(dt)
    if not self.startTimer.active then
        if input.pressed("up") then
            self.cursorIndex = self.cursorIndex - 1
        elseif input.pressed("down") then
            self.cursorIndex = self.cursorIndex + 1
        end
        if input.pressed("shoot") then
            self:fadeToGame()
        end
    end
    self.cursorIndex = math.clamp(self.cursorIndex, 1, #self.graphic.allGraphics - 1)
    self.cursor.offsetY = 5 + (self.cursorIndex - 1) * 24
    Entity.update(self, dt)
end

function Menu:fadeToGame()
    self.startTimer:start()
    self.world.curtain:fadeIn()
end
