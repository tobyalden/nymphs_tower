Sound = class("Sound")

function Sound:__index(key)
    local result = rawget(self, "_" .. key) or self.class.__instanceDict[key]

    if result then
        return result
    elseif key == "count" then
        return #self._sources
    end
end

function Sound:initialize(file, long, volume, pan)
    self._file = file
    self._long = long or false
    self.defaultVolume = volume or 1
    self.defaultPan = pan or 0
    self._sources = {}

    if self._long then
        self._data = file
    else
        self._data = type(file) == "string" and love.sound.newSoundData(file) or file
    end
end

function Sound:play(restart, volume, pan, isLooping)
    local source

    for i, v in ipairs(self._sources) do
        if v:isPlaying() then
            if isLooping then
                return v
            elseif restart then
                source = v
                break
            end
        else
            table.remove(self._sources, i)
            source = v
            break
        end
    end


    if not source then source = love.audio.newSource(self._data, "stream") end
    source:seek(0)
    source:setVolume(volume or self.defaultVolume)
    -- TODO: Allow for panning?
    --source:setPosition(pan or self.defaultPan, 0, 0)
    source:play()
    self._sources[#self._sources + 1] = source
    return source
end

function Sound:fadeOut(fadeAmount, stop)
    stop = stop or true
    if self:isPlaying() then
        if self:getVolume() > 0 then
            self:setVolume(math.approach(self:getVolume(), 0, fadeAmount))
        elseif stop then
            self:stop()
        end
    end
end

function Sound:fadeIn(fadeAmount, startVolume, maxVolume)
    startVolume = 0 or startVolume
    -- maxVolume = 1 or maxVolume
    if not self:isPlaying() then
        self:loop(math.min(startVolume, maxVolume))
    end
    self:setVolume(math.approach(self:getVolume(), maxVolume, fadeAmount))
end

function Sound:setVolume(volume)
    for _, v in pairs(self._sources) do
        v:setVolume(volume)
    end
end

function Sound:getVolume()
    for _, v in pairs(self._sources) do
        return v:getVolume()
    end
end

function Sound:stop()
    for _, v in pairs(self._sources) do
        v:stop()
    end
end

function Sound:stopLoops()
    for _, v in pairs(self._sources) do
        if(v:isLooping()) then
            v:stop()
        end
    end
end

function Sound:isPlaying()
    for _, v in pairs(self._sources) do
        if(v:isPlaying()) then
            return true
        end
    end
    return false
end

function Sound:loop(volume, pan)
    local source = self:play(false, volume, pan, true)
    source:setLooping(true)
    return source
end

function Sound:clearStopped()
    local i = 1

    while i <= #self._sources do
        if not self._sources[i]:isPlaying() then
            table.remove(self._sources, i)
        else
            i = i + 1
        end
    end
end

function Sound:clearAll()
    self._sources = {}
end

for _, v in pairs{"pause", "resume", "rewind", "stop"} do
    Sound[v] = function(self, last)
        if last and self._sources[#self._sources] then
            local source = self._sources[#self._sources]
            if source and source:isPlaying() then source[v](source) end
        else
            for _, s in pairs(self._sources) do
                if s:isPlaying() then s[v](s) end
            end
        end
    end
end
