Paddle = Class{}

-- paddle instantiation function
function Paddle:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    
    self.dy = 0
end

-- updating paddle's position
function Paddle:update(dt)
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    elseif self.dy > 0 then
        self.y = math.min(VIRTUAL_HEIGHT - 30, self.y + self.dy * dt)
    end
end

-- rendering paddle
function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
