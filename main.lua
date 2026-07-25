local bit = require('bit')
local inspect = require('inspect')

---@alias TileType "empty" | "road" | "factory" | "forest" | "anitkabir" | "cso" | "atakule" | "techbridge"

---@class Game
local Game = {}
Game.__index = Game

---@param tiles table<TileType, any>
---@return TileType[], table<TileType, integer>
local function createTileArray(tiles)
    local ret = {}
    local indices = {}
    for tile in pairs(tiles) do
        table.insert(ret, tile)
        indices[tile] = #ret
    end
    return ret, indices
end

---@param tiles TileType[]
---@return table<TileType, integer>
local function calculateBuildableFlags(tiles)
    local ret = {}
    for i = 1, #tiles do
        local tile = tiles[i]
        ret[tile] = bit.lshift(1, i - 1)
    end
    return ret
end

---@param tiles TileType[]
---@return love.Image
local function loadSprites(tiles)
    local images = {} ---@type love.ImageData[]
    local width, height
    for i = 1, #tiles do
        local tile = tiles[i]
        table.insert(images, love.image.newImageData(("assets/%s.png"):format(tile)))
        width, height = images[#images]:getDimensions()
    end

    table.insert(images, love.image.newImageData(width, height))

    local ret = love.graphics.newArrayImage(images)
    return ret
end

---@param defines any
---@param sprites love.Image
---@param tile_indices table<TileType, integer>
---@param tile_scale number
local function generateChunkSprite(defines, sprites, tile_indices, tile_scale)
    local ret = love.graphics.newSpriteBatch(sprites, defines.CHUNK_SIZE * defines.CHUNK_SIZE, "static")
    for y = 1, defines.CHUNK_SIZE do
        for x = 1, defines.CHUNK_SIZE do
            ret:addLayer(
                tile_indices["empty"],
                defines.TILE_PIXEL_SIZE * (x - 1),
                defines.TILE_PIXEL_SIZE * (y - 1),
                0,
                tile_scale * defines.TILE_SIZES["empty"]
            )
        end
    end
    return ret
end

function Game.new()
    local defines = require('defines')
    local tile_array, tile_indices = createTileArray(defines.TILE_SIZES)
    local sprites = loadSprites(tile_array)
    local sprite_width, sprite_height = sprites:getDimensions()
    assert(sprite_width == sprite_height, "Tile assets must be square!")
    local tile_scale = defines.TILE_PIXEL_SIZE / sprite_width

    ---@class Game
    local self = {
        defines = defines,
        tile_array = tile_array,
        tile_indices = tile_indices,
        tile_scale = tile_scale,
        empty_chunk = generateChunkSprite(defines, sprites, tile_indices, tile_scale),

        chunk_mapping = {}, ---@type integer[][]
        buildables = calculateBuildableFlags(tile_array),
        sprites = sprites,

        tiles = {
            length = 0,
            type = {}, ---@type TileType[]
            buildable = {}, ---@type integer[]
        },

        chunks = {
            length = 0,
            start = {}, ---@type integer[]
            sprites = {}, ---@type love.SpriteBatch[]
            x = {}, ---@type integer[]
            y = {}, ---@type integer[]
        },
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
    table.insert(self.chunks.sprites, generateChunkSprite(self.defines, self.sprites, self.tile_indices, self.tile_scale))
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

---@param x integer
---@param y integer
---@param tile TileType
---@return boolean
function Game:checkEmpty(x, y, tile)
    local size = self.defines.TILE_SIZES[tile]
    for yy = y, y + size - 1 do
        for xx = x, x + size - 1 do
            local id = self:getTileIndex(xx, yy)
            if self.tiles.type[id] ~= "empty" then
                return false
            end
        end
    end
    return true
end

---@param x integer
---@param y integer
---@return integer buildables
---@return integer id
function Game:getFittingBuildables(x, y)
    local buildables = 0
    local id = self:getTileIndex(x, y)
    if self.tiles.type[id] ~= "empty" then
        for k, v in pairs(self.buildables) do
            if self:checkEmpty(x, y, k) then
                buildables = bit.bor(buildables, v)
            end
        end
    end
    return buildables, id
end

---@param x integer
---@param y integer
---@param tile TileType
function Game:calculateBuildable(x, y, tile)
    local size = self.defines.TILE_SIZES[tile]
    for yy = y, y + size - 1 do
        for xx = x, x + size - 1 do
            local id = self:getTileIndex(xx, yy)
            self.tiles.buildable[id] = 0
        end
    end
    local top_y = y - 1
    local bot_y = y + size
    local left_x = x - 1
    local right_x = x + size
    if tile == "road" then
        for xx = x - 1, x + size do
            local buildables, id = self:getFittingBuildables(xx, top_y)
            self.buildables[id] = buildables
            buildables, id = self:getFittingBuildables(xx, bot_y)
            self.buildables[id] = buildables
        end
        for yy = y - 1, y + size do
            local buildables, id = self:getFittingBuildables(left_x, yy)
            self.buildables[id] = buildables
            buildables, id = self:getFittingBuildables(right_x, yy)
            self.buildables[id] = buildables
        end
    end
end

---@param x integer
---@param y integer
---@param tile TileType
function Game:placeTile(x, y, tile)
    local tile_id = self:getTileIndex(x, y)
    self.tiles.type[tile_id] = tile
    self:calculateBuildable(x, y, tile)
end

local game ---@type Game

function love.load()
    game = Game.new()
    print(inspect(game))
end

function love.update(dt)
end

function love.draw()
    love.graphics.draw(game.empty_chunk)
end
