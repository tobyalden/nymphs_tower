Sprite = class("Sprite")

function Sprite:initialize(path, frameWidth, frameHeight)
    self.image = love.graphics.newImage(path)
    self.frameWidth = frameWidth or self.image:getWidth()
    self.frameHeight = frameHeight or self.image:getHeight()
    self.flipX = false
    self.flipY = false
    self.offsetX = 0
    self.offsetY = 0
    self.scaleX = 1
    self.scaleY = 1
    self.frames = {}
    self.animations = {}
    self.currentAnimation = {frames = {1}, fps = 1, loop = false}
    self.currentAnimationIndex = 1
    self.elapsed = 0

    -- Create a new image from the source image with added padding between frames
    local imageData = love.image.newImageData(path)
    local widthInFrames = self.image:getWidth() / self.frameWidth
    local heightInFrames = self.image:getHeight() / self.frameHeight
    local pixelOffsetX = 0
    local pixelOffsetY = 0
    local padding = 1
    local paddedImageData = love.image.newImageData(
        self.image:getWidth() + widthInFrames * padding,
        self.image:getHeight() + heightInFrames * padding
    )

    -- Create a new image from the source image with added padding between frames
    for pixelY = 0, imageData:getHeight() - 1 do
        if pixelY > 0 and pixelY % self.frameHeight == 0 then
            pixelOffsetY = pixelOffsetY + padding
        end
        for pixelX = 0, imageData:getWidth() - 1 do
            if pixelX > 0 and pixelX % self.frameWidth == 0 then
                pixelOffsetX = pixelOffsetX + padding
            end
            local r, g, b, a = imageData:getPixel(pixelX, pixelY)
            paddedImageData:setPixel(
                pixelX + pixelOffsetX, pixelY + pixelOffsetY, r, g, b, a
            )
        end
        pixelOffsetX = 0
    end
    self.paddedImage = love.graphics.newImage(paddedImageData)

    -- Chop padded image up into frames
    for frameY = 1, self.image:getHeight() / self.frameHeight do
        for frameX = 1, self.image:getWidth() / self.frameWidth do
            local quad = love.graphics.newQuad(
                (frameX - 1) * (self.frameWidth + padding),
                (frameY - 1) * (self.frameHeight + padding),
                self.frameWidth, self.frameHeight,
                self.paddedImage:getWidth(), self.paddedImage:getHeight()
            )
            table.insert(self.frames, quad)
        end
    end
end

function Sprite:add(
        animationName, animationFrames, animationFps, loopAnimation, complete
    )
    self.complete = complete
    local animationFps = animationFps or 1
    local loopAnimation = loopAnimation or true
    self.animations[animationName] = {
        frames = animationFrames, fps = animationFps, loop = loopAnimation
    }
end

function Sprite:play(animationName)
    if self.currentAnimation ~= self.animations[animationName] then
        self.currentAnimationIndex = 1
        self.elapsed = 0
        self.currentAnimation = self.animations[animationName]
    end
end

function Sprite:update(dt)
    self.elapsed = self.elapsed + dt
    local timePerFrame = 1 / self.currentAnimation.fps
    if self.elapsed > timePerFrame then
        self.elapsed = self.elapsed - timePerFrame
        self.currentAnimationIndex = self.currentAnimationIndex + 1
        if not self.currentAnimation.frames[self.currentAnimationIndex] then
            if self.currentAnimation.loop then
                self.currentAnimationIndex = 1
            else
                self.currentAnimationIndex = self.currentAnimationIndex - 1
            end
            if self.complete then
                self.complete()
            end
        end
    end
end
