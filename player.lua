local Character = require('character')
local collidable = require('collidable')
local Player = Character:new() 

function Player:get_pos()
    return {self.pos[1], self.pos[2]}
end

function Player:getX()
    return self.pos[1]
end

function Player:getY()
    return self.pos[2]
end

function Player:init(...)
    print('player #args: ' .. #{...})
    self.world, self.pos, self.speed, self.image_name = unpack({...})
    self.image = love.graphics.newImage(self.image_name)
    self.image:setFilter('nearest', 'nearest')
    self.scale = 2
    
    self.half_height = (self.image:getHeight() / 2) / self.world.raw.tilewidth * self.scale
    self.width = (self.image:getWidth()) / self.world.raw.tilewidth * self.scale
    self.height = (self.image:getHeight()) / self.world.raw.tileheight * self.scale

    print('Player width: ' .. self.width)
    print('Player height: ' .. self.height)
    print('Player halfheight: ' .. self.half_height)

    self.collidable = collidable:new()
    self:update_collidable()
end

function Player:move(dt, collider)
    local diff = dt * self.speed

    local dy = 0
    if love.keyboard.isDown('up', 'w') then
        dy = dy - diff 
    end
    if love.keyboard.isDown('down', 's') then
        dy = dy + diff
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
    if not collider:collides(self.collidable, 0, dy) then
        self.pos[2] = self.pos[2] + dy
    end

    self:update_collidable()
end

function Player:update_collidable()
    assert(self.collidable)
    self.collidable.x = self.pos[1]
    self.collidable.y = self.pos[2] + self.half_height
    self.collidable.width = self.width
    self.collidable.height = self.height / 2
end

return Player
