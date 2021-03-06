-- Global functions go here (before requires, to be accessible everywhere)
require('class')
gamestates = {main_menu_state, world_state}
gamestates.main_menu_state = require("main_menu_state")
gamestates.world_state = require("world_state")

function check_type(object, parent)
    if getmetatable(object) == parent then
        return true
    else
        return false
    end
end

function set_gamestate(state)
    gamestate = state
    gamestate:init()
end


function love.load()
    set_gamestate(gamestates.main_menu_state)
end

-- called every frame - can do drawing only here
function love.draw()
    gamestate.draw()
    love.graphics.print('FPS: ' .. love.timer.getFPS(), 10, 20)
end

-- also called every update 
function love.update(dt)
    dt = math.min(dt, 0.01666667)
    gamestate:update(dt)
end

