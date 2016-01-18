local camera = {
    map = nil,
    pos_converter = nil,
    images = {},
    xy = {0, 0},
}

function camera:set_pos(world_x, world_y)
    self.xy[1] = world_x
    self.xy[2] = world_y
end

function camera:init(map, pos_converter)
    self.pos_converter = pos_converter
    self.map = map 
    self.images = {}
    for _, tile in pairs(self.map.tilesets) do
        -- insert the lua image into the tile metadata and store it in images
        local graphic_image = love.graphics.newImage(tile.image)
        tile["graphic"] = graphic_image
        local tile_gid = tile.firstgid
        self.images[tile_gid] = tile
    end


    self.screen_tiles_width = math.floor(love.graphics.getWidth() / self.map.tilewidth)
    self.screen_tiles_height = math.floor(love.graphics.getHeight() / self.map.tileheight)
end

function camera:draw()
    if self.map == nil then return end
    for _, layer in pairs(self.map.layers) do
        for y = 0, self.screen_tiles_height do
            for x = 0, self.screen_tiles_width do
                local offset = self.pos_converter:screen_to_offset(x, y)
                local tile_gid = layer.data[offset]
                if self.images[tile_gid] then
                    local meta_image = self.images[tile_gid]
                    love.graphics.draw(meta_image.graphic, x * self.map.tilewidth, y * self.map.tileheight) 
                end
            end
        end
    end
end

function camera:get_pos()
    return xy[1], xy[2]
end

return camera
