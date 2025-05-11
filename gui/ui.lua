local GameGUI = {}

-- Configuration using the provided color palette
local COLUMNS = 7
local ROWS = 6
local CELL_SIZE = 80
local MARGIN = 70
local RADIUS = CELL_SIZE / 2 - 5
local COLORS = {
    empty = {255/255, 181/255, 167/255},  -- Light gray
    player1 = {220/255, 47/255, 2/255},    -- Sinopia
    player2 = {255/255, 186/255, 8/255},   -- Selective Yellow
    board = {55/255, 6/255, 23/255},       -- Chocolate Cosmos
    highlight = {244/255, 140/255, 6/255}, -- Princeton Orange
    text = {250/255, 163/255, 7/255},      -- Orange Web
    background = {199/255, 81/255, 70/255},   -- Rich Black
    current_player = {232/255, 93/255, 4/255} -- Persimmon
}

function GameGUI:new()
    --Local Object for demonstration
    local obj = {
        board = {},
        hover_column = nil,
        current_player = 1,
        game_over = false,
        winner = nil
    }
    
    -- Initialize empty board
    for col = 1, COLUMNS do
        obj.board[col] = {}
        for row = 1, ROWS do
            obj.board[col][row] = nil
        end
    end
    
    setmetatable(obj, {__index = GameGUI})
    return obj
end

function GameGUI:draw()
    -- Set background color
    love.graphics.setColor(COLORS.background)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Calculate total board dimensions
    local board_width = COLUMNS * CELL_SIZE
    local board_height = ROWS * CELL_SIZE
    
    -- Draw board background with subtle gradient effect
    for i = 0, board_height do
        local ratio = i / board_height
        love.graphics.setColor(
            COLORS.board[1] * (1 - ratio) + ratio * COLORS.board[1] * 1.3,
            COLORS.board[2] * (1 - ratio) + ratio * COLORS.board[2] * 1.3,
            COLORS.board[3] * (1 - ratio) + ratio * COLORS.board[3] * 1.3
        )
        love.graphics.rectangle("fill", MARGIN, MARGIN + i, board_width, 1)
    end
    
    -- Draw hover indicator with pulsing effect
    if self.hover_column and not self.game_over then
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
    
    -- Draw cells with subtle shadows
    for col = 1, COLUMNS do
        for row = 1, ROWS do
            local cell = self.board[col][row]
            local x = MARGIN + (col - 1) * CELL_SIZE + CELL_SIZE / 2
            local y = MARGIN + (ROWS - row) * CELL_SIZE + CELL_SIZE / 2
            
            -- Draw shadow
            love.graphics.setColor(0, 0, 0, 0.2)
            love.graphics.circle("fill", x + 2, y + 2, RADIUS)
            
            -- Determine cell color
            local color = COLORS.empty
            if cell == 1 then color = COLORS.player1
            elseif cell == 2 then color = COLORS.player2 end
            
            love.graphics.setColor(color)
            love.graphics.circle("fill", x, y, RADIUS)
            
            -- Add subtle highlight to pieces
            if cell then
                love.graphics.setColor(1, 1, 1, 0.2)
                love.graphics.circle("fill", x - RADIUS/3, y - RADIUS/3, RADIUS/3)
            end
        end
    end
    
    -- Draw current player indicator with animation
    love.graphics.setColor(COLORS.current_player)
    local font = love.graphics.newFont(24)
    love.graphics.setFont(font)
    
    local pulse = 0.5 + 0.5 * math.sin(love.timer.getTime() * 3)
    local y_offset = 5 * pulse
    
    love.graphics.printf("PLAYER " .. self.current_player .. "'S TURN", 
                        MARGIN, MARGIN + board_height + 15 + y_offset, 
                        board_width, "center")
    
    -- Draw game over message with gradient background
    if self.game_over then
        -- Gradient background
        for i = 0, 60 do
            local ratio = i / 60
            love.graphics.setColor(
                COLORS.player1[1] * ratio + COLORS.player2[1] * (1 - ratio),
                COLORS.player1[2] * ratio + COLORS.player2[2] * (1 - ratio),
                COLORS.player1[3] * ratio + COLORS.player2[3] * (1 - ratio),
                0.8
            )
            love.graphics.rectangle("fill", MARGIN, MARGIN + board_height / 2 - 30 + i, 
                                  board_width, 1)
        end
        
        love.graphics.setColor(1, 1, 1)
        local message = self.winner and 
                      ("PLAYER " .. self.winner .. " WINS!") or 
                      "DRAW GAME!"
        local font = love.graphics.newFont(36)
        love.graphics.setFont(font)
        love.graphics.printf(message, MARGIN, MARGIN + board_height / 2 - 20, 
                            board_width, "center")
        
        -- Draw restart prompt with blinking effect
        if math.floor(love.timer.getTime() * 2) % 2 == 0 then
            font = love.graphics.newFont(20)
            love.graphics.setFont(font)
            love.graphics.printf("CLICK TO PLAY AGAIN", MARGIN, 
                                MARGIN + board_height / 2 + 20, 
                                board_width, "center")
        end
    end
end

function GameGUI:update(dt)
    -- Update hover column based on mouse position
    local mouse_x, mouse_y = love.mouse.getPosition()
    if mouse_x >= MARGIN and mouse_x <= MARGIN + COLUMNS * CELL_SIZE then
        self.hover_column = math.floor((mouse_x - MARGIN) / CELL_SIZE) + 1
    else
        self.hover_column = nil
    end
end

function GameGUI:mousepressed(x, y, button)
    if button == 1 then  -- Left click
        if self.game_over then
            -- Reset game
            self:new()
        elseif self.hover_column then
            -- For demonstration, just add a piece to the bottom of the column
            self:addPiece(self.hover_column)
        end
    end
end

function GameGUI:addPiece(column)
    if self.game_over then return end
    
    -- Find the first empty row in the column
    for row = 1, ROWS do
        if not self.board[column][row] then
            self.board[column][row] = self.current_player
            
            -- Switch players
            self.current_player = self.current_player == 1 and 2 or 1
            return
        end
    end
end

function GameGUI:keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

return GameGUI