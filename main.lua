local Game = require('Game')
local g ---@type Game

function love.load()
    g = Game.new(64)
end

function love.draw()
    g:draw()
end

function love.mousemoved(x, y, dx, dy, istouch)
    g:mousemoved(x, y, dx, dy, istouch)
end

function love.mousereleased(x, y, button, istouch, presses)
    g:mousereleased(x, y, button, istouch, presses)
end

function love.wheelmoved(x, y)
    g:wheelmoved(x, y)
end

function love.keyreleased(key, scancode, isrepeat)
    g:keyreleased(key, scancode, isrepeat)
end
