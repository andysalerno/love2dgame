local collidable = require('collidable')

local collider = {
    registered = {},
    x_sorted = {},
    y_sorted = {},
    world = nil,
    collisionoffset = {},
}

function collider:register(object)
    assert(object.collidable ~= nil)
    assert(object.collidable.x)
    assert(object.collidable.y)
    
    table.insert(self.registered, object.collidable)
    table.insert(self.x_sorted, object.collidable)
    table.insert(self.y_sorted, object.collidable)
end

function collider:init(world)
    assert(world ~= nil, "nil world passed to collider:init()")
    self.world = world
    for i=1,#self.world.tiles do
        local layer = self.world.tiles[i]
        local width, height = self.world:get_dimensions()
        for y=0,height-1 do
            for x=0,width-1 do
                self:register(self.world:get_tile_at(i, x, y))
            end
        end
    end
    self:sort_collidables()

    -- old way of doing collisions
    self.collision_offset = {}
    local tiles_that_collide = {}
    for _, tileset in ipairs(self.world.raw.tilesets) do -- for each tile type
        for _, tile in ipairs(tileset.tiles) do
            if tile.properties and tile.properties["collide"] == "1" then
                print('added colliding tile ' .. tile.id)
                tiles_that_collide[tile.id+1] = true
            end
        end
    end

    --set collision_offset[offset] to true if tile at offset is a collider
    for _, layer in pairs(self.world.raw.layers) do
       for index, tile_number in pairs(layer.data) do
            if tiles_that_collide[tile_number] == true then
               self.collision_offset[index] = true
            end
        end
    end
end

function collider:collides(input_collidable, dx, dy)
    assert(self.world ~= nil, "collider didn't have a proper world.")
    assert(check_type(input_collidable, collidable), "collides() was passed an improper collidable")
    
    -- check if any corner of box is in a colliding tile
    local x = math.floor(input_collidable.x + dx)
    local y = math.floor(input_collidable.y + dy)
    for h=0,input_collidable.height-1 do
        for w=0,input_collidable.width-1 do
            local offset = self.world.pos_converter:world_to_offset(math.floor(x+w), math.floor(y+h))
            if self.collision_offset[offset] == true then
                return true
            end
        end
    end

    return false
end

-- do insertion sort on the nearly-sorted registered objects
function collider:sort_collidables()
    local x_func = function (i) return i.x end
    local y_func = function (i) return i.y end
    self.insertion_sort(self.x_sorted, x_func) 
    self.insertion_sort(self.y_sorted, y_func) 
    assert(self.list_is_sorted(self.x_sorted, x_func))
    assert(self.list_is_sorted(self.y_sorted, y_func))
end

function collider.insertion_sort(input, property_picker)
    print('sort start...')
    local size = #input
    for i=2,size do
        local sample = input[i]
        local back_index = i - 1
        while back_index >= 1 
            and property_picker(input[back_index]) > property_picker(sample) do
            input[back_index + 1] = input[back_index]
            back_index = back_index - 1
        end

        input[back_index + 1] = sample
    end
    print('sort end.')
end

function collider.list_is_sorted(input, property_picker)
    local prev = nil
    for i=1,#input do
        local val = input[i]
        assert(val.x)
        assert(val.y)
        if prev == nil then
            prev = property_picker(val)
        elseif property_picker(val) < prev then
                return false
        end
    end
    return true
end

return collider
