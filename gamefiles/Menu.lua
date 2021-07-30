Menu = class("Menu", Entity)

function Menu:initialize(itemNames)
    Entity.initialize(self)
    self.x = 30
    self.y = 100

    self.graphic = Graphiclist:new({})
    self.itemNames = itemNames

    for i, itemName in ipairs(itemNames) do
        local item = Text:new(itemName, 24)
        item.offsetY = 32 * (i - 1)
        self.graphic:add(item)
        if i == 1 then
            self.newGameMenuItem = item
        end
        if i == 2 then
            self.continueMenuItem = item
        end
    end

    self.cursor = Sprite:new("cursor.png")
    self.cursorIndex = 1
    self.cursor.offsetX = -16
    self.cursor.offsetY = 5 + (self.cursorIndex - 1) * 32
    self.graphic:add(self.cursor)

    self.submenu = Text:new("ARE YOU SURE?\n      YES       NO", 24)
    self.isOnSubmenu = false
    self.submenuCursorIsYes = false
    self.graphic:add(self.submenu)

    self.startTimer = self:addTween(Alarm:new(3, function()
        local tower = GameWorld.FIRST_TOWER
        if GameWorld.isSecondTower then
            tower = GameWorld.SECOND_TOWER
        end
        if GameWorld.isSecondTower then
            print('issecondtower')
        else
            print('is not secondtower')
        end
        ammo.world = GameWorld:new(tower)
    end))
end

function Menu:update(dt)
    if not self.startTimer.active then
        if self.isOnSubmenu then
            self.submenu.alpha = 1
            self.newGameMenuItem.alpha = 0
            self.continueMenuItem.alpha = 0
            if input.pressed("jump") then
                if self.submenuCursorIsYes then
                    clearSave()
                    self:fadeToGame()
                else
                    self.isOnSubmenu = false
                end
            end
            if input.pressed("shoot") then
                self.isOnSubmenu = false
            end
            if input.pressed("left") and not self.submenuCursorIsYes then
                self.submenuCursorIsYes = true
            elseif input.pressed("right") and self.submenuCursorIsYes then
                self.submenuCursorIsYes = false
            end
            if self.submenuCursorIsYes then
                self.cursor.offsetX = 24
            else
                self.cursor.offsetX = 24 + 97
            end
            self.cursor.offsetY = 5 + 32
        else
            self.submenu.alpha = 0
            self.newGameMenuItem.alpha = 1
            self.continueMenuItem.alpha = 1
            if input.pressed("up") then
                self.cursorIndex = self.cursorIndex - 1
            elseif input.pressed("down") then
                self.cursorIndex = self.cursorIndex + 1
            elseif input.pressed("jump") then
                if self.cursorIndex == 1 then
                    -- NEW GAME
                    self.isOnSubmenu = true
                    self.submenuCursorIsYes = false
                elseif self.cursorIndex == 2 then
                    -- CONTINUE
                    self:fadeToGame()
                end
            end
            self.cursorIndex = math.clamp(self.cursorIndex, 1, #self.itemNames)
            self.cursor.offsetX = -19
            self.cursor.offsetY = 5 + (self.cursorIndex - 1) * 33
        end
    end
    Entity.update(self, dt)
end

function Menu:fadeToGame()
    GameWorld.isSecondTower = false
    if saveData.exists("currentCheckpoint") then
        local loadedCheckpoint = saveData.load("currentCheckpoint")
        if loadedCheckpoint["isSecondTower"] then
            GameWorld.isSecondTower = true
        end
    end
    self.startTimer:start()
    self.world.curtain:fadeIn()
end
