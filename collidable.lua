local collidable = class:newT({
    x = nil,
    y = nil,
    height = nil,
    width = nil,
    is_stationary = nil,
})

function collidable:set_pos(x, y)
   self.x = x
   self.y = y
end

function collidable:set_dimensions(height, width)
    self.height = height
    self.width = width
end

-- visually draw collidable (for debugging)
function collidable:draw(pos_converter)
    local world_x, world_y = pos_converter:world_to_pixels(self.x, self.y)
    local width = self.width * pos_converter.map.tilewidth
    local height = self.height * pos_converter.map.tileheight

    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(255,0,0,128)
    love.graphics.rectangle("fill", world_x, world_y, width, height)
    love.graphics.setColor(r, g, b, a)
end

return collidable
