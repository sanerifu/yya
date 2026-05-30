require('table.new')

local Tile = require('Tile')

---@alias Tile "empty" | "road" | "factory" | "forest" | "anitkabir" | "atakule" | "cso" | "tech_bridge" | "house" | "grand_national_assembly"

---@param x number
---@param y number
---@param width number
---@return number
local function flatten(x, y, width)
    x = x - 1
    y = y - 1
    local ret = y * width + x
    ret = ret + 1
    return ret
end

---@class Chunk
local Chunk = {}
Chunk.__index = Chunk

---@param atlas love.Image
---@param size number?
function Chunk.new(atlas, size)
    local tile_width, tile_height = atlas:getDimensions()
    size = size or 64
    ---@class Chunk
    local self = {
        size = size,
        grid = table.new(size, 0), ---@type Tile[]
        counts = { ---@type table<Tile, integer>
            empty = size * size,
            road = 0,
            factory = 0,
            forest = 0,
            anitkabir = 0,
            atakule = 0,
            cso = 0,
            tech_bridge = 0,
            house = 0,
            grand_national_assembly = 0,
        },
        batch = love.graphics.newSpriteBatch(atlas),
        batch_indices = table.new(size, 0), ---@type number[]
        tile_width = tile_width, ---@type integer
        tile_height = tile_height, ---@type integer
    }

    for y = 1, size do
        for x = 1, size do
            local index = flatten(x, y, self.size)
            self.grid[index] = "empty"
            self.batch_indices[index] = self.batch:addLayer(
                Tile.indices.empty,
                tile_width * (x - 1),
                tile_height * (y - 1)
            )
        end
    end
    return setmetatable(self, Chunk)
end

---@param x integer
---@param y integer
---@param new_value Tile
---@return Tile old_value
function Chunk:set(x, y, new_value)
    assert(Tile.indices[new_value], ("Invalid tile: %q"):format(new_value))
    assert(1 <= x and x <= self.size, ("Out of bounds X: %q"):format(x))
    assert(1 <= y and y <= self.size, ("Out of bounds Y: %q"):format(y))

    local index = flatten(x, y, self.size)
    local old_value = self.grid[index]
    self.counts[old_value] = self.counts[old_value] - 1
    self.counts[new_value] = self.counts[new_value] + 1
    self.grid[index] = new_value
    self.batch:setLayer(
        self.batch_indices[index],
        Tile.indices[new_value],
        self.tile_width * (x - 1),
        self.tile_height * (y - 1)
    )

    return old_value
end

---@param x integer
---@param y integer
---@return Tile
function Chunk:get(x, y)
    assert(1 <= x and x <= self.size, ("Out of bounds X: %q"):format(x))
    assert(1 <= y and y <= self.size, ("Out of bounds Y: %q"):format(y))

    local index = flatten(x, y, self.size)
    return self.grid[index]
end

function Chunk:getDimensions()
    return self.size * self.tile_width, self.size * self.tile_height
end

return Chunk
