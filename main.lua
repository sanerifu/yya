---@alias TileType "empty" | "road" | "factory" | "forest" | "anitkabir" | "cso" | "atakule" | "techbridge"

---@class Game
local Game = {}
Game.__index = Game

function Game.new()
    ---@class Game
    local self = {
        defines = require('defines'),

        tiles = {
            length = 0,
            type = {}, ---@type TileType[]
            buildable = {}, ---@type integer[]
        },

        chunks = {
            length = 0,
            start = {}, ---@type integer[]
            x = {}, ---@type integer[]
            y = {}, ---@type integer[]
        },

        chunk_mapping = {}, ---@type integer[][]
    }
    return setmetatable(self, Game)
end

---@param x integer
---@param y integer
---@return integer
function Game:getChunk(x, y)
    if self.chunk_mapping[y] and self.chunk_mapping[y][x] then
        return self.chunk_mapping[y][x]
    end
    local chunk_size = self.defines.CHUNK_SIZE * self.defines.CHUNK_SIZE

    local chunk_start = self.tiles.length + 1
    for i = 1, chunk_size do
        table.insert(self.tiles.type, "empty")
        table.insert(self.tiles.buildable, 0)
    end
    self.tiles.length = self.tiles.length + chunk_size
    self.chunks.length = self.chunks.length + 1
    table.insert(self.chunks.start, chunk_start)
    table.insert(self.chunks.x, x)
    table.insert(self.chunks.y, y)
    self.chunk_mapping[y] = self.chunk_mapping[y] or {}
    self.chunk_mapping[y][x] = self.chunks.length

    return self.chunks.length
end

---@param x integer
---@param y integer
---@return integer
function Game:getTileIndex(x, y)
    local chunk_x = math.floor(x / self.defines.CHUNK_SIZE)
    local chunk_y = math.floor(y / self.defines.CHUNK_SIZE)

    local local_x = x % self.defines.CHUNK_SIZE
    local local_y = y % self.defines.CHUNK_SIZE

    local chunk_index = self:getChunk(chunk_x, chunk_y)
    local local_index = self.chunks.start[chunk_index] + (local_y * self.defines.CHUNK_SIZE) + local_x

    return local_index
end

local game

function love.load()
    game = Game.new()
end

function love.update(dt)
end

function love.draw()
end
