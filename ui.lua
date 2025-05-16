local Board = require("game_logic_demo")
local AI = require("ai")
local GameGUI = {}

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
    local obj = {
        boardState = Board:new(),
        hover_column = nil,
        current_player = 1,
        game_over = false,
        winner = nil,
        ai_is_playing = false -- Set to true if you want AI to start
    }
    setmetatable(obj, {__index = GameGUI})
    return obj
end

function GameGUI:draw()
    love.graphics.setColor(COLORS.background)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    local board_width = COLUMNS * CELL_SIZE
    local board_height = ROWS * CELL_SIZE

    for i = 0, board_height do
        local ratio = i / board_height
        love.graphics.setColor(
            COLORS.board[1] * (1 - ratio) + ratio * COLORS.board[1] * 1.3,
            COLORS.board[2] * (1 - ratio) + ratio * COLORS.board[2] * 1.3,
            COLORS.board[3] * (1 - ratio) + ratio * COLORS.board[3] * 1.3
        )
        love.graphics.rectangle("fill", MARGIN, MARGIN + i, board_width, 1)
    end

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

    for col = 1, COLUMNS do
        for row = 1, ROWS do
            local cell = self.boardState.grid[row][col]
            local x = MARGIN + (col - 1) * CELL_SIZE + CELL_SIZE / 2
            local y = MARGIN + (row - 1) * CELL_SIZE + CELL_SIZE / 2

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
        end
    end

    love.graphics.setColor(COLORS.current_player)
    local font = love.graphics.newFont(24)
    love.graphics.setFont(font)

    local pulse = 0.5 + 0.5 * math.sin(love.timer.getTime() * 3)
    local y_offset = 5 * pulse

    local currentPlayerText = "PLAYER " .. self.current_player .. "'S TURN"
    if self.current_player == 2 then
        currentPlayerText = "AI'S TURN"
    end
    love.graphics.printf(currentPlayerText,
                        MARGIN, MARGIN + board_height + 15 + y_offset,
                        board_width, "center")

    if self.game_over then
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
    local mouse_x, mouse_y = love.mouse.getPosition()
    if mouse_x >=MARGIN and mouse_x <= MARGIN + COLUMNS * CELL_SIZE then
        self.hover_column = math.floor((mouse_x - MARGIN) / CELL_SIZE) + 1
    else
        self.hover_column = nil
    end

    if not self.game_over and self.current_player == 2 and not self.ai_is_playing then
        self.ai_is_playing = true
        local bestMove = self:getBestAIMove()
        if bestMove then
            self:addPiece(bestMove)
        end
        self.ai_is_playing = false
    end
end

function GameGUI:mousepressed(x, y, button)
    if button == 1 then  -- Left click
        if self.game_over then
            self:resetGame()
        elseif self.hover_column and self.current_player == 1 then
            self:addPiece(self.hover_column)
        end
    end
end

function GameGUI:keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function GameGUI:addPiece(column)
    if self.game_over then return end

    if self.boardState:isValidMove(column) then
        local madeMove = self.boardState:makeMove(column, self.current_player)
        if madeMove then
            local win, _ = self.boardState:checkWin(self.current_player)
            if win then
                self.game_over = true
                self.winner = self.current_player
            elseif self.boardState:isFull() then
                self.game_over = true
                self.winner = nil -- It's a draw
            else
                self.current_player = 3 - self.current_player -- Switch player
            end
        end
    end
end

function GameGUI:getBestAIMove()
    local bestScore = -math.huge
    local bestColumn = nil

    for col = 1, COLUMNS do
        if self.boardState:isValidMove(col) then
            local tempBoard = self.boardState:copy()
            tempBoard:makeMove(col, 2) -- Assuming AI is player 2
            local score = AI.minimaxWithAlphabeta(tempBoard, 0, -math.huge, math.huge, false, 2)

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
end

return GameGUI

