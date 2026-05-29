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

local ATLAS_WIDTH = 16
local ATLAS_HEIGHT = 16

local TILE_OFFSETS = {
    x = {
        empty = 0 / ATLAS_WIDTH,
        road = 1 / ATLAS_WIDTH,
        factory = 2 / ATLAS_WIDTH,
        forest = 3 / ATLAS_WIDTH,
        anitkabir = 4 / ATLAS_WIDTH,
        atakule = 5 / ATLAS_WIDTH,
        cso = 6 / ATLAS_WIDTH,
        tech_bridge = 7 / ATLAS_WIDTH,
        house = 8 / ATLAS_WIDTH,
        grand_national_assembly = 9 / ATLAS_WIDTH,
    },
    y = {
        empty = 0 / ATLAS_HEIGHT,
        road = 0 / ATLAS_HEIGHT,
        factory = 0 / ATLAS_HEIGHT,
        forest = 0 / ATLAS_HEIGHT,
        anitkabir = 0 / ATLAS_HEIGHT,
        atakule = 0 / ATLAS_HEIGHT,
        cso = 0 / ATLAS_HEIGHT,
        tech_bridge = 0 / ATLAS_HEIGHT,
        house = 0 / ATLAS_HEIGHT,
        grand_national_assembly = 0 / ATLAS_HEIGHT,
    },
}

---@param atlas_width integer
---@param atlas_height integer
---@param atlas_tile_width integer
---@param atlas_tile_height integer
---@param type string
---@return love.Quad
local function makeQuad(atlas_width, atlas_height, atlas_tile_width, atlas_tile_height, type)
    return love.graphics.newQuad(
        TILE_OFFSETS.x[type] * atlas_width,
        TILE_OFFSETS.y[type] * atlas_height,
        atlas_tile_width,
        atlas_tile_height,
        atlas_width,
        atlas_height
    )
end

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

    local atlas_width, atlas_height = atlas:getDimensions()
    local atlas_tile_width, atlas_tile_height =
        math.floor(atlas_width / ATLAS_WIDTH), math.floor(atlas_height / ATLAS_HEIGHT)
    local scale = TILE_SIZE / atlas_tile_width
    local quads = { ---@type table<Tile, love.Quad>
        empty = makeQuad(atlas_width, atlas_height, atlas_tile_width, atlas_tile_height, 'empty'),
        road = makeQuad(atlas_width, atlas_height, atlas_tile_width, atlas_tile_height, 'road'),
        factory = makeQuad(atlas_width, atlas_height, atlas_tile_width, atlas_tile_height, 'factory'),
        forest = makeQuad(atlas_width, atlas_height, atlas_tile_width, atlas_tile_height, 'forest'),
        anitkabir = makeQuad(atlas_width, atlas_height, atlas_tile_width, atlas_tile_height, 'anitkabir'),
        atakule = makeQuad(atlas_width, atlas_height, atlas_tile_width, atlas_tile_height, 'atakule'),
        cso = makeQuad(atlas_width, atlas_height, atlas_tile_width, atlas_tile_height, 'cso'),
        tech_bridge = makeQuad(atlas_width, atlas_height, atlas_tile_width, atlas_tile_height, 'tech_bridge'),
        house = makeQuad(atlas_width, atlas_height, atlas_tile_width, atlas_tile_height, 'house'),
        grand_national_assembly = makeQuad(atlas_width, atlas_height, atlas_tile_width, atlas_tile_height,
            'grand_national_assembly'),
    }

    ---@class Grid
    local ret = {
        atlas = atlas,
        chunk_size = chunk_size,
        chunks = {}, ---@type Chunk[][]
        scale = scale,
        scaled_chunk_size = chunk_size * scale,
        empty_chunk = Chunk.new(atlas, quads, chunk_size),
        quads = quads,
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
        self.chunks[y][x] = Chunk.new(self.atlas, self.quads, self.chunk_size)
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

    for y = top_left_chunk_y, bottom_right_chunk_y do
        for x = top_left_chunk_x, bottom_right_chunk_x do
            if self.chunks[y] and self.chunks[y][x] then
                love.graphics.draw(
                    self.chunks[y][x].batch,
                    self.scaled_chunk_size * zoom * (x - 1) - top_left_x * zoom,
                    self.scaled_chunk_size * zoom * (y - 1) - top_left_y * zoom,
                    0,
                    self.scale * zoom
                )
            else
                love.graphics.draw(
                    self.empty_chunk.batch,
                    self.scaled_chunk_size * zoom * (x - 1) - top_left_x * zoom,
                    self.scaled_chunk_size * zoom * (y - 1) - top_left_y * zoom,
                    0,
                    self.scale * zoom
                )
            end
        end
    end
end

return Grid
