Menu = class("Menu", Entity)

function Menu:initialize(itemNames)
    Entity.initialize(self)
    self.x = 30
    self.y = 50

    self.graphic = Graphiclist:new({})
    self.itemNames = itemNames

    self.hasSaveData = saveData.exists("currentCheckpoint")

    for i, itemName in ipairs(itemNames) do
        local item = Text:new(itemName, 24)
        item.offsetY = 32 * (i - 1)
        self.graphic:add(item)
        if i == 1 then
            self.newGameMenuItem = item
        end
        if i == 2 then
            self.continueMenuItem = item
            if not self.hasSaveData then
                self.continueMenuItem.alpha = 0.5
            end
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
        if GameWorld.static.isSecondTower then
            tower = GameWorld.SECOND_TOWER
        end
        if GameWorld.static.isSecondTower then
            print('issecondtower')
        else
            print('is not secondtower')
        end
        ammo.world = GameWorld:new(tower)
    end))

    self.optionsTimer = self:addTween(Alarm:new(2, function()
        ammo.world = Options:new()
    end))

    self:loadSfx({"menunew.wav", "menumove.wav", "menuback.wav", "menucontinue.wav", "menuno.wav"})
end

function Menu:update(dt)
    if not self.startTimer.active and not self.optionsTimer.active then
        if self.isOnSubmenu then
            self.submenu.alpha = 1
            self.newGameMenuItem.alpha = 0
            self.continueMenuItem.alpha = 0
            if input.pressed("jump") then
                if self.submenuCursorIsYes then
                    clearSave()
                    self:fadeToGame()
                    self.sfx["menunew"]:play()
                else
                    self.isOnSubmenu = false
                    self.sfx["menuback"]:play()
                end
            end
            if input.pressed("shoot") then
                if self.isOnSubmenu then
                    self.sfx["menuback"]:play()
                end
                self.isOnSubmenu = false
            end
            if input.pressed("left") and not self.submenuCursorIsYes then
                self.submenuCursorIsYes = true
                self.sfx["menumove"]:play()
            elseif input.pressed("right") and self.submenuCursorIsYes then
                self.submenuCursorIsYes = false
                self.sfx["menumove"]:play()
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
            if self.hasSaveData then
                self.continueMenuItem.alpha = 1
            else
                self.continueMenuItem.alpha = 0.5
            end
            local oldCursorIndex = self.cursorIndex
            if input.pressed("up") then
                self.cursorIndex = self.cursorIndex - 1
            elseif input.pressed("down") then
                self.cursorIndex = self.cursorIndex + 1
            elseif input.pressed("jump") then
                if self.cursorIndex == 1 then
                    -- NEW GAME
                    if self.hasSaveData then
                        self.isOnSubmenu = true
                        self.submenuCursorIsYes = false
                        self.sfx["menumove"]:play()
                    else
                        clearSave()
                        self:fadeToGame()
                        self.sfx["menunew"]:play()
                    end
                elseif self.cursorIndex == 2 then
                    -- CONTINUE
                     if self.hasSaveData then
                        self:fadeToGame()
                        self.sfx["menucontinue"]:play()
                    else
                        self.sfx["menuno"]:play()
                    end
                elseif self.cursorIndex == 3 then
                    self.sfx["menumove"]:play()
                    self:fadeToOptions()
                end
            end
            self.cursorIndex = math.clamp(self.cursorIndex, 1, #self.itemNames)
            if oldCursorIndex ~= self.cursorIndex then
                self.sfx["menumove"]:play()
            end
            self.cursor.offsetX = -19
            self.cursor.offsetY = 5 + (self.cursorIndex - 1) * 33
        end
    end
    Entity.update(self, dt)
end

function Menu:fadeToGame()
    GameWorld.static.isSecondTower = false
    if saveData.exists("currentCheckpoint") then
        local loadedCheckpoint = saveData.load("currentCheckpoint")
        if loadedCheckpoint["isSecondTower"] then
            GameWorld.static.isSecondTower = true
        end
    end
    self.startTimer:start()
    self.world.curtain:fadeIn()
end

function Menu:fadeToOptions()
    self.optionsTimer:start()
    self.world.curtain:fadeIn()
end
