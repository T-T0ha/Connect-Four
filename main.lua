local GameGUI = require("../gui/ui")
local game_gui

function love.load()
    love.window.setTitle("Connect Four")
    love.window.setMode(700, 650)  -- Width: (7 cols * 80) + (50 margin * 2) = 660 → 700 for padding
    game_gui = GameGUI:new()
end

function love.update(dt)
    game_gui:update(dt)
end

function love.draw()
    love.graphics.clear(0.96, 0.96, 0.96)
    game_gui:draw()
end

function love.mousepressed(x, y, button)
    game_gui:mousepressed(x, y, button)
end

function love.keypressed(key)
    game_gui:keypressed(key)
end