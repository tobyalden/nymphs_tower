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
    self.type = ""
    self.sprite = Sprite:new("debug.png", 50, 50)
end

function Entity:moveBy(x, y, solidTypes)
    solidTypes = solidTypes or {}
    local actualX, actualY, cols, len = bumpWorld:move(self, self.x + x, self.y + y)
    local shouldCollide = false
    for _, collided in pairs(cols) do
        for _, solidType in pairs(solidTypes) do
            if collided.other.type == solidType then
                shouldCollide = true
            end
        end
    end
    if shouldCollide then
        self.x = actualX
        self.y = actualY
    else
        bumpWorld:update(self, self.x + x, self.y + y)
        self.x = self.x + x
        self.y = self.y + y
    end
end

function Entity:added() end
function Entity:update(dt) end

function Entity:draw()
    love.graphics.draw(
        self.sprite.image,
        self.sprite.frames[self.sprite.currentAnimation[1]],
        self.x, self.y
    )
end

function Entity:removed() end
