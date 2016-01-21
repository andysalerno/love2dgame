-- collider.lua
-- collider will be used statically, with one instance handling all collisions in the world.
-- :register() will add an object to the table of objects that can collide.
-- :collides() will return true/false as appropriate if the x,y position passed to it collides with anything registered.
-- There are two types of collisions: static world collisions, and dynamic collisions.
-- static collisions are with objects in the world that never move, like walls and trees, and are registered
-- at :init() time from information in the map.  This marks entire x,y tiles in the world as collidable forever.
-- Dynamic collisions don't even exist yet in this file, and will either be unneeded or implemented later as necessary.

local collider = {}
collider.registered = {}
collider.map = nil
collider.collision_offset = {} 
collider.pos_converter = nil

function collider:register(collidable)
    if collidable.world_x == nil or collidable.world_y == nil
        or collidable.pix_width == nil or collidable.pix_height == nil then
        print('tried to register collision collidable without world_x or world_y!')
        return
    end
    table.insert(self.registered, collidable)
end

function collider:init(map, pos_converter)
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

function collider:collides(world_x, world_y)
    -- first, check if we have collided with any collidable tiles
    -- in the world.
    if self.map == nil then
        print('map not set in collider!')
    end
    local world_x = math.floor(world_x)
    local world_y = math.floor(world_y)
    local offset = self.pos_converter:world_to_offset(world_x, world_y)
    if self.collision_offset[offset] == true then -- don't 'optimize' this to one line, lua interprets weirdly
        return true
    else
        return false
    end
end

return collider
