Sprite = class("Sprite")

function Sprite:initialize(path, frameWidth, frameHeight)
    self.image = love.graphics.newImage(path)
    self.frameWidth = frameWidth
    self.frameHeight = frameHeight
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
    for frameY = 1, self.image:getHeight() / frameHeight do
        for frameX = 1, self.image:getWidth() / frameWidth do
            table.insert(
                self.frames,
                love.graphics.newQuad(
                    (frameX - 1) * frameWidth, (frameY - 1) * frameHeight,
                    frameWidth, frameHeight,
                    self.image:getWidth(), self.image:getHeight()
                )
            )
        end
    end
end

function Sprite:add(animationName, animationFrames, animationFps, loopAnimation)
    local animationFps = animationFps or 1
    local loopAnimation = loopAnimation or false
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
        end
    end
end
