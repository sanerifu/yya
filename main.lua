local config = require('config')
local TILE_PATHS = {} ---@type string[]
for i = 1, #config.tiles do
    TILE_PATHS[i] = ("%s%s.png"):format(config.asset_path, config.tiles[i])
end

local game ---@type Game

function love.load()
    local tiles = love.graphics.newArrayImage(TILE_PATHS) ---@type love.Image

    ---@class Game
    game = {
        ---@class Assets
        assets = {
            tiles = tiles,
        },

        ---@class Camera
        camera = {
            center_x = 0, ---@type number
            center_y = 0, ---@type number
            zoom = 1, ---@type number
        },

        ---@class Tiles
        tiles = {
            type = {}, ---@type Tile[]
        },

        ---@class Chunks
        chunks = {
            tile = {}, ---@type integer[]
            dirty = {}, ---@type boolean[]

            mapping = {}, ---@type integer[][]
        },

        ---@class TileData
        ghost = {
            x = 0, ---@type integer
            y = 0, ---@type integer
            tile = 'empty', ---@type Tile
        },

        money = config.starting_money,
        chunk_size = config.chunk_size,
    }
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
