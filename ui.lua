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
    -- Original theme renamed to "Vintage Sunset"
    ["Vintage Sunset"] = {
        empty = {255/255, 181/255, 167/255},
        player1 = {220/255, 47/255, 2/255},
        player2 = {255/255, 186/255, 8/255},
        board = {55/255, 6/255, 23/255},       
        highlight = {244/255, 140/255, 6/255},
        text = {250/255, 163/255, 7/255},
        background = {199/255, 81/255, 70/255}, 
        current_player = {232/255, 93/255, 4/255}
    },
    ["Retro Pixel"] = {
        empty = {200/255, 220/255, 240/255},
        player1 = {255/255, 50/255, 50/255},
        player2 = {50/255, 200/255, 50/255},
        board = {80/255, 80/255, 120/255},
        highlight = {255/255, 255/255, 100/255},
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
        highlight = {255/255, 255/255, 0/255},
        text = {0/255, 255/255, 255/255},
        background = {10/255, 0/255, 20/255},
        current_player = {200/255, 0/255, 255/255}
    }
}

-- Difficulty settings (affects AI depth)
local DIFFICULTY_DEPTHS = {
    Easy = 2,
    Medium = 4,
    Hard = 6
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
        selected_theme = 1,
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
        
    }
    setmetatable(obj, {__index = GameGUI})
    return obj
end



function GameGUI:drawThemeOptions(x, y, width, COLORS)
    local popup_height = #self.themes * 40
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
        local item_y = popup_y + (i - 1) * 40
        if i == self.selected_theme then
            love.graphics.setColor(COLORS.highlight)
            love.graphics.rectangle("fill", x + 5, item_y + 5, width - 10, 30, 5)
        end
        love.graphics.setColor(COLORS.text)
        love.graphics.printf(theme, x, item_y + 10, width, "center")
    end
end



function GameGUI:getCurrentTheme()
    return THEMES[self.themes[self.selected_theme]]
end

function GameGUI:drawMenu()
    local COLORS = self:getCurrentTheme()
    love.graphics.setColor(COLORS.background)
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
                local option_y = popup_y + (i - 1) * 40
                if x >= button_x and x <= button_x + button_width and
                   y >= option_y and y <= option_y + 40 then
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
    local time = love.timer.getTime()
    for i = 0, love.graphics.getHeight(), 50 do
        local colorIntensity = 0.2 + 0.1 * math.sin(time + i * 0.1)
        love.graphics.setColor(0.1, 0.1, 0.2 + colorIntensity, 0.5)
        love.graphics.rectangle("fill", 0, i, love.graphics.getWidth(), 50)
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
    self:drawBackground()
    local COLORS = self:getCurrentTheme()
    love.graphics.setColor(COLORS.background)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    local board_width = COLUMNS * CELL_SIZE
    local board_height = ROWS * CELL_SIZE

    -- Draw board background with gradient
    for i = 0, board_height do
        local ratio = i / board_height
        love.graphics.setColor(
            COLORS.board[1] * (1 - ratio) + ratio * COLORS.board[1] * 1.3,
            COLORS.board[2] * (1 - ratio) + ratio * COLORS.board[2] * 1.3,
            COLORS.board[3] * (1 - ratio) + ratio * COLORS.board[3] * 1.3
        )
        love.graphics.rectangle("fill", MARGIN, MARGIN + i, board_width, 1)
    end
     local COLORS = self:getCurrentTheme()
    love.graphics.setColor(COLORS.background)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- Draw hover indicator
    if self.hover_column and not self.game_over and self.current_player == 1 then
        local x = MARGIN + (self.hover_column - 1) * CELL_SIZE + CELL_SIZE / 2
        local pulse = 0.8 + 0.2 * math.sin(love.timer.getTime() * 5)
        love.graphics.setColor(
            COLORS.highlight[1],
            COLORS.highlight[2],
            COLORS.highlight[3],
            pulse
        )
        love.graphics.circle("fill", x, MARGIN / 2, RADIUS * 0.8)
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
            end
            if skip then goto continue end

            love.graphics.setColor(0, 0, 0, 0.2)
            love.graphics.circle("fill", x + 2, y + 2, RADIUS)

            local color = COLORS.empty
            if cell == 1 then color = COLORS.player1
            elseif cell == 2 then color = COLORS.player2 end

            love.graphics.setColor(color)
            love.graphics.circle("fill", x, y, RADIUS)

            if cell then
                love.graphics.setColor(1, 1, 1, 0.2)
                love.graphics.circle("fill", x - RADIUS/3, y - RADIUS/3, RADIUS/3)
            end
            
            ::continue::
        end
    end

    -- Draw falling coins animation
    for i, coin in ipairs(self.falling_coins) do
        local x = MARGIN + (coin.col - 1) * CELL_SIZE + CELL_SIZE / 2
        local color = coin.player == 1 and COLORS.player1 or COLORS.player2
        
        love.graphics.setColor(0, 0, 0, 0.2)
        love.graphics.circle("fill", x + 2, coin.y + 2, RADIUS)
        
        love.graphics.setColor(color)
        love.graphics.circle("fill", x, coin.y, RADIUS)
        
        love.graphics.setColor(1, 1, 1, 0.2)
        love.graphics.circle("fill", x - RADIUS/3, coin.y - RADIUS/3, RADIUS/3)
    end

    -- Draw winning coins animation
    if #self.winning_coins > 0 then
        local pulse = 0.7 + 0.3 * math.sin(love.timer.getTime() * 8)
        for _, coin in ipairs(self.winning_coins) do
            local x = MARGIN + (coin.col - 1) * CELL_SIZE + CELL_SIZE / 2
            local y = MARGIN + (coin.row - 1) * CELL_SIZE + CELL_SIZE / 2
            
            -- Pulsing effect
            local color = coin.player == 1 and COLORS.player1 or COLORS.player2
            love.graphics.setColor(
                color[1] * pulse,
                color[2] * pulse,
                color[3] * pulse
            )
            
            -- Draw larger coin with glow
            love.graphics.circle("fill", x, y, RADIUS * 1.2)
            
            -- Draw normal sized coin
            love.graphics.setColor(color)
            love.graphics.circle("fill", x, y, RADIUS)
            
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

    -- Draw game over screen
     -- Draw game over screen
     if self.game_over then
        -- Dark overlay
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", MARGIN, MARGIN, board_width, board_height)
        
        -- Winner text
        love.graphics.setColor(1, 1, 1)
        local message = self.winner and
                           (self.winner == 1 and "PLAYER WINS!" or "AI WINS!") or
                           "DRAW GAME!"
        local font = love.graphics.newFont(48)
        love.graphics.setFont(font)
        love.graphics.printf(message, MARGIN, MARGIN + board_height / 2 - 40,
                           board_width, "center")

        -- Theme name
        love.graphics.setColor(COLORS.text)
        font = love.graphics.newFont(20)
        love.graphics.setFont(font)
        love.graphics.printf("Theme: " .. self.themes[self.selected_theme], 
                           MARGIN, MARGIN + board_height / 2 + 20,
                           board_width, "center")
        
        if math.floor(love.timer.getTime() * 2) % 2 == 0 then
            font = love.graphics.newFont(24)
            love.graphics.setFont(font)
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
    local depth = DIFFICULTY_DEPTHS[self.difficulty] or 4 -- Default to medium

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