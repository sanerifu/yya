local Grid       = require('Grid')
local Camera     = require('Camera')
local inspect    = require('lib.inspect')

local g ---@type Grid
local c ---@type Camera

local TILES      = { ---@type Tile[]
    "empty",
    "road",
    "factory",
    "forest",
    "anitkabir",
    "atakule",
    "cso",
    "tech_bridge",
    "house",
    "grand_national_assembly",
}

local TILE_PATHS = {} ---@type string[]
for i = 1, #TILES do
    TILE_PATHS[i] = ("assets/%s.png"):format(TILES[i])
end

function love.load()
    local building_atlas = love.graphics.newArrayImage(TILE_PATHS)
    g = Grid.new(building_atlas)
    c = Camera.new()
    g:generateStartingChunk()
end

function love.draw()
    g:draw(c.zoom, c:getBoundingBox())
end

function love.mousemoved(x, y, dx, dy, istouch)
    if love.mouse.isDown(2) then
        c.center_x = c.center_x - dx / c.zoom
        c.center_y = c.center_y - dy / c.zoom
    end
end

function love.wheelmoved(x, y)
    c.zoom = math.max(0.33, math.min(c.zoom * (2 ^ (y * 3e-2)), 3))
end
