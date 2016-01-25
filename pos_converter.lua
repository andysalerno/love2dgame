local pos_converter = {camera_pos_table, map}

function pos_converter:init(camera_pos_table, map)
    self.camera_pos_table = camera_pos_table
    self.map = map
end

function pos_converter:get_tile_length()
    return self.map.tileheight
end

function pos_converter:world_to_offset(x, y)
    local offset = y * self.map.width
    offset = offset + x + 1
    return offset
end

function pos_converter:screen_to_offset(screen_x, screen_y)
    if self.map == nil then return end
    local x, y = self:screen_to_world(screen_x, screen_y)
    return self:world_to_offset(x, y)
end

function pos_converter:screen_to_world(screen_x, screen_y)
    local x = screen_x + self.camera_pos_table[1]
    local y = screen_y + self.camera_pos_table[2]
    return x, y
end

function pos_converter:pixels_to_screen(xpix, ypix)
    local screen_x = math.floor(xpix / self.map.tilewidth)
    local screen_y = math.floor(ypix / self.map.tileheight)
    return screen_x, screen_y
end

function pos_converter:world_to_pixels(x, y)
    -- convert world x,y to screen x,y
    local xdiff = self.camera_pos_table[1]
    local ydiff = self.camera_pos_table[2]

    local x_screen = x - xdiff
    local y_screen = y - ydiff

    local pix_x = x_screen * self.map.tilewidth
    local pix_y = y_screen * self.map.tileheight

    return pix_x, pix_y
end

return pos_converter
