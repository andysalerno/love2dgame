local collidable = class:new({
    x = nil,
    y = nil,
    height = nil,
    width = nil,
})

function collidable:set_pos(x, y)
   self.x = x
   self.y = y
end

function collidable:set_dimensions(height, width)
    self.height = height
    self.width = width
end

return collidable
