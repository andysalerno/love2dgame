-- Describes a character in the world, parent class for player character, etc
character = {world_x, world_y, speed, image}

function character:new()
    local new_character = {}
    setmetatable(new_character, self)
    self.__index = self
    return new_character
end

function character:move(dt)
    if love.keyboard.isDown('left','a') then
        if self.world_x > 0 then
            self.world_x = self.world_x - (self.speed*dt)
        end
    end
    if love.keyboard.isDown('right','d') then
        if self.world_x < love.graphics.getWidth() then
            self.world_x = self.world_x + (self.speed*dt)
        end
    end
    if love.keyboard.isDown('up','w') then
        if self.world_y > 0 then
            self.world_y = self.world_y - (self.speed*dt)
        end
    end
    if love.keyboard.isDown('down','s') then
        if self.world_y < love.graphics.getHeight() then
            self.world_y = self.world_y + (self.speed*dt)
        end
    end
end
