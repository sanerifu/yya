local config = require('Config')
local module = {}

---@param camera Camera
---@return integer top_left_x
---@return integer top_left_y
---@return integer bot_right_x
---@return integer bot_right_y
function module.getBoundingBox(camera)
    local pixel_size = config.pixels * camera.zoom
    local width, height = love.graphics.getDimensions()

    local half_width, half_height
        = math.ceil(width / 2), math.ceil(height / 2)
    local half_tile_width, half_tile_height =
        half_width / pixel_size, half_height / pixel_size
    local center_tile_x, center_tile_y =
        camera.center_x / pixel_size, camera.center_y / pixel_size

    return
        math.floor(center_tile_x - half_tile_width), math.floor(center_tile_y - half_tile_height),
        math.ceil(center_tile_x + half_tile_width), math.ceil(center_tile_y + half_tile_height)
end

return module
