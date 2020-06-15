Sprite = class("Sprite")

function Sprite:initialize(path, frameWidth, frameHeight)
    self.image = love.graphics.newImage(path)
    self.frames = {}
    self.animations = {}
    self.currentAnimation = {frames = {1}, fps = 1}
    self.currentAnimationIndex = 1
    self.elapsed = 0
    for frameX = 1, self.image:getWidth() / frameWidth do
        for frameY = 1, self.image:getHeight() / frameHeight do
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

function Sprite:add(animationName, animationFrames, animationFps)
    fps = fps or 1
    self.animations[animationName] = {frames = animationFrames, fps = animationFps}
end

function Sprite:play(animationName)
    self.currentAnimation = self.animations[animationName]
end

function Sprite:update(dt)
    self.elapsed = self.elapsed + dt
    local timePerFrame = 1 / self.currentAnimation.fps
    if self.elapsed > timePerFrame then
        self.elapsed = self.elapsed - timePerFrame
        self.currentAnimationIndex = self.currentAnimationIndex + 1
        if not self.currentAnimation.frames[self.currentAnimationIndex] then
            self.currentAnimationIndex = 1
        end

    end
end
