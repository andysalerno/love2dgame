local collidable = require('collidable')

local collider = {
    registered = {},
    map = nil,
    collisionoffset = {},
    pos_converter = nil,
}

function collider:register(input_collidable)
    assert(check_type(input_collidable, collidable), "tried to register a non-collidable")
    table.insert(self.registered, collidable)
end

function collider:init(map, pos_converter)
    assert(map ~= nil, "nil map passed to collider:init()")
    assert(pos_converter ~= nil, "nil pos_converter passed to collider:init()")
    self.pos_converter = pos_converter
    self.map = map
    self.collision_offset = {}
    local tiles_that_collide = {}
    for _, tileset in ipairs(self.map.tilesets) do -- for each tile type
        for _, tile in ipairs(tileset.tiles) do
            if tile.properties and tile.properties["collide"] == "1" then
                print('added colliding tile ' .. tile.id)
                tiles_that_collide[tile.id+1] = true
            end
        end
    end

    --set collision_offset[offset] to true if tile at offset is a collider
    for _, layer in pairs(self.map.layers) do
       for index, tile_number in pairs(layer.data) do
            if tiles_that_collide[tile_number] == true then
               self.collision_offset[index] = true
            end
        end
    end
end

function collider:collides(input_collidable, dx, dy)
    assert(self.map ~= nil, "collider didn't have a proper map.")
    assert(check_type(input_collidable, collidable), "collides() was passed an improper collidable")
    
    local x = math.floor(input_collidable.x + dx)
    local y = math.floor(input_collidable.y + dy)
    for h=0,input_collidable.height do
        for w=0,input_collidable.width do
            local offset = self.pos_converter:world_to_offset(math.floor(x+w), math.floor(y+h))
            if self.collision_offset[offset] == true then
                return true
            end
        end
    end

    return false
end

-- do insertion sort on the nearly-sorted registered objects
function collider:sort_collidables()
    local size = #self.registered
    for i=2,size do
        local sample = self.registered[i].x
        local back_index = i - 1
        while back_index >= 1 and self.registered[back_index].x > sample do
            self.registered[back_index + 1] = self.registered[back_index]
            back_index = back_index - 1
        end

        self.registered[back_index + 1] = sample
    end
end

return collider
