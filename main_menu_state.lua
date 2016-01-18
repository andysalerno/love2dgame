local main_menu = {}
local menu_x = 200
local menu_y = 100
local font_size = 64
local menu_font = love.graphics.newFont(font_size)
local menu_options = {"New Game", "Settings", "Exit"}
local selected_option = 1 -- index of selected item in menu_options 
local menu_length = #menu_options
love.graphics.setFont(menu_font)

local function new_game()
    set_gamestate(gamestates.world_state)
end

local function settings()
end

local function exit_game()
    love.event.quit()
end

function main_menu.init()
    love.keypressed = main_menu.keypressed
end

function main_menu.keypressed(key, scancode, isrepeat)
    if key == 's' or key == 'down' then
        if selected_option == menu_length then
            selected_option = 1
        else
            selected_option = selected_option + 1
        end
    elseif key == 'w' or key == 'up' then
        if selected_option == 1 then
                selected_option = menu_length
            else
                selected_option = selected_option - 1
        end
    elseif key == 'return' then
        if selected_option == 1 then new_game() 
        elseif selected_option == 2 then settings() 
        elseif selected_option == 3 then exit_game() end
    end
end

function main_menu.draw(dt)
    for i=1,menu_length do
        love.graphics.print(menu_options[i], menu_x, menu_y + (80 * i - 1) - (font_size / 2))
    end
    love.graphics.circle("fill", menu_x - 30, menu_y + (80 * selected_option - 1), 20, 20)
end

function main_menu.update(dt)
end
return main_menu
