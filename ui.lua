local Board = require("game_logic_demo")
local AI = require("ai")
local GameGUI = {}

local COLUMNS = 7
local ROWS = 6
local CELL_SIZE = 80
local MARGIN = 70
local RADIUS = CELL_SIZE / 2 - 5

-- Define all color themes
local THEMES = {
    ["Vintage Sunset"] = {
        empty = {255/255, 181/255, 167/255},
        player1 = {220/255, 47/255, 2/255},
        player2 = {255/255, 186/255, 8/255},
        board = {55/255, 6/255, 23/255},       
        highlight = {180/255, 40/255, 90/255}, 
        text = {250/255, 163/255, 7/255},
        background = {199/255, 81/255, 70/255}, 
        current_player = {232/255, 93/255, 4/255}
    },
    ["Retro Pixel"] = {
        empty = {200/255, 220/255, 240/255},
        player1 = {255/255, 50/255, 50/255},
        player2 = {50/255, 200/255, 50/255},
        board = {80/255, 80/255, 120/255},
        highlight = {150/255, 50/255, 200/255},  
        text = {255/255, 255/255, 255/255},
        background = {40/255, 40/255, 80/255},
        current_player = {255/255, 150/255, 50/255}
    },
    ["Monochrome"] = {
        empty = {240/255, 240/255, 240/255},
        player1 = {50/255, 50/255, 50/255},
        player2 = {150/255, 150/255, 150/255},
        board = {200/255, 200/255, 200/255},
        highlight = {100/255, 100/255, 100/255},
        text = {30/255, 30/255, 30/255},
        background = {220/255, 220/255, 220/255},
        current_player = {80/255, 80/255, 80/255}
    },
    ["Cyberpunk"] = {
        empty = {50/255, 5/255, 80/255},
        player1 = {255/255, 0/255, 200/255},
        player2 = {0/255, 255/255, 200/255},
        board = {20/255, 0/255, 40/255},
        highlight = {160/255, 0/255, 120/255},  
        text = {0/255, 255/255, 255/255},
        background = {10/255, 0/255, 20/255},
        current_player = {200/255, 0/255, 255/255}
    }
}

-- Difficulty settings (affects AI depth)
local DIFFICULTY_DEPTHS = {
    Easy = 0,
    Medium = 1,
    Hard = 2
}

function GameGUI:new()
    local obj = {
        boardState = Board:new(),
        hover_column = nil,
        current_player = 1,
        game_over = false,
        winner = nil,
        ai_is_playing = false,
        state = "menu",
        selected_theme = 4,
        selected_difficulty = 2,
        themes = {"Vintage Sunset", "Retro Pixel", "Monochrome", "Cyberpunk"},
        difficulties = {"Easy", "Medium", "Hard"},
        animation_timer = 0,
        winning_coins = {},
        falling_coins = {},
        difficulty = "Medium",
        sounds = {},
        show_theme_options = false,
        show_difficulty_options = false,
        theme_images = {
            love.graphics.newImage("vintage-sunset.jpg"),
            love.graphics.newImage("retro-pixel.jpg"),
            love.graphics.newImage("monochrome.jpg"),
            love.graphics.newImage("cyberpunk.jpg")
        }
    }
    setmetatable(obj, {__index = GameGUI})
    return obj
end



function GameGUI:drawThemeOptions(x, y, width, COLORS)
    local popup_height = #self.themes * 55 -- Make taller to fit thumbnails
    local popup_y = y + 60
    
    -- Popup background with gradient
    for i = 0, popup_height do
        local ratio = i / popup_height
        love.graphics.setColor(
            COLORS.board[1] * (1 - ratio) + ratio * COLORS.board[1] * 1.3,
            COLORS.board[2] * (1 - ratio) + ratio * COLORS.board[2] * 1.3,
            COLORS.board[3] * (1 - ratio) + ratio * COLORS.board[3] * 1.3,
            0.95
        )
        love.graphics.rectangle("fill", x, popup_y + i, width, 1)
    end
    
    -- Popup border
    love.graphics.setColor(COLORS.highlight)
    love.graphics.rectangle("line", x, popup_y, width, popup_height, 10)
    
    -- Theme options
    for i, theme in ipairs(self.themes) do
        local item_y = popup_y + (i - 1) * 55
        
        -- Highlight selected theme
        if i == self.selected_theme then
            love.graphics.setColor(COLORS.highlight)
            love.graphics.rectangle("fill", x + 5, item_y + 5, width - 10, 45, 5)
        end
        
        -- Draw theme name
        love.graphics.setColor(COLORS.text)
        love.graphics.printf(theme, x, item_y + 10, width, "center")
        
        -- Draw thumbnail of theme image
        if self.theme_images[i] then
            love.graphics.setColor(1, 1, 1)
            local thumb_size = 30
            local thumb_x = x + 30
            local thumb_y = item_y + 15
            -- Draw a small version of the theme image
            love.graphics.draw(self.theme_images[i], thumb_x, thumb_y, 0, thumb_size/self.theme_images[i]:getWidth(), thumb_size/self.theme_images[i]:getHeight())
        end
    end
end



function GameGUI:getCurrentTheme()
    return THEMES[self.themes[self.selected_theme]]
end

