local Chunk = require('Chunk')

local CONFIG = {
    sizes = {
        road = 1,
        factory = 3,
        forest = 3,
        anitkabir = 7,
        atakule = 5,
        cso = 5,
        tech_bridge = 5,

        house = 2,
        grand_national_assembly = 5,
    }, ---@type table<Tile, integer>
}

local TILE_SIZE = 16

---@class Grid
local Grid = {}
Grid.__index = Grid

---@param atlas love.Image
---@param chunk_size integer?
---@return Grid
function Grid.new(atlas, chunk_size)
    chunk_size = chunk_size or 64
    assert(chunk_size > 6, "Chunk size too small")
    atlas:setFilter('nearest', 'nearest')
    local atlas_tile_width, atlas_tile_height = atlas:getDimensions()
    local scale = TILE_SIZE / atlas_tile_width

    ---@class Grid
    local ret = {
        atlas = atlas,
        chunk_size = chunk_size,
        chunks = {}, ---@type Chunk[][]
        scale = scale,
        scaled_chunk_size = chunk_size * scale,
        empty_chunk = Chunk.new(atlas, chunk_size),
    }

    return setmetatable(ret, Grid)
end

function Grid:generateStartingChunk()
    for y = 1, CONFIG.sizes.grand_national_assembly do
        for x = 1, CONFIG.sizes.grand_national_assembly do
            self:place(x, y, "grand_national_assembly")
        end
    end
    self:place(math.ceil(CONFIG.sizes.grand_national_assembly / 2), CONFIG.sizes.grand_national_assembly + 1, 'road')
end

---@param x integer
---@param y integer
---@return Chunk
function Grid:getChunk(x, y)
    if not self.chunks[y] then
        self.chunks[y] = {}
    end
    if not self.chunks[y][x] then
        self.chunks[y][x] = Chunk.new(self.atlas, self.chunk_size)
    end
    return self.chunks[y][x]
end

---@param x integer
---@param y integer
---@param new_value Tile
---@return Tile old_value
function Grid:place(x, y, new_value)
    x = x - 1
    y = y - 1
    local chunk_x = math.floor(x / self.chunk_size) + 1
    local chunk_y = math.floor(y / self.chunk_size) + 1
    local inner_x = x % self.chunk_size + 1
    local inner_y = y % self.chunk_size + 1
    return self:getChunk(chunk_x, chunk_y):place(inner_x, inner_y, new_value)
end

---@param zoom number
---@param top_left_x integer
---@param top_left_y integer
---@param bottom_right_x integer
---@param bottom_right_y integer
function Grid:draw(zoom, top_left_x, top_left_y, bottom_right_x, bottom_right_y)
    local top_left_tile_x, top_left_tile_y =
        math.floor(top_left_x / TILE_SIZE), math.floor(top_left_y / TILE_SIZE)
    local bottom_right_tile_x, bottom_right_tile_y =
        math.ceil(bottom_right_x / TILE_SIZE), math.ceil(bottom_right_y / TILE_SIZE)
    local top_left_chunk_x, top_left_chunk_y =
        math.floor(top_left_tile_x / self.chunk_size), math.floor(top_left_tile_y / self.chunk_size)
    local bottom_right_chunk_x, bottom_right_chunk_y =
        math.ceil(bottom_right_tile_x / self.chunk_size), math.ceil(bottom_right_tile_y / self.chunk_size)

    local size = math.floor(self.scaled_chunk_size * zoom)
    local offset_x = math.floor(top_left_x * zoom)
    local offset_y = math.floor(top_left_y * zoom)

    for y = top_left_chunk_y, bottom_right_chunk_y do
        for x = top_left_chunk_x, bottom_right_chunk_x do
            if self.chunks[y] and self.chunks[y][x] then
                love.graphics.draw(
                    self.chunks[y][x].batch,
                    size * (x - 1) - offset_x,
                    size * (y - 1) - offset_y,
                    0,
                    self.scale * zoom
                )
            else
                love.graphics.draw(
                    self.empty_chunk.batch,
                    size * (x - 1) - offset_x,
                    size * (y - 1) - offset_y,
                    0,
                    self.scale * zoom
                )
            end
        end
    end
end

return Grid
