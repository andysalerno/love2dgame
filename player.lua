require('character')
player = character:new() 

function player:move(dt, collider)
    if love.keyboard.isDown('up', 'w') then
        local new_y = self.collidable.world_y - (dt * self.speed)
        if not collider:collides(self.collidable.world_x, new_y) then
            self.collidable.world_y = new_y
        end
    end
    if love.keyboard.isDown('left', 'a') then
        local new_x = self.collidable.world_x - (dt * self.speed)
        if not collider:collides(new_x, self.collidable.world_y) then
            self.collidable.world_x = new_x
        end
    end
    if love.keyboard.isDown('down', 's') then
        local new_y = self.collidable.world_y + (dt * self.speed)
        if not collider:collides(self.collidable.world_x, new_y) then
            self.collidable.world_y = new_y
        end
    end
    if love.keyboard.isDown('right', 'd') then
        local new_x = self.collidable.world_x + (dt * self.speed)
        if not collider:collides(new_x, self.collidable.world_y) then
            self.collidable.world_x = new_x
        end
    end
end
