local Chunk = require('Chunk')
local Tile = require('Tile')

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
    local scale = Tile.pixels / atlas_tile_width

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
    for y = 1, Tile.sizes.grand_national_assembly do
        for x = 1, Tile.sizes.grand_national_assembly do
            self:set(x, y, "grand_national_assembly")
        end
    end
    self:set(math.ceil(Tile.sizes.grand_national_assembly / 2), Tile.sizes.grand_national_assembly + 1, 'road')
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
function Grid:set(x, y, new_value)
    x = x - 1
    y = y - 1
    local chunk_x = math.floor(x / self.chunk_size) + 1
    local chunk_y = math.floor(y / self.chunk_size) + 1
    local inner_x = x % self.chunk_size + 1
    local inner_y = y % self.chunk_size + 1
    return self:getChunk(chunk_x, chunk_y):place(inner_x, inner_y, new_value)
end

---@param x integer
---@param y integer
---@param new_value Tile
function Grid:place(x, y, new_value)
    for yy = y, y + Tile.sizes[new_value] - 1 do
        for xx = x, x + Tile.sizes[new_value] - 1 do
            self:set(xx, yy, new_value)
        end
    end
end

---@param camera Camera
---@param hover_tile_x integer?
---@param hover_tile_y integer?
---@param hover_tile_type Tile?
function Grid:draw(camera, hover_tile_x, hover_tile_y, hover_tile_type)
    local zoom = camera.zoom
    local top_left_x, top_left_y, bottom_right_x, bottom_right_y = camera:getBoundingBox()
    local top_left_tile_x, top_left_tile_y =
        math.floor(top_left_x / Tile.pixels), math.floor(top_left_y / Tile.pixels)
    local bottom_right_tile_x, bottom_right_tile_y =
        math.ceil(bottom_right_x / Tile.pixels), math.ceil(bottom_right_y / Tile.pixels)
    local top_left_chunk_x, top_left_chunk_y =
        math.floor(top_left_tile_x / self.chunk_size), math.floor(top_left_tile_y / self.chunk_size)
    local bottom_right_chunk_x, bottom_right_chunk_y =
        math.ceil(bottom_right_tile_x / self.chunk_size), math.ceil(bottom_right_tile_y / self.chunk_size)

    local scaled_tile_size = self.scale * zoom
    local size = self.scaled_chunk_size * zoom
    local offset_x = top_left_x * zoom
    local offset_y = top_left_y * zoom

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

    if hover_tile_x and hover_tile_y and hover_tile_type and Tile.sizes[hover_tile_type] then
        local hover_size = Tile.sizes[hover_tile_type]
        local r, g, b, a = love.graphics.getColor()
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.drawLayer(
            self.atlas,
            Tile.indices[hover_tile_type],
            scaled_tile_size * (hover_tile_x - 1) - offset_x,
            scaled_tile_size * (hover_tile_y - 1) - offset_y,
            0,
            scaled_tile_size * hover_size,
            scaled_tile_size * hover_size
        )
        love.graphics.setColor(r, g, b, a)
    end
end

---@param camera Camera
---@param x integer
---@param y integer
---@return integer tile_x
---@return integer tile_y
function Grid:getTileCoordinate(camera, x, y)
    local zoom = camera.zoom
    local top_left_x, top_left_y, bottom_right_x, bottom_right_y = camera:getBoundingBox()
    local size = Tile.pixels * zoom
    local offset_x = top_left_x * zoom
    local offset_y = top_left_y * zoom

    local tile_x = math.floor((x + offset_x) / size + 1)
    local tile_y = math.floor((y + offset_y) / size + 1)

    return tile_x, tile_y
end

return Grid
