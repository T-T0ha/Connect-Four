local GameGUI = require("ui")
local game_gui

function love.load()
    love.window.setTitle("Connect Four")
    love.window.setMode(700, 700)
    
    -- Initialize with menu state
    game_gui = GameGUI:new()
    game_gui.state = "menu" -- menu, playing, game_over
    game_gui.selected_theme = 1
    game_gui.selected_difficulty = 2 -- medium by default
    game_gui.themes = {
        "Vintage Sunset",  -- Original theme name
        "Retro Pixel",
        "Monochrome",
        "Cyberpunk"
    }
    game_gui.difficulties = {"Easy", "Medium", "Hard"}
    
    -- Load sounds for animations
    game_gui.sounds = {
        win = love.audio.newSource("win.wav", "static"),
        draw = love.audio.newSource("draw.wav", "static"),
        drop = love.audio.newSource("drop.wav", "static")
    }
end

function love.update(dt)
    if game_gui.state == "playing" or game_gui.state == "game_over" then
        game_gui:update(dt)
    end
end

function love.draw()
    if game_gui.state == "menu" then
        game_gui:drawMenu()
    else
        game_gui:draw()
    end
end

function love.mousepressed(x, y, button)
    if game_gui.state == "menu" then
        game_gui:menuMousepressed(x, y, button)
    else
        game_gui:mousepressed(x, y, button)
    end
end

function love.keypressed(key)
    game_gui:keypressed(key)
end