function GameGUI:drawMenu()
    -- Draw the themed background first
    self:drawBackground()
    
    local COLORS = self:getCurrentTheme()
    -- Add a semi-transparent overlay to make the menu more visible
    love.graphics.setColor(COLORS.background[1], COLORS.background[2], COLORS.background[3], 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Title
    love.graphics.setColor(COLORS.text)
    local title_font = love.graphics.newFont(48)
    love.graphics.setFont(title_font)
    love.graphics.printf("CONNECT FOUR", 0, 50, love.graphics.getWidth(), "center")
    
    -- Button dimensions
    local button_width = 300
    local button_height = 50
    local button_x = (love.graphics.getWidth() - button_width) / 2
    
    -- Theme Selection Button
    local theme_button_y = 200
    love.graphics.setColor(COLORS.board)
    love.graphics.rectangle("fill", button_x, theme_button_y, button_width, button_height, 10)
    love.graphics.setColor(COLORS.highlight)
    love.graphics.rectangle("line", button_x, theme_button_y, button_width, button_height, 10)
    love.graphics.setColor(COLORS.text)
    local button_font = love.graphics.newFont(24)
    love.graphics.setFont(button_font)
    love.graphics.printf("Theme: " .. self.themes[self.selected_theme], button_x, theme_button_y + 12, button_width, "center")

    -- Difficulty Selection Button
    local difficulty_button_y = theme_button_y + 80
    love.graphics.setColor(COLORS.board)
    love.graphics.rectangle("fill", button_x, difficulty_button_y, button_width, button_height, 10)
    love.graphics.setColor(COLORS.highlight)
    love.graphics.rectangle("line", button_x, difficulty_button_y, button_width, button_height, 10)
    love.graphics.setColor(COLORS.text)
    love.graphics.printf("Difficulty: " .. self.difficulties[self.selected_difficulty], button_x, difficulty_button_y + 12, button_width, "center")

    -- Start Game Button (only show when no options are open)
    if not self.show_theme_options and not self.show_difficulty_options then
        local start_button_y = difficulty_button_y + 80
        local pulse = 0.8 + 0.2 * math.sin(love.timer.getTime() * 3)
        love.graphics.setColor(COLORS.current_player)
        love.graphics.rectangle("fill", button_x, start_button_y, button_width, button_height, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("START GAME", button_x, start_button_y + 12, button_width, "center")
    end

    -- Draw options pop-ups if active
    if self.show_theme_options then
        self:drawThemeOptions(button_x, theme_button_y, button_width, COLORS)
    end

    if self.show_difficulty_options then
        self:drawDifficultyOptions(button_x, difficulty_button_y, button_width, COLORS)
    end
end

function GameGUI:drawDifficultyOptions(x, y, width, COLORS)
    local popup_height = #self.difficulties * 40
    local popup_y = y + 60
    
    -- Popup background with gradient
    for i = 0, popup_height do
        local ratio = i / popup_height
        love.graphics.setColor(
            COLORS.board[1] * (1 - ratio) + ratio * COLORS.board[1] * 1.3,
            COLORS.board[2] * (1 - ratio) + ratio * COLORS.board[2] * 1.3,
            COLORS.board[3] * (1 - ratio) + ratio * COLORS.board[3] * 1.3,
            0.95
        )
        love.graphics.rectangle("fill", x, popup_y + i, width, 1)
    end
    
    love.graphics.setColor(COLORS.highlight)
    love.graphics.rectangle("line", x, popup_y, width, popup_height, 10)
    
    for i, difficulty in ipairs(self.difficulties) do
        local item_y = popup_y + (i - 1) * 40
        if i == self.selected_difficulty then
            love.graphics.setColor(COLORS.highlight)
            love.graphics.rectangle("fill", x + 5, item_y + 5, width - 10, 30, 5)
        end
        love.graphics.setColor(COLORS.text)
        love.graphics.printf(difficulty, x, item_y + 10, width, "center")
    end
end

function GameGUI:menuMousepressed(x, y, button)
    if button == 1 then
        local button_width = 300
        local button_x = (love.graphics.getWidth() - button_width) / 2
        
        -- Theme button coordinates
        local theme_button_y = 200
        local theme_button_height = 50
        
        -- Difficulty button coordinates
        local difficulty_button_y = 280
        local difficulty_button_height = 50
        
        -- Start button coordinates
        local start_button_y = 360
        local start_button_height = 50
        
        -- First check if we're clicking on open options
        if self.show_theme_options then
            local popup_y = theme_button_y + 60
            for i, _ in ipairs(self.themes) do
                local option_y = popup_y + (i - 1) * 55  -- Updated from 40 to 55 to match the new height
                if x >= button_x and x <= button_x + button_width and
                   y >= option_y and y <= option_y + 55 then  -- Updated height
                    self.selected_theme = i
                    self.show_theme_options = false
                    if self.sounds.drop then
                        self.sounds.drop:play()
                    end
                    return -- Stop further processing if we clicked an option
                end
            end
        end
        
        if self.show_difficulty_options then
            local popup_y = difficulty_button_y + 60
            for i, _ in ipairs(self.difficulties) do
                local option_y = popup_y + (i - 1) * 40
                if x >= button_x and x <= button_x + button_width and
                   y >= option_y and y <= option_y + 40 then
                    self.selected_difficulty = i
                    self.difficulty = self.difficulties[i]
                    self.show_difficulty_options = false
                    if self.sounds.drop then
                        self.sounds.drop:play()
                    end
                    return -- Stop further processing if we clicked an option
                end
            end
        end
        
        -- Then check for main buttons (only if no options are open)
        if not self.show_theme_options and not self.show_difficulty_options then
            -- Check if theme button was clicked
            if x >= button_x and x <= button_x + button_width and
               y >= theme_button_y and y <= theme_button_y + theme_button_height then
                self.show_theme_options = true
                self.show_difficulty_options = false
                if self.sounds.drop then
                    self.sounds.drop:play()
                end
                return
            end
            
            -- Check if difficulty button was clicked
            if x >= button_x and x <= button_x + button_width and
               y >= difficulty_button_y and y <= difficulty_button_y + difficulty_button_height then
                self.show_difficulty_options = true
                self.show_theme_options = false
                if self.sounds.drop then
                    self.sounds.drop:play()
                end
                return
            end
            
            -- Check if start button was clicked
            if x >= button_x and x <= button_x + button_width and
               y >= start_button_y and y <= start_button_y + start_button_height then
                self.state = "playing"
                if self.sounds.drop then
                    self.sounds.drop:play()
                end
                return
            end
        end
    end
end
function GameGUI:drawBackground()
    -- Get current theme colors
    local COLORS = self:getCurrentTheme()
    
    -- Draw the theme image as background with enhanced blending
    local themeImage = self.theme_images[self.selected_theme]
    
    if themeImage then
        -- Scale the image to cover the entire window
        local windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()
        local imageWidth, imageHeight = themeImage:getWidth(), themeImage:getHeight()
        
        -- Add subtle movement based on time for more dynamic background
        local time_offset_x = math.sin(love.timer.getTime() * 0.2) * 5
        local time_offset_y = math.cos(love.timer.getTime() * 0.3) * 5
        
        local scaleX = windowWidth / imageWidth * 1.1  -- Scale slightly larger for movement
        local scaleY = windowHeight / imageHeight * 1.1
        local scale = math.max(scaleX, scaleY)
        
        -- Center the image with subtle movement
        local scaledWidth = imageWidth * scale
        local scaledHeight = imageHeight * scale
        local x = (windowWidth - scaledWidth) / 2 + time_offset_x
        local y = (windowHeight - scaledHeight) / 2 + time_offset_y
        
        -- Draw with a semi-transparent overlay to maintain theme color visibility
        love.graphics.setColor(1, 1, 1, 0.6)  -- More visible background
        love.graphics.draw(themeImage, x, y, 0, scale, scale)
          -- Add theme-specific overlay effects using alphaMultiply which is safer than multiply
        love.graphics.setBlendMode("alpha", "alphamultiply")
        if self.selected_theme == 1 then -- vintage-sunset
            -- Add warm golden gradient overlay
            for i = 0, windowHeight do
                local ratio = i / windowHeight
                love.graphics.setColor(
                    (0.9 - ratio * 0.2) * 0.3, 
                    (0.7 - ratio * 0.3) * 0.3, 
                    (0.5 - ratio * 0.1) * 0.3, 
                    0.3
                )
                love.graphics.rectangle("fill", 0, i, windowWidth, 1)
            end
        elseif self.selected_theme == 2 then -- retro-pixel
            -- Add pixel grid effect
            love.graphics.setColor(0.7 * 0.15, 0.8 * 0.15, 1.0 * 0.15, 0.15)
            local grid_size = 4
            for i = 0, windowWidth, grid_size do
                love.graphics.rectangle("line", i, 0, grid_size, windowHeight)
            end
            for i = 0, windowHeight, grid_size do
                love.graphics.rectangle("line", 0, i, windowWidth, grid_size)
            end
        elseif self.selected_theme == 3 then -- monochrome
            -- Add film grain effect
            love.graphics.setColor(0.9 * 0.1, 0.9 * 0.1, 0.9 * 0.1, 0.1)
            for i = 1, 200 do
                local grain_x = math.random(0, windowWidth)
                local grain_y = math.random(0, windowHeight)
                local grain_size = math.random(1, 3)
                love.graphics.rectangle("fill", grain_x, grain_y, grain_size, grain_size)
            end
        elseif self.selected_theme == 4 then -- cyberpunk
            -- Add scan lines and glow effect
            for i = 0, windowHeight, 3 do
                love.graphics.setColor(0.5 * 0.05, 0.9 * 0.05, 1.0 * 0.05, 0.05)
                love.graphics.rectangle("fill", 0, i, windowWidth, 1)
            end
            
            -- Add subtle digital glitch effect
            if math.random() < 0.02 then -- occasionally show glitch
                local glitch_x = math.random(0, windowWidth - 100)
                local glitch_y = math.random(0, windowHeight - 20)
                local glitch_width = math.random(50, 150)
                local glitch_height = math.random(5, 15)
                love.graphics.setColor(0.8 * 0.2, 1.0 * 0.2, 1.0 * 0.2, 0.2)
                love.graphics.rectangle("fill", glitch_x, glitch_y, glitch_width, glitch_height)
            end
        end
        love.graphics.setBlendMode("alpha")
    end
    
    -- Add a subtle vignette effect around the edges to focus attention on the board
    local gradientSize = 200
    for i = 0, gradientSize do
        local alpha = (gradientSize - i) / gradientSize * 0.7  -- Stronger vignette
        -- Top vignette
        love.graphics.setColor(0, 0, 0, alpha)
        love.graphics.rectangle("fill", 0, i, love.graphics.getWidth(), 1)
        
        -- Bottom vignette
        love.graphics.rectangle("fill", 0, love.graphics.getHeight() - i, love.graphics.getWidth(), 1)
        
        -- Left vignette
        love.graphics.rectangle("fill", i, 0, 1, love.graphics.getHeight())
        
        -- Right vignette
        love.graphics.rectangle("fill", love.graphics.getWidth() - i, 0, 1, love.graphics.getHeight())
    end
    
    -- Add a subtle animated pattern overlay specific to each theme
    local time = love.timer.getTime()
    if self.selected_theme == 1 then -- vintage-sunset
        -- Dust particles floating effect
        for i = 1, 30 do
            local x = (time * 5 + i * 50) % love.graphics.getWidth()
            local y = (math.sin(time + i) * 50 + i * 30) % love.graphics.getHeight()
            love.graphics.setColor(1, 1, 0.8, 0.05)
            love.graphics.circle("fill", x, y, 2)
        end
    elseif self.selected_theme == 2 then -- retro-pixel
        -- Blocky pattern movement
        for i = 0, love.graphics.getHeight(), 80 do
            for j = 0, love.graphics.getWidth(), 80 do
                if (i + j + math.floor(time * 2)) % 3 == 0 then
                    love.graphics.setColor(0.7, 0.8, 1.0, 0.05)
                    love.graphics.rectangle("fill", j, i, 40, 40)
                end
            end
        end
    elseif self.selected_theme == 3 then -- monochrome
        -- Fading circles
        for i = 1, 20 do
            local radius = 20 + 10 * math.sin(time + i)
            local x = (time * 10 + i * 60) % love.graphics.getWidth()
            local y = (i * 50) % love.graphics.getHeight()
            love.graphics.setColor(1, 1, 1, 0.02)
            love.graphics.circle("fill", x, y, radius)
        end
    elseif self.selected_theme == 4 then -- cyberpunk
        -- Digital rain effect (Matrix-like)
        for i = 1, 30 do
            local x = (i * 40) % love.graphics.getWidth()
            local y = (time * 50 + i * 60) % love.graphics.getHeight()
            love.graphics.setColor(0, 1, 0.8, 0.05)
            love.graphics.print(string.char(math.random(33, 126)), x, y)
        end
    end
end

-- Enhance hover indicator with a glow effect
function GameGUI:drawHoverIndicator()
    if self.hover_column and not self.game_over and self.current_player == 1 then
        local x = MARGIN + (self.hover_column - 1) * CELL_SIZE + CELL_SIZE / 2
        local pulse = 0.8 + 0.2 * math.sin(love.timer.getTime() * 5)
        love.graphics.setColor(1, 1, 0, pulse) -- Yellow glow
        love.graphics.circle("fill", x, MARGIN / 2, RADIUS * 0.9)
        love.graphics.setColor(1, 1, 1, 0.3)
        love.graphics.circle("line", x, MARGIN / 2, RADIUS * 1.1)
    end
end

-- Add tooltips for buttons
function GameGUI:drawButtonTooltip()
    if self.state ~= "menu" then
        local mouse_x, mouse_y = love.mouse.getPosition()
        local buttonX = love.graphics.getWidth() - 100 - 10
        local buttonY = 10
        if mouse_x >= buttonX and mouse_x <= buttonX + 100 and
           mouse_y >= buttonY and mouse_y <= buttonY + 40 then
            love.graphics.setColor(0, 0, 0, 0.7)
            love.graphics.rectangle("fill", mouse_x + 10, mouse_y + 10, 120, 30, 5, 5)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf("Return to Menu", mouse_x + 15, mouse_y + 15, 110, "left")
        end
    end
end


function GameGUI:draw()
    -- Draw the themed background first
    self:drawBackground()
    
    local COLORS = self:getCurrentTheme()
    
    -- If we're in menu state, let the menu drawing handle it
    if self.state == "menu" then
        self:drawMenu()
        return
    end    local board_width = COLUMNS * CELL_SIZE
    local board_height = ROWS * CELL_SIZE
    
    -- Create a stencil for the inner board area to apply special effects
    love.graphics.stencil(function()
        love.graphics.rectangle("fill", MARGIN, MARGIN, board_width, board_height, 12)
    end, "replace", 1)
    
    -- Draw the theme image as the board background first
    love.graphics.setStencilTest("equal", 1)
    local themeImage = self.theme_images[self.selected_theme]
    if themeImage then
        -- Draw the theme image as the board background with a special effect
        -- We want it to look like the theme is showing through a translucent board
        love.graphics.setColor(1, 1, 1, 0.7) -- More visible background inside the board
        
        local windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()
        local imageWidth, imageHeight = themeImage:getWidth(), themeImage:getHeight()
        
        -- Add a subtle parallax effect based on mouse position to create depth
        local mouse_x, mouse_y = love.mouse.getPosition()
        local offset_x = (mouse_x - windowWidth/2) / windowWidth * 20
        local offset_y = (mouse_y - windowHeight/2) / windowHeight * 20
        
        local scaleX = windowWidth / imageWidth * 1.2 -- Zoom in a bit for the board area
        local scaleY = windowHeight / imageHeight * 1.2
        local scale = math.max(scaleX, scaleY)
        
        -- Center the image with the parallax offset
        local scaledWidth = imageWidth * scale
        local scaledHeight = imageHeight * scale
        local x = (windowWidth - scaledWidth) / 2 - offset_x
        local y = (windowHeight - scaledHeight) / 2 - offset_y
        
        love.graphics.draw(themeImage, x, y, 0, scale, scale)
          -- Add texture overlay specific to the current theme for more integrated look
        love.graphics.setBlendMode("alpha", "alphamultiply")
        local theme_overlay_alpha = 0.3
        if self.selected_theme == 1 then -- vintage-sunset
            love.graphics.setColor(0.9 * theme_overlay_alpha, 0.7 * theme_overlay_alpha, 0.5 * theme_overlay_alpha, theme_overlay_alpha) -- warm sepia overlay
        elseif self.selected_theme == 2 then -- retro-pixel
            love.graphics.setColor(0.7 * theme_overlay_alpha, 0.8 * theme_overlay_alpha, 1.0 * theme_overlay_alpha, theme_overlay_alpha) -- slight blue tint
        elseif self.selected_theme == 3 then -- monochrome
            love.graphics.setColor(0.9 * theme_overlay_alpha, 0.9 * theme_overlay_alpha, 0.9 * theme_overlay_alpha, theme_overlay_alpha) -- light gray overlay
        elseif self.selected_theme == 4 then -- cyberpunk
            love.graphics.setColor(0.5 * theme_overlay_alpha, 0.9 * theme_overlay_alpha, 1.0 * theme_overlay_alpha, theme_overlay_alpha) -- cyan tint
        end
        love.graphics.rectangle("fill", MARGIN, MARGIN, board_width, board_height)
        love.graphics.setBlendMode("alpha")
    end
    love.graphics.setStencilTest()
    
    -- First draw a soft glow border that blends with the background
    love.graphics.setColor(
        COLORS.board[1] * 0.8,
        COLORS.board[2] * 0.8,
        COLORS.board[3] * 0.8,
        0.4  -- Very transparent outer border
    )
    -- Outer glow
    love.graphics.rectangle("fill", MARGIN-10, MARGIN-10, board_width+20, board_height+20, 15)
    
    -- Draw a very subtle inner shadow around the board edges for depth
    local shadow_size = 20
    for i = 0, shadow_size do
        local alpha = (shadow_size - i) / shadow_size * 0.2
        love.graphics.setColor(0, 0, 0, alpha)
        love.graphics.rectangle("line", MARGIN + i/2, MARGIN + i/2, board_width - i, board_height - i, 12 - i/4)
    end
    
    -- Then draw the actual board with a gradient but very transparent
    for i = 0, board_height do
        local ratio = i / board_height
        -- Much more subtle gradient with higher transparency
        love.graphics.setColor(
            COLORS.board[1] * (1 - ratio) + ratio * COLORS.board[1] * 1.05,
            COLORS.board[2] * (1 - ratio) + ratio * COLORS.board[2] * 1.05,
            COLORS.board[3] * (1 - ratio) + ratio * COLORS.board[3] * 1.05,
            0.3 + 0.1 * ratio  -- Very transparent to let background show through
        )
        love.graphics.rectangle("fill", MARGIN, MARGIN + i, board_width, 1)
    end-- Draw hover indicator with subtle glow
    if self.hover_column and not self.game_over and self.current_player == 1 then
        local x = MARGIN + (self.hover_column - 1) * CELL_SIZE + CELL_SIZE / 2
        local pulse = 0.6 + 0.4 * math.sin(love.timer.getTime() * 4)
        
        -- Outer glow - very subtle
        love.graphics.setColor(
            COLORS.highlight[1] * 0.8,
            COLORS.highlight[2] * 0.8,
            COLORS.highlight[3] * 0.8,
            0.2 * pulse
        )
        love.graphics.circle("fill", x, MARGIN / 2, RADIUS * 1.2)
        
        -- Inner glow - slightly more visible
        love.graphics.setColor(
            COLORS.highlight[1],
            COLORS.highlight[2],
            COLORS.highlight[3],
            0.5 * pulse
        )
        love.graphics.circle("fill", x, MARGIN / 2, RADIUS * 0.9)
    end

    -- Draw coins
    for col = 1, COLUMNS do
        for row = 1, ROWS do
            local cell = self.boardState.grid[row][col]
            local x = MARGIN + (col - 1) * CELL_SIZE + CELL_SIZE / 2
            local y = MARGIN + (row - 1) * CELL_SIZE + CELL_SIZE / 2

            -- Skip if this coin is part of the falling animation
            local skip = false
            for _, coin in ipairs(self.falling_coins) do
                if coin.col == col and coin.row == row then
                    skip = true
                    break
                end
            end
            if skip then goto continue end

            -- Skip if this is a winning coin (it will be drawn in the animation)
            for _, coin in ipairs(self.winning_coins) do
                if coin.col == col and coin.row == row then
                    skip = true
                    break
                end
            end            if skip then goto continue end
            
            -- Draw holes/coins with a different approach to better blend with background
            local color = COLORS.empty
            if cell == 1 then color = COLORS.player1
            elseif cell == 2 then color = COLORS.player2 end
            
            -- For empty spaces - create a transparent "hole" effect
            if cell == 0 then
                -- Create a hole effect that reveals the background
                -- First draw a subtle ring to define the hole
                love.graphics.setColor(0, 0, 0, 0.25) 
                love.graphics.circle("fill", x, y, RADIUS * 1.05)
                
                -- Use stencil to create a see-through hole
                love.graphics.stencil(function()
                    love.graphics.circle("fill", x, y, RADIUS * 0.95)
                end, "replace", 1)
                
                love.graphics.setStencilTest("equal", 1)
                
                -- Draw a zoomed portion of the background image in the hole
                if themeImage then
                    -- Here we're creating a "peephole" effect where the theme shows through
                    love.graphics.setColor(1, 1, 1, 1)
                    
                    -- Calculate position to draw image in the hole
                    local windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()
                    local imageWidth, imageHeight = themeImage:getWidth(), themeImage:getHeight()
                    
                    -- Add a subtle parallax effect specific to each hole
                    local hole_offset_x = math.sin(x / 30) * 5
                    local hole_offset_y = math.cos(y / 30) * 5
                    
                    -- Calculate scaling to make the image fit the window
                    local scaleX = windowWidth / imageWidth * 1.3  -- Zoom more for the hole effect
                    local scaleY = windowHeight / imageHeight * 1.3
                    local scale = math.max(scaleX, scaleY)
                    
                    -- Calculate position to draw centered
                    local scaledWidth = imageWidth * scale
                    local scaledHeight = imageHeight * scale
                    local imgX = (windowWidth - scaledWidth) / 2 + hole_offset_x
                    local imgY = (windowHeight - scaledHeight) / 2 + hole_offset_y
                    
                    -- Draw the theme image inside the hole
                    love.graphics.draw(themeImage, imgX, imgY, 0, scale, scale)
                      -- Add a theme-specific overlay inside the hole
                    love.graphics.setBlendMode("alpha", "alphamultiply")
                    if self.selected_theme == 1 then -- vintage-sunset
                        love.graphics.setColor(0.9 * 0.4, 0.7 * 0.4, 0.5 * 0.4, 0.4) -- warm tone
                    elseif self.selected_theme == 2 then -- retro-pixel
                        love.graphics.setColor(0.7 * 0.4, 0.8 * 0.4, 1.0 * 0.4, 0.4) -- blue tint
                    elseif self.selected_theme == 3 then -- monochrome
                        love.graphics.setColor(0.85 * 0.4, 0.85 * 0.4, 0.85 * 0.4, 0.4) -- slight gray
                    elseif self.selected_theme == 4 then -- cyberpunk
                        love.graphics.setColor(0.6 * 0.4, 0.8 * 0.4, 1.0 * 0.4, 0.4) -- slight cyan
                    end
                    love.graphics.circle("fill", x, y, RADIUS * 0.95)
                    love.graphics.setBlendMode("alpha")
                end
                
                -- Add a subtle inner highlight
                love.graphics.setColor(1, 1, 1, 0.2)
                love.graphics.arc("fill", x, y, RADIUS * 0.9, math.pi * 0.7, math.pi * 1.3)
                
                love.graphics.setStencilTest()
                
                -- Add a subtle edge glow to define the hole
                love.graphics.setColor(0.2, 0.2, 0.2, 0.3)
                love.graphics.circle("line", x, y, RADIUS * 1.05)
            else
                -- For player coins - add depth and context-aware styling
                
                -- Subtle shadow for depth
                love.graphics.setColor(0, 0, 0, 0.2)
                love.graphics.circle("fill", x + 2, y + 2, RADIUS * 0.95)
                
                -- Create reflective edge effect based on theme
                love.graphics.stencil(function()
                    love.graphics.circle("fill", x, y, RADIUS)
                end, "replace", 1)
                
                love.graphics.setStencilTest("equal", 1)
                
                -- Add a subtle reflection of the background to the coin
                love.graphics.setColor(1, 1, 1, 0.1)
                if themeImage then
                    local windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()
                    local imageWidth, imageHeight = themeImage:getWidth(), themeImage:getHeight()
                    local scaleX = windowWidth / imageWidth * 1.5 -- More zoomed for the reflection
                    local scaleY = windowHeight / imageHeight * 1.5
                    local scale = math.max(scaleX, scaleY)
                    local scaledWidth = imageWidth * scale
                    local scaledHeight = imageHeight * scale
                    local imgX = (windowWidth - scaledWidth) / 2
                    local imgY = (windowHeight - scaledHeight) / 2
                    love.graphics.draw(themeImage, imgX, imgY, 0, scale, scale)
                end
                
                love.graphics.setStencilTest()
                
                -- Draw the main coin with a subtle gradient for dimension
                local gradient_intensity = 0.2
                love.graphics.setColor(
                    color[1] * (1 - gradient_intensity) + color[1] * 1.1 * gradient_intensity,
                    color[2] * (1 - gradient_intensity) + color[2] * 1.1 * gradient_intensity,
                    color[3] * (1 - gradient_intensity) + color[3] * 1.1 * gradient_intensity,
                    0.9 -- Slightly transparent to blend with theme
                )
                love.graphics.circle("fill", x, y, RADIUS * 0.95)
                
                -- Add highlight for dimension
                love.graphics.setColor(1, 1, 1, 0.2)
                love.graphics.arc("fill", x, y, RADIUS * 0.7, math.pi * 0.7, math.pi * 1.5)
                
                -- Add a thin ring around the coin edge
                love.graphics.setColor(color[1] * 0.7, color[2] * 0.7, color[3] * 0.7, 0.6)
                love.graphics.circle("line", x, y, RADIUS * 0.95)
            end
            
            ::continue::
        end
    end    -- Draw falling coins animation
    for i, coin in ipairs(self.falling_coins) do
        local x = MARGIN + (coin.col - 1) * CELL_SIZE + CELL_SIZE / 2
        local color = coin.player == 1 and COLORS.player1 or COLORS.player2
        
        -- Shadow for depth
        love.graphics.setColor(0, 0, 0, 0.1)
        love.graphics.circle("fill", x + 3, coin.y + 3, RADIUS)
        
        -- Soft outer glow
        love.graphics.setColor(color[1], color[2], color[3], 0.3)
        love.graphics.circle("fill", x, coin.y, RADIUS * 1.1)
        
        -- Actual coin
        love.graphics.setColor(color)
        love.graphics.circle("fill", x, coin.y, RADIUS)
        
        -- Highlight
        love.graphics.setColor(1, 1, 1, 0.15)
        love.graphics.circle("fill", x - RADIUS/3, coin.y - RADIUS/3, RADIUS/3)
    end

    -- Draw winning coins animation
    if #self.winning_coins > 0 then
        local pulse = 0.7 + 0.3 * math.sin(love.timer.getTime() * 8)
        for _, coin in ipairs(self.winning_coins) do
            local x = MARGIN + (coin.col - 1) * CELL_SIZE + CELL_SIZE / 2
            local y = MARGIN + (coin.row - 1) * CELL_SIZE + CELL_SIZE / 2
            
            -- Pulsing effect with color
            local color = coin.player == 1 and COLORS.player1 or COLORS.player2
            
            -- Outer glow with more subtlety
            love.graphics.setColor(
                color[1] * pulse * 0.8,
                color[2] * pulse * 0.8, 
                color[3] * pulse * 0.8,
                0.4
            )
            love.graphics.circle("fill", x, y, RADIUS * 1.4)
            
            -- Middle glow
            love.graphics.setColor(
                color[1] * pulse,
                color[2] * pulse,
                color[3] * pulse,
                0.7
            )
            love.graphics.circle("fill", x, y, RADIUS * 1.2)
            
            -- Actual coin
            love.graphics.setColor(color)
            love.graphics.circle("fill", x, y, RADIUS)
            
            -- Highlight
            love.graphics.setColor(1, 1, 1, 0.3 * pulse)
            love.graphics.circle("fill", x - RADIUS/3, y - RADIUS/3, RADIUS/3)
        end
    end

    -- Draw current player indicator
    love.graphics.setColor(COLORS.current_player)
    local font = love.graphics.newFont(24)
    love.graphics.setFont(font)

    local pulse = 0.5 + 0.5 * math.sin(love.timer.getTime() * 3)
    local y_offset = 5 * pulse

    local currentPlayerText = "PLAYER " .. self.current_player .. "'S TURN"
    if self.current_player == 2 then
        currentPlayerText = "AI'S TURN (" .. self.difficulty:upper() .. ")"
    end
    love.graphics.printf(currentPlayerText,
                       MARGIN, MARGIN + board_height + 15 + y_offset,
                       board_width, "center")

    -- Draw game over screen     -- Draw game over screen
     if self.game_over then
        -- Softer semi-transparent overlay with gradient
        for i = 0, board_height do
            local ratio = i / board_height
            love.graphics.setColor(
                0, 0, 0, 
                0.6 - 0.2 * ratio  -- Gradient transparency from top to bottom
            )
            love.graphics.rectangle("fill", MARGIN, MARGIN + i, board_width, 1)
        end
        
        -- Winner text with glow effect
        local message = self.winner and
                           (self.winner == 1 and "PLAYER WINS!" or "AI WINS!") or
                           "DRAW GAME!"
        
        -- Text glow
        local glow_intensity = 0.5 + 0.2 * math.sin(love.timer.getTime() * 3)
        love.graphics.setColor(
            COLORS.text[1] * 0.5, 
            COLORS.text[2] * 0.5, 
            COLORS.text[3] * 0.5, 
            glow_intensity * 0.7
        )
        local font = love.graphics.newFont(48)
        love.graphics.setFont(font)
        love.graphics.printf(message, MARGIN - 2, MARGIN + board_height / 2 - 42,
                            board_width, "center")
                            
        -- Main text
        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.printf(message, MARGIN, MARGIN + board_height / 2 - 40,
                           board_width, "center")        -- Theme name with more subtle styling
        love.graphics.setColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], 0.8)
        font = love.graphics.newFont(20)
        love.graphics.setFont(font)
        love.graphics.printf("Theme: " .. self.themes[self.selected_theme], 
                           MARGIN, MARGIN + board_height / 2 + 20,
                           board_width, "center")
        
        -- Play again text with pulsing effect
        if math.floor(love.timer.getTime() * 2) % 2 == 0 then
            font = love.graphics.newFont(24)
            love.graphics.setFont(font)
            -- Gentle glow behind text
            love.graphics.setColor(COLORS.highlight[1] * 0.5, COLORS.highlight[2] * 0.5, COLORS.highlight[3] * 0.5, 0.5)
            love.graphics.printf("CLICK TO PLAY AGAIN", MARGIN,
                                MARGIN + board_height / 2 + 60,
                                board_width, "center")
            -- Main text
            love.graphics.setColor(1, 1, 1, 0.9)
            love.graphics.printf("CLICK TO PLAY AGAIN", MARGIN,
                                MARGIN + board_height / 2 + 60,
                                board_width, "center")
        end
    end

    -- Draw back to menu button (always visible except in menu)
    if self.state ~= "menu" then
        local buttonText = "MENU"
        local buttonWidth = 100
        local buttonHeight = 40
        local buttonX = love.graphics.getWidth() - buttonWidth - 10
        local buttonY = 10
        
        -- Button background
        love.graphics.setColor(COLORS.board)
        love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, buttonHeight, 5, 5)
        
        -- Button border
        love.graphics.setColor(COLORS.highlight)
        love.graphics.rectangle("line", buttonX, buttonY, buttonWidth, buttonHeight, 5, 5)
        
        -- Button text
        love.graphics.setColor(COLORS.text)
        local font = love.graphics.newFont(20)
        love.graphics.setFont(font)
        love.graphics.printf(buttonText, buttonX, buttonY + 10, buttonWidth, "center")
    end
    -- self:drawButtonTooltip()
