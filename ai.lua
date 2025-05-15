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


function minimaxWithAlphabeta(node, depth, alpha, beta, isMax)
    if #node.children == 0 then
        return node.value
    end
    
    if isMax then
        local value = -math.huge
        for _, child in ipairs(node.children) do
            value = math.max(value, minimaxWithAlphabeta(child, depth + 1, alpha, beta, false))
            alpha = math.max(alpha, value)
            if beta <= alpha then
                break -- Beta cutoff
            end
        end
        return value
    else
        local value = math.huge
        for _, child in ipairs(node.children) do
            value = math.min(value, minimaxWithAlphabeta(child, depth + 1, alpha, beta, true))
            beta = math.min(beta, value)
            if beta <= alpha then
                break -- Alpha cutoff
            end
        end
        return value
    end
end


function heuristic(board)
    local aiPlayer = 2  -- Assuming AI is player 2
    local humanPlayer = 1  -- Assuming human is player 1
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


function main()
    
    local leaf1 = TreeNode:new(3)
    local leaf2 = TreeNode:new(5)
    local leaf3 = TreeNode:new(2)
    local leaf4 = TreeNode:new(9)
    local leaf5 = TreeNode:new(12)
    local leaf6 = TreeNode:new(5)
    local leaf7 = TreeNode:new(23)
    local leaf8 = TreeNode:new(23)
    
    local node1 = TreeNode:new(nil, {leaf1, leaf2})
    local node2 = TreeNode:new(nil, {leaf3, leaf4})
    local node3 = TreeNode:new(nil, {leaf5, leaf6, leaf7}) 
    local node4 = TreeNode:new(nil, {leaf8})               
    
    local node5 = TreeNode:new(nil, {node1, node2})
    local node6 = TreeNode:new(nil, {node3, node4})
    
    local root = TreeNode:new(nil, {node5, node6})
    
    local result = minimaxWithAlphabeta(root, 0, -math.huge, math.huge, true)
    print("Optimal value: " .. result);
end

main()
