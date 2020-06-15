Sprite = class("Sprite")

function Sprite:initialize(path, frameWidth, frameHeight)
    self.image = love.graphics.newImage(path)
    self.frames = {}
    self.animations = {}
    self.currentAnimation = {1}
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
            print('insert')
        end
    end
end

function Sprite:add(animationName, animationFrames)
    self.animations[animationName] = animationFrames
end

function Sprite:play(animationName)
    self.currentAnimation = self.animations[animationName]
end
