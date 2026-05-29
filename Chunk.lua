require('table.new')

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

local TILE_CHECKER = {
    empty = true,
    road = true,
    factory = true,
    forest = true,
    anitkabir = true,
    atakule = true,
    cso = true,
    tech_bridge = true,
    house = true,
    grand_national_assembly = true,
} ---@type table<Tile, boolean>

---@class Chunk
local Chunk = {}
Chunk.__index = Chunk

---@param size number?
function Chunk.new(size)
    size = size or 64
---@diagnostic disable-next-line: undefined-field
    local grid = table.new(size, 0) ---@type Tile[]
    local total = size * size
    for i = 1, total do
        grid[i] = "empty"
    end

    ---@class Chunk
    local ret = {
        size = size,
        grid = grid,
        counts = {
            empty = total,
            road = 0,
            factory = 0,
            forest = 0,
            anitkabir = 0,
            atakule = 0,
            cso = 0,
            tech_bridge = 0,
            house = 0,
            grand_national_assembly = 0,
        } ---@type table<Tile, number>
    }
    return setmetatable(ret, Chunk)
end

---@param x integer
---@param y integer
---@param new_value Tile
---@return Tile old_value
function Chunk:place(x, y, new_value)
    assert(TILE_CHECKER[new_value], ("Invalid tile: %q"):format(new_value))
    assert(1 <= x and x <= self.size, ("Out of bounds X: %q"):format(x))
    assert(1 <= y and y <= self.size, ("Out of bounds Y: %q"):format(y))

    local index = flatten(x, y, self.size)
    local old_value = self.grid[index]
    self.counts[old_value] = self.counts[old_value] - 1
    self.counts[new_value] = self.counts[new_value] + 1
    self.grid[index] = new_value

    return old_value
end

return Chunk
