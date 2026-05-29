---@class Camera
local Camera = {}
Camera.__index = Camera

function Camera.new()
    ---@class Camera
    local self = {
        center_x = 0, ---@type number
        center_y = 0, ---@type number
        zoom = 1, ---@type number
    }
    return setmetatable(self, Camera)
end

---@return integer top_left_x
---@return integer top_left_y
---@return integer bottom_right_x
---@return integer bottom_right_y
function Camera:getBoundingBox()
    local width, height = love.graphics.getDimensions()
    local half_width, half_height = math.ceil(width / 2), math.ceil(height / 2)

    return
        math.floor(self.center_x - half_width / self.zoom),
        math.floor(self.center_y - half_height / self.zoom),
        math.ceil(self.center_x + half_width / self.zoom),
        math.ceil(self.center_y + half_height / self.zoom)
end

return Camera
