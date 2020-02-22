-- Setting up global values
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200
BALL_SPEED = 300

-- Loading other files
Class = require 'class'
push = require 'push'

require 'Ball'
require 'Paddle'

function love.load()
    -- generate randomseed each time of the game to ensure no consistency between games and games
    math.randomseed(os.time())

    -- setting up a filter with the mode "point" to make graphics appear crispy
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- intiatlize game name to "Pong"
    love.window.setTitle('Pong')

    -- initialize virtual resolution, which will be rendered within our actual window
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    -- create font objects
    fpsFont = love.graphics.newFont('font2.ttf', 6)
    smallFont = love.graphics.newFont('font2.ttf', 8)
    scoreFont = love.graphics.newFont('font2.ttf', 32)
    victoryFont = love.graphics.newFont('font2.ttf', 15)
    
    -- set sounds
    sounds = {
        ['hit'] = love.audio.newSource('blip.wav', 'static'),
        ['wall'] = love.audio.newSource('wall_hit.wav', 'static'),
        ['goal'] = love.audio.newSource('goal.wav', 'static'),
        ['victory'] = love.audio.newSource('victory.wav', 'static')
    }

    -- initialize player scores to 0
    player1Score = 0
    player2Score = 0

    servingPlayer = math.random(2) == 1 and 1 or 2

    winningPlayer = 0

    -- instantiate paddle objects
    paddle1 = Paddle(5, 20, 5, 30)
    paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 30)

    -- instantiate ball object
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 5, 5)

    if servingPlayer == 1 then
        ball.dx = BALL_SPEED
    else
        ball.dx = -BALL_SPEED
    end

    -- initialize game state to "start"
    gameState = 'start'
    AIsync()
end

function love.resize(w, h)
    push:resize(w, h)
end

-- player 1 movement
function love.update(dt)
    if gameState == 'play' then
        if ball.x <= 0 then
            player2Score = player2Score + 1
            sounds['goal']:play()
            servingPlayer = 1
            ball:reset()
            AIsync()
            ball.dx = BALL_SPEED

            if player2Score >= 2 then
                gameState = 'victory'
                sounds['victory']:play()
                winningPlayer = 2
                player1Score = 0
                player2Score = 0
                AIsync()
            else
                gameState = 'serve'
            end
        end

        if ball.x >= VIRTUAL_WIDTH - 4 then
            player1Score = player1Score + 1
            sounds['goal']:play()
            servingPlayer = 2
            ball:reset()
            AIsync()
            ball.dx = -BALL_SPEED
            
            if player1Score >= 2 then
                gameState = 'victory'
                sounds['victory']:play()
                winningPlayer = 1
                player1Score = 0
                player2Score = 0
                AIsync()
            else
                gameState = 'serve'
            end
        end

        -- checking for paddle collisions
        if ball:collides(paddle1) then
            -- deflect the ball to the right
            ball.dx = -ball.dx
            ball:speedup()
            sounds['hit']:play()
        end
        if ball:collides(paddle2) then
            -- deflect the ball to the left
            ball.dx = -ball.dx
            ball:speedup()
            sounds['hit']:play()
        end

        -- checking for upper and lower bound collisions
        if ball.y <= 0 then
            -- deflect the ball down
            ball.dy = -ball.dy
            ball.y = 0
            sounds['wall']:play()
        end
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            -- deflect the ball up
            ball.dy = -ball.dy
            ball.y = VIRTUAL_HEIGHT - 4
            sounds['wall']:play()
        end

        -- detecting keyboard controls
        -- player1
        if love.keyboard.isDown('w') then
            -- add negative paddle speed to current Y scaled by deltaTime
            paddle1.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('s') then
            -- add positive paddle speed to current Y scaled by deltaTime
            paddle1.dy = PADDLE_SPEED
        else
            paddle1.dy = 0
        end
        -- player 2
        AItrack()

        -- update paddle/ball positions within the object
        paddle1:update(dt)
        paddle2:update(dt)
        ball:update(dt)
    end
end

-- detecting one time key presses
function love.keypressed(key)
    -- quitting
    if key == 'escape' then
        love.event.quit()
    -- starting/pausing
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'victory' then
            gameState = 'start'
        end
    end
end

-- rendering objects
function love.draw()
    push:apply('start')

    -- clear the screen with a specified color; in this case, a color similar
    -- to dark red blood
    love.graphics.clear(29 / 255, 0 / 255, 0 / 255, 255 / 255)

    -- render first and second paddle (left side)
    paddle1:render()
    paddle2:render()

    -- render ball
    ball:render()

    -- render FPS count
    displayFPS()

    -- set font
    love.graphics.setFont(smallFont)

    -- print in-game state messages
    if gameState == 'start' then
        love.graphics.printf("Welcome to Pong!~", 0, 35, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Enter to Play!", 0, 45, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.printf("Player " .. tostring(servingPlayer) .. "'s turn", 0, 35, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Enter to Serve!", 0, 45, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'victory' then
        love.graphics.setFont(victoryFont)
        love.graphics.printf("Player" .. tostring(winningPlayer) .. " wins!", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Enter to Restart!", 0, 45, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
    end

    -- print scores
    displayScore()
    
    -- end rendering at virtual resolution
    push:apply('end')
end

-- literally displays frame per second at the top left corner
function displayFPS()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(fpsFont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 5, 2)
    love.graphics.setColor(1, 1, 1, 1)
end

-- display scores
function displayScore()
    love.graphics.setFont(scoreFont)
    love.graphics.print(player1Score, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(player2Score, VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end

function AIsync()
    paddle2.y = ball.y - 15
end

function AItrack()
    paddle2.dy = ball.dy
end