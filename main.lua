local Grid = require('Grid')
local inspect = require('lib.inspect')

local g

function love.load()
    local building_atlas = love.graphics.newImage("assets/tiles.png")
    g = Grid.new(building_atlas)
    g:generateStartingChunk()
    print(inspect(g))
end

function love.draw()
    g:draw()
    love.graphics.print("Hello, World!")
end
