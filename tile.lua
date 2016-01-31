local Collidable = require('collidable')
local Tile = class:newT({
    pos = nil,
    value = nil,
    collidable = Collidable:new(),
    is_active = false,
    is_static = true,
})

function Tile:init(value, pos)
    self.value = value
    self.pos = pos
    self.collidable:set_pos(self.pos[1], self.pos[2])
end

function Tile:get_pos()
    return self.pos[1], self.pos[2]
end

return Tile
