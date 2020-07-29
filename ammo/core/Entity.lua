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
    self._moveX, self._moveY = 0, 0
    self.active = true
    self.paused = false
    self.visible = true
    self.collidable = true
    self._layer = 1
    self.width = 1
    self.height = 1
    self.types = {}
    --self.graphic = Sprite:new("debug.png", 50, 50)
    self.sfx = {}
    self.tweens = {}
end

function Entity:explode(numParticles, particleSpeed, particleScale, particleFps, offsetX, offsetY, particleLayer, startPaused)
    offsetX = offsetX or 0
    offsetY = offsetY or 0
    particleLayer = particleLayer or -99
    local offset = math.random() * math.pi * 2
    local increment = (math.pi * 2) / numParticles
    for i = 1, numParticles do
        --local rotation = increment * (i - 1) + offset + (offset / 4 * math.random())
        local rotation = increment * (i - 1) + offset
        local particleHeading = Vector:new(math.cos(rotation), math.sin(rotation))
        --particleSpeed = particleSpeed + ((particleSpeed / 8) * (math.random()))
        local offset = 6 * particleScale
        local particle = Particle:new(
            self:getMaskCenter().x - offset + offsetX,
            self:getMaskCenter().y - offset + offsetY,
            particleHeading, particleSpeed, particleScale, particleFps,
            particleLayer, startPaused
        )
        self.world:add(particle)
    end
end

function Entity:distanceFrom(otherEntity, useHitbox)
    useHitbox = useHitbox or false
    if useHitbox then
        local myCenter = self:getMaskCenter()
        local otherEntityCenter = otherEntity:getMaskCenter()
        return math.sqrt(
            (otherEntityCenter.x - myCenter.x) ^ 2
            + (otherEntityCenter.y - myCenter.y) ^ 2
        )
    else
        return math.sqrt((otherEntity.x - self.x) ^ 2 + (otherEntity.y - self.y) ^ 2)
    end
end

function Entity:getMaskCenter()
    return Vector:new(
        self.x + self.mask.width / 2, (self.y + self.mask.height / 2)
    )
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
    local typeFilter = function(item)
        for _, solidType in pairs(solidTypes) do
            for _, otherType in pairs(item.parent.types) do
                if (
                    solidType == otherType
                    and item.parent.collidable
                ) then
                    return true
                end
            end
        end
        return false
    end
    local items, _ = bumpWorld:queryRect(
        checkX, checkY, self.mask.width, self.mask.height, typeFilter
    )
    local collided = {}
    for _, item in pairs(items) do
        otherTypes = item.parent.types
        for _, solidType in pairs(solidTypes) do
            local matchFound = false
            for _, otherType in pairs(otherTypes) do
                matchFound = true
                table.insert(collided, item.parent)
                break
            end
            if matchFound then break end
        end
    end
    return collided
end

function Entity:addTween(tween, start)
    start = start or false
    table.insert(self.tweens, tween)
    if start then
        tween:start()
    end
    return tween
end

function Entity:moveBy(x, y, solidTypes)
    self._moveX = self._moveX + x
    self._moveY = self._moveY + y
    local useX = math.round(self._moveX)
    local useY = math.round(self._moveY)
    self._moveX = self._moveX - useX
    self._moveY = self._moveY - useY

    local collidedX = self:_moveBy(useX, 0, solidTypes)
    if(#collidedX > 0) then
        self:moveCollideX(collidedX)
    end
    local collidedY = self:_moveBy(0, useY, solidTypes)
    if(#collidedY > 0) then
        self:moveCollideY(collidedY)
    end
end

function Entity:moveTo(x, y, solidTypes)
    self._moveX = 0
    self._moveY = 0
    self:moveBy(x - self.x, y - self.y, solidTypes)
end

function Entity:moveCollideX(collided)
end

function Entity:moveCollideY(collided)
end

function Entity:_moveBy(x, y, solidTypes)
    if not solidTypes or #solidTypes == 0 then
        self.x = self.x + x
        self.y = self.y + y
        bumpWorld:update(self.mask, self.x, self.y)
        return {}
    end
    local typeFilter = function(item, other)
        for _, solidType in pairs(solidTypes) do
            for _, otherType in pairs(other.parent.types) do
                if (
                    solidType == otherType
                    and other.parent.collidable
                ) then return 'slide' end
            end
        end
        return 'cross'
    end
    local actualX, actualY, cols, len = bumpWorld:move(
        self.mask, self.x + x, self.y + y, typeFilter
    )
    local allCollided = {}
    for _, collided in pairs(cols) do
        for _, solidType in pairs(solidTypes) do
            local otherTypes = collided.other.parent.types
            for _, otherType in pairs(otherTypes) do
                if (
                    solidType == otherType
                    and collided.other.parent.collidable
                ) then
                    table.insert(allCollided, collided.other.parent)
                end
            end
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
    if self.graphic and (self.graphic.class == Sprite or self.graphic.class == Graphiclist) then
        self.graphic:update(dt)
    end
    if not self.paused and self.active then
        for _, tween in pairs(self.tweens) do
            tween:update(dt)
        end
    end
end

function Entity:draw()
    -- TODO: Could refactor this so we call the draw method of each graphic and
    -- pass it the entity maybe?
    if not self.graphic or not self.visible then return end
    if self.graphic.class == Graphiclist then
        for _, v in pairs(self.graphic.allGraphics) do
            self:_drawGraphic(v)
        end
    else
        self:_drawGraphic(self.graphic)
    end
end

function Entity:_drawGraphic(graphic)
    --local oldX = self.x
    --local oldY = self.y
    --self.x = math.round(self.x)
    --self.y = math.round(self.y)
    local r, g, b, a = love.graphics.getColor()
    local scroll = graphic.scroll or 1
    local alpha = graphic.alpha or 1
    local color = graphic.color or {1, 1, 1}
    love.graphics.setColor(color[1], color[2], color[3], alpha)
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
        love.graphics.draw(
            graphic.image,
            self.x + graphic.offsetX, self.y + graphic.offsetY
        )
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
    love.graphics.setColor(r, g, b, a)
    --self.x = oldX
    --self.y = oldY
end

function Entity:removed() end
