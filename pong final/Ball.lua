Ball = Class{}

-- ball instantiation
function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    -- randomize x speed and y speed
    self.dx = math.random(2) == 1 and -100 or 100
    self.dy = math.random(-50, 50)
end

function Ball:speedup()
    if self.dx < 0 then
        self.dx = self.dx - 10
    else
        self.dx = self.dx + 10
    end
end

-- Axis Alligned Bounding Box collision detection
function Ball:collides(box)
    if self.x > box.x + box.width or self.x + self.width < box.x then
        return false
    end

    if self.y > box.y + box.height or self.y + self.height < box.y then
        return false
    end

    return true
end

-- updating ball's position
function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

-- rendering ball (center)
function Ball:render(ballX, ballY)
    love.graphics.rectangle('fill', self.x, self.y, 4, 4)
end

-- resetting ball's position
function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2;
    self.dx = math.random(2) == 1 and -100 or 100
    self.dy = math.random(-50, 50) * 1.5
end