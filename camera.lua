local pos_converter = require('pos_converter')
local camera = {
    world = nil,
    player = nil,
    player_quads = {},
    world_tileset = {},
    spriteBatches = {},
    world_quads = {},
    pos = {nil, nil},
}

function camera:get_pos()
    reutrn {self.pos[1], self.pos[2]}
end

function camera:getX()
    return self.pos[1]
end

function camera:getY()
    return self.pos[2]
end

function camera:center_on(world_x, world_y)
    local half_width = self.half_pix_width / self.world.tilewidth
    local half_height = self.half_pix_height / self.world.tileheight

    self:set_pos(world_x - half_width, world_y - half_height)
end

function camera:set_pos(world_x, world_y)
    self.pos[1] = world_x
    self.pos[2] = world_y
end

function camera:init(world, player)
    print('camera init')
    self.world = world.raw 
    self.player = player
    self.half_pix_width = math.floor(love.graphics.getWidth() / 2)
    self.half_pix_height = math.floor(love.graphics.getHeight() / 2)
    self.screen_tiles_width = math.floor(love.graphics.getWidth() / self.world.tilewidth) -- todo: don't floor it?
    self.screen_tiles_height = math.floor(love.graphics.getHeight() / self.world.tileheight)

    assert(self.world.tilesets[1].image ~= nil, "couldn't access world tileset")
    self.world_tileset.image = love.graphics.newImage(self.world.tilesets[1].image)
    self.world_tileset.image:setFilter("nearest", "nearest")
    print('opened image ' .. self.world.tilesets[1].image)
    self.world_tileset.pix_width = self.world_tileset.image:getWidth()
    self.world_tileset.pix_height = self.world_tileset.image:getHeight()

    assert(self.world_tileset.pix_width % self.world.tilewidth == 0, "tileset not a multiple of tilewidth")
    assert(self.world_tileset.pix_height % self.world.tileheight == 0, "tileset not a multiple of tileheight")
    self.world_tileset.tiles_width = self.world_tileset.pix_width / self.world.tilewidth
    self.world_tileset.tiles_height = self.world_tileset.pix_height / self.world.tileheight

    -- one spriteBatch per layer, sourcing same tileset
    for index, layer in ipairs(self.world.layers) do
        local spriteBatch = nil
        if layer.name == 'player' then
            self.player.layer = index
            table.insert(self.player_quads, love.graphics.newQuad(0, 0, self.player.image:getWidth(), self.player.image:getHeight(), self.player.image:getWidth(), self.player.image:getHeight()))
            spriteBatch = love.graphics.newSpriteBatch(self.player.image, 8) -- for now, assume only 8 sprites for player
        else
            spriteBatch = love.graphics.newSpriteBatch(self.world_tileset.image,
                (self.screen_tiles_width+1) * (self.screen_tiles_height+2))
        end
        table.insert(self.spriteBatches, spriteBatch)    
    end


    self.world_quads = {}
    for y=0,self.world_tileset.tiles_height-1 do
        for x=0,self.world_tileset.tiles_width-1 do
            local quad = love.graphics.newQuad(
                x * self.world.tilewidth, y * self.world.tileheight,
                self.world.tilewidth, self.world.tileheight,
                self.world_tileset.image:getWidth(), self.world_tileset.image:getHeight())
            table.insert(self.world_quads, quad)
        end
    end
end

function camera:test_draw()
    for y=0,self.world_tileset.tiles_height-1 do
        for x=0,self.world_tileset.tiles_width-1 do
            local quad_num = y * self.world_tileset.tiles_width + x + 1
            love.graphics.draw(self.world_tileset.image, self.world_quads[quad_num], x * self.world.tilewidth, y * self.world.tileheight)
        end
    end
end


function camera:draw_no_spritebatch() -- for emergency use only, if drawing with spriteBatch explodes
    if self.world == nil then return end

    -- how far offset [0-1) tile we are in each direction
    local x_flat = math.floor(self.pos[1])
    local y_flat = math.floor(self.pos[2])
    local x_offset = self.pos[1] - x_flat 
    local y_offset = self.pos[2] - y_flat

    -- populate each layer (spriteBatch) with quads worldping to world tileset  
    for index, layer in ipairs(self.world.layers) do
        for h=y_flat-1,y_flat+self.screen_tiles_height+1 do -- to render outside visible area for smoothness
            for w=x_flat-1,x_flat+self.screen_tiles_width+1 do
                if w >=0 and w < self.world.width and h >= 0 and h < self.world.height then
                    local offset = pos_converter:world_to_offset(w,h)
                    local tile_number = layer.data[offset]
                    local tile_quad = self:get_quad(tile_number)
                    love.graphics.draw(self.world_tileset.image, tile_quad,
                        (w-x_offset-x_flat) * self.world.tilewidth, (h-y_offset-y_flat) * self.world.tileheight)
                end
            end
        end
    end
end


function camera:draw()
    for _, spriteBatch in ipairs(self.spriteBatches) do
        spriteBatch:clear()
    end

    -- how far offset [0-1) tile we are in each direction
    local x_flat = math.floor(self.pos[1])
    local y_flat = math.floor(self.pos[2])
    local x_offset = self.pos[1] - x_flat 
    local y_offset = self.pos[2] - y_flat

    -- populate each layer (spriteBatch) with quads worldping to world tileset  
    for index, layer in ipairs(self.world.layers) do
        if layer.name == 'player' then
            local player_pix_x, player_pix_y = pos_converter:world_to_pixels(self.player.pos[1], self.player.pos[2])
            self.spriteBatches[index]:add(self.player_quads[1], player_pix_x, player_pix_y, 0, self.player.scale)
        else
            for h=y_flat,y_flat+self.screen_tiles_height+1 do -- to render outside visible area for smoothness
                for w=x_flat,x_flat+self.screen_tiles_width do
                    if w >=0 and w < self.world.width and h >= 0 and h < self.world.height then
                        local offset = pos_converter:world_to_offset(w,h)
                        local tile_number = layer.data[offset]
                        local tile_quad = self:get_quad(tile_number)
                        self.spriteBatches[index]:add(tile_quad, 
                            (w-x_offset-x_flat) * self.world.tilewidth, (h-y_offset-y_flat) * self.world.tileheight)
                    end
                end
            end
        end
    end

    for _, spriteBatch in ipairs(self.spriteBatches) do
        spriteBatch:flush()
        love.graphics.draw(spriteBatch)
    end
    self.player.collidable:draw(pos_converter)
end

function camera:get_quad(tile_number)
    return self.world_quads[tile_number] -- Lua array starts at 1, tile ids start at 0
end

return camera
