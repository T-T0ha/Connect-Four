TreeNode = {}
function TreeNode:new(value, children)
    local obj = {
        value = value,
        children = children or {}
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end


function minimaxWithAlphabeta(board, depth, alpha, beta, isMax, maximizingPlayer)
    local winningMove, _ = board:checkWin(maximizingPlayer)
    if winningMove then
        return 1000000 - depth
    end
    local losingMove, _ = board:checkWin(3 - maximizingPlayer)
    if losingMove then
        return -1000000 + depth
    end
    if board:isFull() then
        return 0
    end
    if depth == 4 then -- Limit search depth for performance
        return heuristic(board.grid, maximizingPlayer)
    end

    if isMax then
        local value = -math.huge
        for col = 1, board.COLS do
            if board:isValidMove(col) then
                local newBoard = board:copy()
                newBoard:makeMove(col, maximizingPlayer)
                value = math.max(value, minimaxWithAlphabeta(newBoard, depth + 1, alpha, beta, false, maximizingPlayer))
                alpha = math.max(alpha, value)
                if beta <= alpha then
                    break
                end
            end
        end
        return value
    else
        local value = math.huge
        for col = 1, board.COLS do
            if board:isValidMove(col) then
                local newBoard = board:copy()
                newBoard:makeMove(col, 3 - maximizingPlayer)
                value = math.min(value, minimaxWithAlphabeta(newBoard, depth + 1, alpha, beta, true, maximizingPlayer))
                beta = math.min(beta, value)
                if beta <= alpha then
                    break
                end
            end
        end
        return value
    end
end


function heuristic(board,aiPlayer)
    local humanPlayer = 3 - aiPlayer
    local score = 0
    
    -- Check horizontal, vertical, and diagonal possibilities
    -- Score based on potential connect fours
    
    -- Score center column control (strategically valuable)
    local centerCol = math.ceil(#board[1] / 2)
    for row = 1, #board do
        if board[row][centerCol] == aiPlayer then
            score = score + 3
        elseif board[row][centerCol] == humanPlayer then
            score = score - 3
        end
    end
    
    -- Evaluate windows of 4 positions
    for row = 1, #board do
        for col = 1, #board[1] do
            -- Horizontal windows
            if col <= #board[1] - 3 then
                score = score + evaluateWindow({board[row][col], board[row][col+1], board[row][col+2], board[row][col+3]}, aiPlayer, humanPlayer)
            end
            
            -- Vertical windows
            if row <= #board - 3 then
                score = score + evaluateWindow({board[row][col], board[row+1][col], board[row+2][col], board[row+3][col]}, aiPlayer, humanPlayer)
            end
            
            -- Diagonal down-right
            if row <= #board - 3 and col <= #board[1] - 3 then
                score = score + evaluateWindow({board[row][col], board[row+1][col+1], board[row+2][col+2], board[row+3][col+3]}, aiPlayer, humanPlayer)
            end
            
            -- Diagonal up-right
            if row >= 4 and col <= #board[1] - 3 then
                score = score + evaluateWindow({board[row][col], board[row-1][col+1], board[row-2][col+2], board[row-3][col+3]}, aiPlayer, humanPlayer)
            end
        end
    end
    
    return score
end

-- Helper function to evaluate a window of 4 positions
function evaluateWindow(window, aiPlayer, humanPlayer)
    local aiCount = 0
    local humanCount = 0
    local emptyCount = 0
    
    for _, cell in ipairs(window) do
        if cell == aiPlayer then
            aiCount = aiCount + 1
        elseif cell == humanPlayer then
            humanCount = humanCount + 1
        else
            emptyCount = emptyCount + 1
        end
    end
    
    -- Score the window
    if aiCount == 4 then
        return 100  -- AI wins
    elseif aiCount == 3 and emptyCount == 1 then
        return 5    -- AI can potentially win next move
    elseif aiCount == 2 and emptyCount == 2 then
        return 2    -- AI has two in a row
    elseif humanCount == 4 then
        return -100 -- Human wins
    elseif humanCount == 3 and emptyCount == 1 then
        return -10  -- Block human from winning
    elseif humanCount == 2 and emptyCount == 2 then
        return -1   -- Human has two in a row
    end
    
    return 0        -- Neutral window
end

return {
    minimaxWithAlphabeta = minimaxWithAlphabeta,
    heuristic = heuristic
}