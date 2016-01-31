local level_one = require('maps/thirtytwo')
local camera = require('camera')
local collider = require('collider')
local Player = require('player')
local World = require('world')

local world_state = {}

function world_state.keypressed(key)
    -- if key == 'escape' then love.event.quit() end
    if key == 'escape' then set_gamestate(gamestates.main_menu_state) end
end

function world_state:init()
    love.keypressed = world_state.keypressed 

    self.world = World:new(level_one, camera.pos)
    local player_image = "tiles/player.png"
    self.player = Player:new(self.world, {10, 10}, 5, player_image)
    camera:init(self.world, self.player)

    collider:init(self.world)
    collider:register(self.player)
end

function world_state.draw()
    camera:draw()
--    local player_pix_x, player_pix_y = pos_converter:world_to_pixels(player.collidable.x, player.collidable.y)
--    love.graphics.draw(player.image, player_pix_x, player_pix_y, 0, 2)
end

function world_state:update(dt)
    self.player:move(dt, collider)
    camera:center_on(self.player.collidable.x, self.player.collidable.y)
end

return world_state
