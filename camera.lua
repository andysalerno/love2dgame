local camera = {
    map = nil,
    pos_converter = nil,
    images = {},
    xy = {10, 10},
}

function camera:center_on(world_x, world_y)
    local half_width = self.half_pix_width / self.map.tilewidth
    local half_height = self.half_pix_height / self.map.tileheight

    self:set_pos(world_x - half_width, world_y - half_height)
end

function camera:set_pos(world_x, world_y)
    self.xy[1] = world_x
    self.xy[2] = world_y
end

function camera:init(map, pos_converter)
    self.pos_converter = pos_converter
    self.map = map 
    self.images = {}
    self.half_pix_width = math.floor(love.graphics.getWidth() / 2)
    self.half_pix_height = math.floor(love.graphics.getHeight() / 2)
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

    -- how far offset [0-1) tile we are in each direction
    local x_floor = math.floor(self.xy[1])
    local y_floor = math.floor(self.xy[2])
    local x_offset = self.xy[1] - x_floor 
    local y_offset = self.xy[2] - y_floor

    -- draw every visible tile, offset by those amounts
    for _, layer in ipairs(self.map.layers) do
        for h=y_floor-1,y_floor+self.screen_tiles_height+1 do -- to render outside visible area for smoothness
            for w=x_floor-1,x_floor+self.screen_tiles_width+1 do
                if w >=0 and w < self.map.width and h >= 0 and h < self.map.height then
                    local offset = self.pos_converter:world_to_offset(w,h)
                    local tile_id = layer.data[offset]
                    local meta_img = self.images[tile_id]
                    if meta_img then
                        love.graphics.draw(meta_img.graphic,
                            (w-x_offset-x_floor) * self.map.tilewidth, 
                            (h-y_offset-y_floor) * self.map.tileheight)
                    end
                end
            end
        end
    end
end

function camera:get_pos()
    return xy[1], xy[2]
end

return camera
