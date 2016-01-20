local camera = {
    map = nil,
    pos_converter = nil,
    world_tileset = {},
    spriteBatches = {},
    quads = {},
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
    print('camera init')
    self.pos_converter = pos_converter
    self.map = map 
    self.half_pix_width = math.floor(love.graphics.getWidth() / 2)
    self.half_pix_height = math.floor(love.graphics.getHeight() / 2)
    self.screen_tiles_width = math.floor(love.graphics.getWidth() / self.map.tilewidth) -- todo: don't floor it?
    self.screen_tiles_height = math.floor(love.graphics.getHeight() / self.map.tileheight)

    if self.map.tilesets[1].image == nil then print("couldn't access world tileset!") end
    self.world_tileset.image = love.graphics.newImage(self.map.tilesets[1].image)
    self.world_tileset.image:setFilter("nearest", "nearest")
    print('opened image ' .. self.map.tilesets[1].image)
    self.world_tileset.pix_width = self.world_tileset.image:getWidth()
    self.world_tileset.pix_height = self.world_tileset.image:getHeight()
    if self.world_tileset.pix_width % self.map.tilewidth ~= 0 then print('tileset not a multiple of tilewidth!') end
    if self.world_tileset.pix_height % self.map.tileheight ~= 0 then print('tileset not a multiple of tileheight!') end
    self.world_tileset.tiles_width = self.world_tileset.pix_width / self.map.tilewidth
    self.world_tileset.tiles_height = self.world_tileset.pix_height / self.map.tileheight

    -- one spriteBatch per layer, sourcing same tileset
    for _, _ in ipairs(self.map.layers) do
        print('adding tileset spritebatch layer...')
        table.insert(self.spriteBatches,
            love.graphics.newSpriteBatch(self.world_tileset.image,
            (self.screen_tiles_width * self.screen_tiles_height) + 1)) 
    end


    self.quads = {}
    for y=0,self.world_tileset.tiles_height-1 do
        for x=0,self.world_tileset.tiles_width-1 do
            local quad = love.graphics.newQuad(
                x * self.map.tilewidth, y * self.map.tileheight,
                self.map.tilewidth, self.map.tileheight,
                self.world_tileset.image:getWidth(), self.world_tileset.image:getHeight())
            table.insert(self.quads, quad)
        end
    end
end

function camera:test_draw()
    for y=0,self.world_tileset.tiles_height-1 do
        for x=0,self.world_tileset.tiles_width-1 do
            local quad_num = y * self.world_tileset.tiles_width + x + 1
            love.graphics.draw(self.world_tileset.image, self.quads[quad_num], x * self.map.tilewidth, y * self.map.tileheight)
        end
    end
end


function camera:drawdraw()
    if self.map == nil then return end

    -- how far offset [0-1) tile we are in each direction
    local x_flat = math.floor(self.xy[1])
    local y_flat = math.floor(self.xy[2])
    local x_offset = self.xy[1] - x_flat 
    local y_offset = self.xy[2] - y_flat

    -- populate each layer (spriteBatch) with quads mapping to world tileset  
    for index, layer in ipairs(self.map.layers) do
        for h=y_flat-1,y_flat+self.screen_tiles_height+1 do -- to render outside visible area for smoothness
            for w=x_flat-1,x_flat+self.screen_tiles_width+1 do
                if w >=0 and w < self.map.width and h >= 0 and h < self.map.height then
                    local offset = self.pos_converter:world_to_offset(w,h)
                    local tile_number = layer.data[offset]
                    local tile_quad = self:get_quad(tile_number)
                    love.graphics.draw(self.world_tileset.image, tile_quad,
                        (w-x_offset-x_flat) * self.map.tilewidth, (h-y_offset-y_flat) * self.map.tileheight)
                end
            end
        end
    end
end
function camera:draw()
    if self.map == nil then return end
    for _, spriteBatch in ipairs(self.spriteBatches) do
        spriteBatch:clear()
    end

    -- how far offset [0-1) tile we are in each direction
    local x_flat = math.floor(self.xy[1])
    local y_flat = math.floor(self.xy[2])
    local x_offset = self.xy[1] - x_flat 
    local y_offset = self.xy[2] - y_flat

    -- populate each layer (spriteBatch) with quads mapping to world tileset  
    for index, layer in ipairs(self.map.layers) do
        for h=y_flat-1,y_flat+self.screen_tiles_height+1 do -- to render outside visible area for smoothness
            for w=x_flat-1,x_flat+self.screen_tiles_width+1 do
                if w >=0 and w < self.map.width and h >= 0 and h < self.map.height then
                    local offset = self.pos_converter:world_to_offset(w,h)
                    local tile_number = layer.data[offset]
                    local tile_quad = self:get_quad(tile_number)
                    self.spriteBatches[index]:add(tile_quad, 
                        (w-x_offset-x_flat) * self.map.tilewidth, (h-y_offset-y_flat) * self.map.tileheight)
                end
            end
        end
    end

    for _, spriteBatch in ipairs(self.spriteBatches) do
        spriteBatch:flush()
        love.graphics.draw(spriteBatch)
    end
end

function camera:print_tileno(tile_number)
    love.graphics.print('tileno: ' .. tile_number, 30, 10)
end

function camera:get_quad(tile_number)
    --return self.quads[101]
    return self.quads[tile_number] -- Lua array starts at 1, tile ids start at 0
end

function camera:get_pos()
    return xy[1], xy[2]
end

return camera
