local Tile = require('tile')
local pos_converter = require('pos_converter')
local World = class:newT({
    tiles = {},
    raw = nil,
    pos_converter = nil,
})

function World:init(...)
    local raw, camera_pos_table = unpack({...})
    self.raw = raw

    self.pos_converter = pos_converter
    self.pos_converter:init(camera_pos_table, self)

    for i=1,#self.raw.layers do
        local tilelist = self:build_tilelist(self.raw.layers[i].data)
        table.insert(self.tiles, tilelist)
    end
end

function World:get_tile_at(layer, x, y)
    return self.tiles[layer][y+1][x+1]
end

function World:get_dimensions()
    return self.raw.width, self.raw.height
end

function World:build_tilelist(data)
    local result = {}
    local map_width = self.raw.width
    local map_height = self.raw.height
    for y=0,map_height-1 do
        local row = {}
        for x=0,map_width-1 do
            local offset = self.pos_converter:world_to_offset(x, y)
            local new_tile = Tile:new(data[offset], {x,y})
            table.insert(row, new_tile)
        end
        table.insert(result, row)
    end
    return result
end

return World
