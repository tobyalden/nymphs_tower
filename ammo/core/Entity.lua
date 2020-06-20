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

function Entity:collide(checkX, checkY, solidTypes)
    local items, _ = bumpWorld:queryRect(
        checkX, checkY, self.mask.width, self.mask.height
    )
    local collided = {}
    for _, item in pairs(items) do
        otherTypes = item.parent.types
        for _, solidType in pairs(solidTypes) do
            local matchFound = false
            for _, otherType in pairs(otherTypes) do
                if solidType == otherType then
                    matchFound = true
                    table.insert(collided, item)
                    break
                end
            end
            if matchFound then break end
        end
    end
    return collided
end

function Entity:moveBy(x, y, solidTypes)
    local collidedX = self:_moveBy(x, 0, solidTypes)
    if(#collidedX > 0) then
        self:moveCollideX(collidedX)
    end
    local collidedY = self:_moveBy(0, y, solidTypes)
    if(#collidedY > 0) then
        self:moveCollideY(collidedY)
    end
end

function Entity:moveCollideX(collided)
end

function Entity:moveCollideY(collided)
end

function Entity:_moveBy(x, y, solidTypes)
    solidTypes = solidTypes or {}
    local typeFilter = function(item, other)
        for _, solidType in pairs(solidTypes) do
            for _, otherType in pairs(other.parent.types) do
                if solidType == otherType then return 'slide'
                else return 'cross' end
            end
        end
    end
    local actualX, actualY, cols, len = bumpWorld:move(
        self.mask, self.x + x, self.y + y, typeFilter
    )
    local shouldCollide = false
    local allCollided = {}
    for _, collided in pairs(cols) do
        for _, solidType in pairs(solidTypes) do
            local shouldBreak = false
            local otherTypes = collided.other.parent.types
            for _, otherType in pairs(otherTypes) do
                if solidType == otherType then
                    shouldCollide = true
                    shouldBreak = true
                    table.insert(allCollided, collided.other.parent)
                    break
                end
            end
            if shouldBreak then break end
        end
    end
    if #allCollided > 0 then
        self.x = actualX
        self.y = actualY
    else
        self.x = self.x + x
        self.y = self.y + y
    end
    return allCollided
end

function Entity:added() end

function Entity:update(dt)
    if self.graphic.class == Sprite or self.graphic.class == Graphiclist then
        self.graphic:update(dt)
    end
end

function Entity:draw()
    -- TODO: Could refactor this so we call the draw method of each graphic and
    -- pass it the entity maybe?
     if self.graphic.class == Graphiclist then
         for _, v in pairs(self.graphic.allGraphics) do
            self:_drawGraphic(v)
         end
     else
        self:_drawGraphic(self.graphic)
     end
end

function Entity:_drawGraphic(graphic)
    local scroll = graphic.scroll or 1
    self.world.camera:set(scroll)
    if graphic.class == Sprite then
        local drawQuad = graphic.frames[
            graphic.currentAnimation.frames[
                graphic.currentAnimationIndex
            ]
        ]

        local drawScaleX = graphic.scaleX
        if graphic.flipX then
            drawScaleX = -drawScaleX
        end
        local drawX = self.x
        if drawScaleX < 0 then
            drawX = self.x + graphic.frameWidth * graphic.scaleX
        end
        drawX = drawX + graphic.offsetX

        local drawScaleY = graphic.scaleY
        if graphic.flipY then
            drawScaleY = -drawScaleY
        end
        local drawY = self.y
        if drawScaleY < 0 then
            drawY = self.y + graphic.frameHeight * graphic.scaleY
        end
        drawY = drawY + graphic.offsetY

        love.graphics.draw(
            graphic.paddedImage,
            drawQuad,
            drawX, drawY,
            0,
            drawScaleX, drawScaleY
        )
    elseif graphic.class == Tilemap then
        love.graphics.draw(graphic.batch, self.x, self.y)
    elseif graphic.class == Text then
        local r, g, b, a = love.graphics.getColor()
        love.graphics.setColor(graphic.color)
        love.graphics.draw(graphic.image, self.x, self.y)
        love.graphics.setColor(r, g, b, a)
    elseif graphic.class == Backdrop then
        local drawX = (
            self.x * scroll % graphic.image:getWidth()
            + math.floor(self.world.camera.x * scroll / graphic.image:getWidth())
            * graphic.image:getWidth()
        )
        local drawY = (
            self.y * scroll % graphic.image:getHeight()
            + math.floor(self.world.camera.y * scroll / graphic.image:getHeight())
            * graphic.image:getHeight()
        )
        love.graphics.draw(graphic.batch, drawX, drawY)
    elseif graphic.class == TiledSprite then
        local tiledFrame = graphic.tiledFrames[
            graphic.currentAnimation.frames[
                graphic.currentAnimationIndex
            ]
        ]

        local drawScaleX = graphic.scaleX
        if graphic.flipX then
            drawScaleX = -drawScaleX
        end
        local drawX = self.x
        if drawScaleX < 0 then
            drawX = self.x + graphic.frameWidth * graphic.scaleX
        end
        drawX = drawX + graphic.offsetX

        local drawScaleY = graphic.scaleY
        if graphic.flipY then
            drawScaleY = -drawScaleY
        end
        local drawY = self.y
        if drawScaleY < 0 then
            drawY = self.y + graphic.frameHeight * graphic.scaleY
        end
        drawY = drawY + graphic.offsetY

        love.graphics.draw(
            tiledFrame,
            drawX, drawY,
            0,
            drawScaleX, drawScaleY
        )
    end
    self.world.camera:unset()
end

function Entity:removed() end