end

function GameGUI:update(dt)
    if self.state == "game_over" then return end
    
    -- Update hover column
    local mouse_x, mouse_y = love.mouse.getPosition()
    if mouse_x >= MARGIN and mouse_x <= MARGIN + COLUMNS * CELL_SIZE then
        self.hover_column = math.floor((mouse_x - MARGIN) / CELL_SIZE) + 1
    else
        self.hover_column = nil
    end

    -- AI move
    if not self.game_over and self.current_player == 2 and not self.ai_is_playing then
        if not self.ai_move_timer then
            -- Start the timer when it's AI's turn
            self.ai_move_timer = 0.8 -- 0.8 second delay before AI moves
        else
            self.ai_move_timer = self.ai_move_timer - dt
            if self.ai_move_timer <= 0 then
                self.ai_is_playing = true
                local bestMove = self:getBestAIMove()
                if bestMove then
                    self:addPiece(bestMove)
                end
                self.ai_is_playing = false
                self.ai_move_timer = nil -- Reset timer
            end
        end
    end
    
    -- Update falling coins animation
    for i = #self.falling_coins, 1, -1 do
        local coin = self.falling_coins[i]
        coin.y = coin.y + 800 * dt -- Falling speed
        
        -- Target y position
        local target_y = MARGIN + (coin.row - 1) * CELL_SIZE + CELL_SIZE / 2
        if coin.y >= target_y then
            table.remove(self.falling_coins, i)
        end
    end
    
    -- Update animation timer
    if self.game_over then
        self.animation_timer = self.animation_timer + dt
    end
