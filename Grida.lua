require('table.new')
local Config = require('Config')
local Event = require('Event')

---@class Grid
local Grid = {}
Grid.__index = Grid

function Grid:generateStartingChunk()
    for y = -2, Config.sizes.grand_national_assembly - 3 do
        for x = -2, Config.sizes.grand_national_assembly - 3 do
            self:set(x, y, "grand_national_assembly")
        end
    end
    self:set(math.ceil(Config.sizes.grand_national_assembly / 2) - 3, Config.sizes.grand_national_assembly - 2, 'road')
end

---@param x integer
---@param y integer
---@param new_value Tile
---@return boolean is_placed
function Grid:place(x, y, new_value)
    if not self:isValid(x, y, new_value) then
        return false
    end
    local size = Config.sizes[new_value]
    for yy = y, y + size - 1 do
        for xx = x, x + size - 1 do
            self:set(xx, yy, new_value)
        end
    end

    return true
end

---@param camera Camera
---@param is_hover_buildable boolean
---@param hover_tile_x integer?
---@param hover_tile_y integer?
---@param hover_tile_type Tile?
function Grid:draw(camera, is_hover_buildable, hover_tile_x, hover_tile_y, hover_tile_type)
    -- local zoom = camera.zoom
    -- local top_left_x, top_left_y, bottom_right_x, bottom_right_y = camera:getBoundingBox()
    -- local top_left_tile_x, top_left_tile_y =
    --     math.floor(top_left_x / Config.pixels), math.floor(top_left_y / Config.pixels)
    -- local bottom_right_tile_x, bottom_right_tile_y =
    --     math.ceil(bottom_right_x / Config.pixels), math.ceil(bottom_right_y / Config.pixels)
    -- local top_left_chunk_x, top_left_chunk_y =
    --     math.floor(top_left_tile_x / self.chunk_size), math.floor(top_left_tile_y / self.chunk_size)
    -- local bottom_right_chunk_x, bottom_right_chunk_y =
    --     math.ceil(bottom_right_tile_x / self.chunk_size), math.ceil(bottom_right_tile_y / self.chunk_size)

    -- local scaled_tile_size = self.scale * zoom
    -- local size = self.scaled_chunk_size * zoom
    -- local offset_x = top_left_x * zoom
    -- local offset_y = top_left_y * zoom

    -- for y = top_left_chunk_y, bottom_right_chunk_y do
    --     for x = top_left_chunk_x, bottom_right_chunk_x do
    --         if self.chunks[y] and self.chunks[y][x] then
    --             love.graphics.draw(
    --                 self.chunks[y][x].batch,
    --                 size * (x - 1) - offset_x,
    --                 size * (y - 1) - offset_y,
    --                 0,
    --                 self.scale * zoom
    --             )
    --         else
    --             love.graphics.draw(
    --                 self.empty_chunk.batch,
    --                 size * (x - 1) - offset_x,
    --                 size * (y - 1) - offset_y,
    --                 0,
    --                 self.scale * zoom
    --             )
    --         end
    --     end
    -- end

    -- if hover_tile_x and hover_tile_y and hover_tile_type and Config.sizes[hover_tile_type] then
    --     local hover_size = Config.sizes[hover_tile_type]
    --     local r, g, b, a = love.graphics.getColor()
    --     if is_hover_buildable then
    --         love.graphics.setColor(0, 1, 0, 0.5)
    --     else
    --         love.graphics.setColor(1, 0, 0, 0.5)
    --     end
    --     love.graphics.drawLayer(
    --         self.atlas,
    --         Config.indices[hover_tile_type],
    --         scaled_tile_size * (hover_tile_x - 1) - offset_x,
    --         scaled_tile_size * (hover_tile_y - 1) - offset_y,
    --         0,
    --         scaled_tile_size * hover_size,
    --         scaled_tile_size * hover_size
    --     )
    --     love.graphics.setColor(r, g, b, a)
    -- end
end

---@param camera Camera
---@param x integer
---@param y integer
---@return integer tile_x
---@return integer tile_y
function Grid:getTileCoordinate(camera, x, y)
    local zoom = camera.zoom
    local top_left_x, top_left_y, bottom_right_x, bottom_right_y = camera:getBoundingBox()
    local size = Config.pixels * zoom
    local offset_x = top_left_x * zoom
    local offset_y = top_left_y * zoom

    local tile_x = math.floor((x + offset_x) / size + 1)
    local tile_y = math.floor((y + offset_y) / size + 1)

    return tile_x, tile_y
end

---@param x integer
---@param y integer
---@param tile Tile
---@return boolean
function Grid:isValid(x, y, tile)
    assert(Config.sizes[tile], ("Cannot place tile %q"):format(tile))

    local size = Config.sizes[tile]
    for yy = y, y + size - 1 do
        for xx = x, x + size - 1 do
            if self:get(xx, yy) ~= "empty" then
                return false
            end
        end
    end

    return true;
end

return Grid
