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

local TILE_OFFSETS = {
    x = {
        empty = 0 / 16,
        road = 1 / 16,
        factory = 2 / 16,
        forest = 3 / 16,
        anitkabir = 4 / 16,
        atakule = 5 / 16,
        cso = 6 / 16,
        tech_bridge = 7 / 16,
        house = 8 / 16,
        grand_national_assembly = 9 / 16,
    },
    y = {
        empty = 0 / 16,
        road = 0 / 16,
        factory = 0 / 16,
        forest = 0 / 16,
        anitkabir = 0 / 16,
        atakule = 0 / 16,
        cso = 0 / 16,
        tech_bridge = 0 / 16,
        house = 0 / 16,
        grand_national_assembly = 0 / 16,
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

---@class Grid
local Grid = {}
Grid.__index = Grid

---@param atlas love.Image
---@param chunk_size integer?
---@return Grid
function Grid.new(atlas, chunk_size)
    chunk_size = chunk_size or 64
    assert(chunk_size > 6, "Chunk size too small")

    local atlas_width, atlas_height = atlas:getDimensions()
    local atlas_tile_width, atlas_tile_height = math.floor(atlas_width / 16), math.floor(atlas_height / 16)

    ---@class Grid
    local ret = {
        atlas = atlas,
        chunk_size = chunk_size,
        chunks = {}, ---@type Chunk[][]
        quads = {
            empty = makeQuad(atlas_width, atlas_height, atlas_tile_width, atlas_tile_height, 'empty'),
            road = makeQuad(atlas_width, atlas_height, atlas_tile_width, atlas_tile_height, 'road'),
            factory = makeQuad(atlas_width, atlas_height, atlas_tile_width, atlas_tile_height, 'factory'),
            forest = makeQuad(atlas_width, atlas_height, atlas_tile_width, atlas_tile_height, 'forest'),
            anitkabir = makeQuad(atlas_width, atlas_height, atlas_tile_width, atlas_tile_height, 'anitkabir'),
            atakule = makeQuad(atlas_width, atlas_height, atlas_tile_width, atlas_tile_height, 'atakule'),
            cso = makeQuad(atlas_width, atlas_height, atlas_tile_width, atlas_tile_height, 'cso'),
            tech_bridge = makeQuad(atlas_width, atlas_height, atlas_tile_width, atlas_tile_height, 'tech_bridge'),
            house = makeQuad(atlas_width, atlas_height, atlas_tile_width, atlas_tile_height, 'house'),
            grand_national_assembly = makeQuad(atlas_width, atlas_height, atlas_tile_width, atlas_tile_height, 'grand_national_assembly'),
        }, ---@type table<Tile, love.Quad>
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

function Grid:draw()
    love.graphics.draw(self.chunks[1][1].batch)
end

return Grid