end

function GameGUI:mousepressed(x, y, button)
    if button == 1 then  -- Left click
        -- Check if menu button was clicked
        if self.state ~= "menu" then
            local buttonWidth = 150
            local buttonHeight = 40
            local buttonX = love.graphics.getWidth() - buttonWidth - 20
            local buttonY = 20
            
            if x >= buttonX and x <= buttonX + buttonWidth and
               y >= buttonY and y <= buttonY + buttonHeight then
                self:returnToMenu()
                return
            end
        end
        
        if self.game_over then
            self:resetGame()
        elseif self.hover_column and self.current_player == 1 then
            self:addPiece(self.hover_column)
        end
    end
end


function GameGUI:returnToMenu()
    self.state = "menu"
    self.ai_move_timer = nil -- Clear any pending AI move
    if self.sounds.drop then
        self.sounds.drop:play()
    end
end

function GameGUI:keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "return" and self.state == "menu" then
        self.state = "playing"
        if self.sounds.drop then
            self.sounds.drop:play()
        end
    elseif key == "m" and (self.state == "playing" or self.state == "game_over") then
        self:returnToMenu()
    end
end


function GameGUI:addPiece(column)
    if self.game_over then return end

    if self.boardState:isValidMove(column) then
        -- Find the row where the piece will land
        local row = ROWS
        for r = 1, ROWS do
            if self.boardState.grid[r][column] ~= Board.EMPTY then
                row = r - 1
                break
            end
        end
        
        -- Add to falling animation
        table.insert(self.falling_coins, {
            col = column,
            row = row,
            y = MARGIN - CELL_SIZE / 2,
            player = self.current_player
        })
        
        if self.sounds.drop then
            self.sounds.drop:play()
        end
        
        -- Actually make the move after a short delay (for animation)
        local madeMove = self.boardState:makeMove(column, self.current_player)
        if madeMove then
            local win, winCoins = self.boardState:checkWin(self.current_player)
            if win then
                self.game_over = true
                self.winner = self.current_player
                self.winning_coins = winCoins or {}
                if self.sounds.win then
                    self.sounds.win:play()
                end
            elseif self.boardState:isFull() then
                self.game_over = true
                self.winner = nil -- It's a draw
                if self.sounds.draw then
                    self.sounds.draw:play()
                end
            else
                self.current_player = 3 - self.current_player -- Switch player
            end
        end
    end
end

function GameGUI:getBestAIMove()
    local bestScore = -math.huge
    local bestColumn = nil
    local depth = DIFFICULTY_DEPTHS[self.difficulty]  -- Default to medium

    for col = 1, COLUMNS do
        if self.boardState:isValidMove(col) then
            local tempBoard = self.boardState:copy()
            tempBoard:makeMove(col, 2) -- Assuming AI is player 2
            local score = AI.minimaxWithAlphabeta(tempBoard, 0, -math.huge, math.huge, false, 2, depth)

            if score > bestScore then
                bestScore = score
                bestColumn = col
            end
        end
    end
    return bestColumn
end

function GameGUI:resetGame()
    self.boardState = Board:new()
    self.game_over = false
    self.winner = nil
    self.current_player = 1
    self.ai_is_playing = false
    self.winning_coins = {}
    self.falling_coins = {}
    self.animation_timer = 0
end

return GameGUI