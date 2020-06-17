Entity = class("Entity")

function Entity:__index(key)
    return rawget(self, "_" .. key) or self.class.__instanceDict[key]
end

function Entity:__newindex(key, value)
    if key == "layer" then
        if self._layer == value then return end

        if self._world then
            local prev = self._layer
            self._layer = value
            self._world:_setLayer(self, prev)
        else
            self._layer = value
        end
    elseif key == "world" then
        if self._world == value then return end
        if self._world then self._world:remove(self) end
        if value then value:add(self) end
    else
        rawset(self, key, value)
    end
end

function Entity:initialize(x, y)
    self.x = x or 0
    self.y = y or 0
    self.active = true
    self.visible = true
    self._layer = 1
    self.width = 1
    self.height = 1
    self.types = {}
    self.graphic = Sprite:new("debug.png", 50, 50)
    self.sfx = {}
end

function loadSfx(parent, sfxPaths)
    for _, sfxPath in pairs(sfxPaths) do
        local sfxName
        words = {}
        for word in (sfxPath .. '.'):gmatch("([^.]*).") do
            sfxName = word
            table.insert(words, word)
        end
        sfxName = words[1]
        fileType = words[2]
        parent.sfx[sfxName] = Sound:new(sfxPath, fileType == "ogg")
    end
end

function Entity:loadSfx(sfxPaths)
    loadSfx(self, sfxPaths)
end

function Entity:moveBy(x, y, solidTypes)
    solidTypes = solidTypes or {}
    local actualX, actualY, cols, len = bumpWorld:move(self.mask, self.x + x, self.y + y)
    local shouldCollide = false
    for _, collided in pairs(cols) do
        for _, solidType in pairs(solidTypes) do
            otherTypes = collided.other.parent.types
            for _, otherType in pairs(otherTypes) do
                if solidType == otherType then
                    shouldCollide = true
                end
            end
        end
    end
    if shouldCollide then
        self.x = actualX
        self.y = actualY
    else
        bumpWorld:update(self.mask, self.x + x, self.y + y)
        self.x = self.x + x
        self.y = self.y + y
    end
end

function Entity:added() end

function Entity:update(dt)
    if self.graphic.class == Sprite then
        self.graphic:update(dt)
    end
end

function Entity:draw()
    -- TODO: Could refactor this so we call the draw method of each graphic and
    -- pass it the entity maybe?
    if self.graphic.class == Sprite then
        local drawQuad = self.graphic.frames[
            self.graphic.currentAnimation.frames[
                self.graphic.currentAnimationIndex
            ]
        ]

        local drawScaleX = self.graphic.scaleX
        if self.graphic.flipX then
            drawScaleX = -drawScaleX
        end
        local drawX = self.x
        if drawScaleX < 0 then
            drawX = self.x + self.graphic.frameWidth * self.graphic.scaleX
        end
        drawX = drawX + self.graphic.offsetX

        local drawScaleY = self.graphic.scaleY
        if self.graphic.flipY then
            drawScaleY = -drawScaleY
        end
        local drawY = self.y
        if drawScaleY < 0 then
            drawY = self.y + self.graphic.frameHeight * self.graphic.scaleY
        end
        drawY = drawY + self.graphic.offsetY

        love.graphics.draw(
            self.graphic.image,
            drawQuad,
            drawX, drawY,
            0,
            drawScaleX, drawScaleY
        )
    elseif self.graphic.class == Tilemap then
        love.graphics.draw(self.graphic.batch, self.x, self.y)
    elseif self.graphic.class == Text then
        love.graphics.draw(self.graphic.image, self.x, self.y)
    end
end

function Entity:removed() end
