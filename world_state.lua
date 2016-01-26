local level_one = require('maps/thirtytwo')
local camera = require('camera')
local collider = require('collider')
local pos_converter = require('pos_converter')
local player = require('player')

local world_state = {}

function world_state.keypressed(key)
    -- if key == 'escape' then love.event.quit() end
    if key == 'escape' then set_gamestate(gamestates.main_menu_state) end
end

function world_state:init()
    pos_converter:init(camera.pos, level_one)
    love.keypressed = world_state.keypressed 

    self.player = world_state:create_player()

    camera:init(level_one, player, pos_converter)
    collider:init(level_one, pos_converter)
    collider:register(player.collidable)
end

function world_state:create_player()
    local player_image = "tiles/player.png"
    return player:new({10, 10}, 5, player_image, pos_converter)
end

function world_state.draw()
    camera:draw()
--    local player_pix_x, player_pix_y = pos_converter:world_to_pixels(player.collidable.x, player.collidable.y)
--    love.graphics.draw(player.image, player_pix_x, player_pix_y, 0, 2)
end

function world_state.update(dt)
    player:move(dt, collider)
    camera:center_on(player.collidable.x, player.collidable.y)
end

return world_state
