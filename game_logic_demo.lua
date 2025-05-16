local Board = {
    ROWS = 6,
    COLS = 7,
    EMPTY = 0,
    PLAYER1 = 1,
    PLAYER2 = 2
}

-- Initialize a new game board
function Board:new()
    local board = {
        grid = {},
        currentPlayer = self.PLAYER1,
        gameOver = false,
        winner = nil
    }
    setmetatable(board, self)
    self.__index = self
    
    board.grid = {}
    for i = 1, self.ROWS do
        board.grid[i] = {}
        for j = 1, self.COLS do
            board.grid[i][j] = self.EMPTY
        end
    end
    
    return board
end

function Board:copy()
    local newBoard = Board:new()
    for r = 1, self.ROWS do
        for c = 1, self.COLS do
            newBoard.grid[r][c] = self.grid[r][c]
        end
    end
    newBoard.currentPlayer = self.currentPlayer
    newBoard.gameOver = self.gameOver
    newBoard.winner = self.winner
    return newBoard
end

function Board:isValidMove(col)
    if col < 1 or col > self.COLS then
        return false
    end
    return self.grid[1][col] == self.EMPTY
end

-- Make a move in the specified column
function Board:makeMove(col, player)
    if not self:isValidMove(col) then
        return false
    end
    
    -- Find the lowest empty position in the column
    for row = self.ROWS, 1, -1 do
        if self.grid[row][col] == self.EMPTY then
            self.grid[row][col] = player
            return true
        end
    end
    return false
end

-- Check for a win condition
function Board:checkWin(player)
    -- Check horizontal
    for row = 1, self.ROWS do
        for col = 1, self.COLS - 3 do
            if self.grid[row][col] == player and
               self.grid[row][col + 1] == player and
               self.grid[row][col + 2] == player and
               self.grid[row][col + 3] == player then
                return true, string.format("Horizontal win at row %d, starting at column %d", row, col)
            end
        end
    end

    -- Check vertical
    for row = 1, self.ROWS - 3 do
        for col = 1, self.COLS do
            if self.grid[row][col] == player and
               self.grid[row + 1][col] == player and
               self.grid[row + 2][col] == player and
               self.grid[row + 3][col] == player then
                return true, string.format("Vertical win at column %d, starting at row %d", col, row)
            end
        end
    end

    -- Check diagonal (positive slope)
    for row = 1, self.ROWS - 3 do
        for col = 1, self.COLS - 3 do
            if self.grid[row][col] == player and
               self.grid[row + 1][col + 1] == player and
               self.grid[row + 2][col + 2] == player and
               self.grid[row + 3][col + 3] == player then
                return true, string.format("Diagonal win (positive slope) starting at row %d, column %d", row, col)
            end
        end
    end

    -- Check diagonal (negative slope)
    for row = 1, self.ROWS - 3 do
        for col = 4, self.COLS do
            if self.grid[row][col] == player and
               self.grid[row + 1][col - 1] == player and
               self.grid[row + 2][col - 2] == player and
               self.grid[row + 3][col - 3] == player then
                return true, string.format("Diagonal win (negative slope) starting at row %d, column %d", row, col)
            end
        end
    end

    return false, nil
end

function Board:isFull()
    for col = 1, self.COLS do
        if self:isValidMove(col) then
            return false
        end
    end
    return true
end

function Board:print()
    print("\n Current Board State:")

    io.write("  ")
    for col = 1, self.COLS do
        io.write(col .. " ")
    end
    print("\n")
    
    for row = 1, self.ROWS do
        io.write(row .. " ")
        for col = 1, self.COLS do
            local cell = self.grid[row][col]
            if cell == self.EMPTY then
                io.write("· ")
            elseif cell == self.PLAYER1 then
                io.write("X ")
            else
                io.write("● ")
            end
        end
        print()
    end
    print()
end

return Board

-- function demonstrateGameLogic()
--     print("\n=== Connect-4 Game Logic Demonstration ===")
--     local board = Board:new()
    
--     print("\nScenario 1: Demonstrating Horizontal Win")
--     print("Making moves: Player 1 (X) in columns 1,2,3,4")
--     board:makeMove(1, Board.PLAYER1)
--     board:makeMove(2, Board.PLAYER1)
--     board:makeMove(3, Board.PLAYER1)
--     board:makeMove(4, Board.PLAYER1)
--     board:print()
--     local won, desc = board:checkWin(Board.PLAYER1)
--     if won then
--         print("Win detected: " .. desc)
--     end
    
--     print("\nScenario 2: Demonstrating Vertical Win")
--     board = Board:new()
--     print("Making moves: Player 2 (●) in column 3, rows 1-4")
--     board:makeMove(3, Board.PLAYER2)
--     board:makeMove(3, Board.PLAYER2)
--     board:makeMove(3, Board.PLAYER2)
--     board:makeMove(3, Board.PLAYER2)
--     board:print()
--     won, desc = board:checkWin(Board.PLAYER2)
--     if won then
--         print("Win detected: " .. desc)
--     end
    
--     print("\nScenario 3: Demonstrating Diagonal Win")
--     board = Board:new()
--     print("Setting up diagonal pattern for Player 1")
--     board:makeMove(1, Board.PLAYER1)
--     board:makeMove(2, Board.PLAYER2)
--     board:makeMove(2, Board.PLAYER1)
--     board:makeMove(3, Board.PLAYER2)
--     board:makeMove(3, Board.PLAYER2)
--     board:makeMove(3, Board.PLAYER1)
--     board:makeMove(4, Board.PLAYER2)
--     board:makeMove(4, Board.PLAYER2)
--     board:makeMove(4, Board.PLAYER2)
--     board:makeMove(4, Board.PLAYER1)
--     board:print()
--     won, desc = board:checkWin(Board.PLAYER1)
--     if won then
--         print("Win detected: " .. desc)
--     end

--     print("\nScenario 4: Demonstrating Invalid Move Detection")
--     board = Board:new()

--     for i = 1, 6 do
--         board:makeMove(1, Board.PLAYER1)
--     end
--     board:print()
--     print("Attempting to place in full column 1:")
--     if not board:makeMove(1, Board.PLAYER2) then
--         print("Invalid move detected: Column is full")
--     end
    
--     print("\nScenario 5: Demonstrating Draw Detection")
--     board = Board:new()
    
--     local pattern = {
--         {1,2,1,2,1,2,1},
--         {2,1,2,1,2,1,2},
--         {1,2,1,2,1,2,1},
--         {2,1,2,1,2,1,2},
--         {1,2,1,2,1,2,1},
--         {2,1,2,1,2,1,2}
--     }
--     print("Filling board with a pattern that leads to a draw")
--     for row = 1, #pattern do
--         for col = 1, #pattern[row] do
--             board.grid[row][col] = pattern[row][col]
--         end
--     end
--     board:print()
--     if board:isFull() then
--         print("Draw detected: Board is full with no winner")
--     end
-- end


-- demonstrateGameLogic()
