local config = require('config')

local module = {}

---@param tiles Tiles
---@param type Tile
---@return integer index
function module.makeTile(tiles, type)
    table.insert(tiles.type, type)
    return #tiles.type
end

---@param tiles Tiles
---@param chunks Chunks
---@param x integer
---@param y integer
---@return integer index
function module.makeChunk(tiles, chunks, x, y)
    local tile_index = #tiles.type + 1
    local total = config.chunk_size * config.chunk_size

    table.insert(chunks.tile, tile_index)
    table.insert(chunks.dirty, true)

    for _ = 1, total do
        module.makeTile(tiles, "empty")
    end

    local index = #chunks.tile
    if not chunks.mapping[y] then
        chunks.mapping[y] = {}
    end

    chunks.mapping[y][x] = index

    return index
end

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

---@param tiles Tiles
---@param chunks Chunks
---@param x integer
---@param y integer
---@return integer tile_index
---@return integer chunk_index
function module.getTile(tiles, chunks, x, y)
    local chunk_x, chunk_y =
        math.floor(x / config.chunk_size), math.floor(y / config.chunk_size)
    local tile_x, tile_y =
        x % config.chunk_size, y % config.chunk_size

    if not chunks.mapping[chunk_y] or not chunks.mapping[chunk_y][chunk_x] then
        module.makeChunk(tiles, chunks, chunk_x, chunk_y)
    end

    local chunk_index = chunks.mapping[chunk_y][chunk_x]
    local tile_start = chunks.tile[chunk_index]

    local flattened = flatten(tile_x, tile_y, config.chunk_size)
    return tile_start + flattened - 1, chunk_index
end

---@param tiles Tiles
---@param chunks Chunks
---@param x integer
---@param y integer
---@param tile Tile
---@return Tile old_tile
function module.setTile(tiles, chunks, x, y, tile)
    local tile_index, chunk_index = module.getTile(tiles, chunks, x, y)

    local old_tile = tiles.type[tile_index]
    tiles.type[tile_index] = tile
    chunks.dirty[chunk_index] = true
    return old_tile
end

---@param tiles Tiles
---@param chunks Chunks
---@param x integer
---@param y integer
---@param building Tile
function module.placeBuilding(tiles, chunks, x, y, building)
    local size = config.sizes[building]
    for yy = y, y + size - 1 do
        for xx = x, x + size - 1 do
            module.setTile(tiles, chunks, xx, yy, building)
        end
    end
end

return module
