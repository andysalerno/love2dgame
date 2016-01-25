require('character')
local collidable = require('collidable')
player = character:new() 

function player:new(pos, speed, image, pos_converter)
    new_player = character:new()
    self:init(pos, speed, image, pos_converter)
    return new_player
end

function player:get_pos()
    return {self.pos[1], self.pos[2]}
end

function player:getX()
    return self.pos[1]
end

function player:getY()
    return self.pos[2]
end

function player:init(pos, speed, image, pos_converter)
    self.pos = pos
    self.speed = speed
    self.pos_converter = pos_converter
    self.image = love.graphics.newImage(image)
    self.image:setFilter('nearest', 'nearest')

    self.half_height = (self.image:getHeight() / 2) / self.pos_converter:get_tile_length()
    self.width = (self.image:getWidth()) / self.pos_converter:get_tile_length()
    self.height = (self.image:getHeight()) / self.pos_converter:get_tile_length()

    self.collidable = collidable:new()
    self:update_collidable()
end

function player:move(dt, collider)
    local diff = dt * self.speed

    local dy = 0
    if love.keyboard.isDown('up', 'w') then
        dy = dy - diff 
    end
    if love.keyboard.isDown('down', 's') then
        dy = dy + diff
    end
    if not collider:collides(self.collidable, 0, dy) then
        self.pos[2] = self.pos[2] + dy
    end

    local dx = 0
    if love.keyboard.isDown('left', 'a') then
        dx = dx - diff
    end
    if love.keyboard.isDown('right', 'd') then
        dx = dx + diff
    end
    if not collider:collides(self.collidable, dx, 0) then
        self.pos[1] = self.pos[1] + dx
    end

    self:update_collidable()
end

function player:update_collidable()
    assert(self.collidable)
    self.collidable.x = self.pos[1]
    self.collidable.y = self.pos[2] + self.half_height
    self.collidable.width = self.width
    self.collidable.height = self.height / 2
end
