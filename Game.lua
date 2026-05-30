local Grid = require('Grid')
local Camera = require('Camera')

---@class Game
local Game = {}
Game.__index = Game

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

---@param chunk_size integer?
function Game.new(chunk_size)
    chunk_size = chunk_size or 64
    local atlas = love.graphics.newArrayImage(TILE_PATHS)

    ---@class Game
    local self = {
        atlas = atlas,
        camera = Camera.new(),
        grid = Grid.new(atlas, chunk_size),
        hover_tile_x = nil, ---@type integer?
        hover_tile_y = nil, ---@type integer?
        hover_tile_type = nil, ---@type Tile?
    }

    self.grid:generateStartingChunk()

    return setmetatable(self, Game)
end

function Game:draw()
    self.grid:draw(self.camera, self.hover_tile_x, self.hover_tile_y, self.hover_tile_type)
end

function Game:mousemoved(x, y, dx, dy, istouch)
    self.hover_tile_x, self.hover_tile_y = self.grid:getTileCoordinate(self.camera, x, y)
    if love.mouse.isDown(1) and self.hover_tile_type then
        self.grid:place(self.hover_tile_x, self.hover_tile_y, self.hover_tile_type)
    end
    if love.mouse.isDown(2) then
        self.camera.center_x = self.camera.center_x - dx / self.camera.zoom
        self.camera.center_y = self.camera.center_y - dy / self.camera.zoom
    end
end

function Game:mousereleased(x, y, button, istouch, presses)
    self.hover_tile_x, self.hover_tile_y = self.grid:getTileCoordinate(self.camera, x, y)
    if button == 1 and self.hover_tile_type then
        self.grid:place(self.hover_tile_x, self.hover_tile_y, self.hover_tile_type)
    end
end

function Game:wheelmoved(x, y)
    self.camera.zoom = math.max(0.33, math.min(self.camera.zoom * (2 ^ (y * 3e-2)), 3))
end

function Game:keyreleased(key, scancode, isrepeat)
    if scancode == "1" then
        self.hover_tile_type = "road"
    elseif scancode == "2" then
        self.hover_tile_type = "factory"
    elseif scancode == "3" then
        self.hover_tile_type = "forest"
    elseif scancode == "4" then
        self.hover_tile_type = "anitkabir"
    elseif scancode == "5" then
        self.hover_tile_type = "atakule"
    elseif scancode == "6" then
        self.hover_tile_type = "cso"
    elseif scancode == "7" then
        self.hover_tile_type = "tech_bridge"
    elseif scancode == "0" then
        self.hover_tile_type = nil
    end
end

return Game
