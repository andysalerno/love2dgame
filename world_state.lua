local level_one = require('maps/thirtytwo')
local camera = require('camera')
local pos_converter = require('pos_converter')
local collider = require('collider')
require('player')

local world_state = {}
local m_player = player:new()
m_player.speed = 5 
m_player.image = love.graphics.newImage("tiles/player.png")
m_player.image:setFilter("nearest", "nearest")

m_player.collidable = {
    world_x = 10,
    world_y = 10,
    pix_width = m_player.image:getWidth(),
    pix_height = m_player.image:getHeight(),
}

function world_state.keypressed(key)
    -- if key == 'escape' then love.event.quit() end
    if key == 'escape' then set_gamestate(gamestates.main_menu_state) end
end
 
function world_state.init()
    love.keypressed = world_state.keypressed 
    pos_converter:init(camera.xy, level_one)
    camera:init(level_one, m_player, pos_converter)
    -- camera:center_on(m_player.collidable.world_x, m_player.collidable.world_y)
    collider:init(level_one, pos_converter)
    collider:register(m_player.collidable)
end

function world_state.draw()
    camera:draw()
--    local player_pix_x, player_pix_y = pos_converter:world_to_pixels(m_player.collidable.world_x, m_player.collidable.world_y)
--    love.graphics.draw(m_player.image, player_pix_x, player_pix_y, 0, 2)
end

function world_state.update(dt)
    m_player:move(dt, collider)
    camera:center_on(m_player.collidable.world_x, m_player.collidable.world_y)
end

return world_state
