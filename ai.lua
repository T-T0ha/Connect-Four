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

function minimax(node, depth, isMax)
    if #node.children == 0 then
        return node.value
    end
    
    if isMax then
        local bestValue = -math.huge
        for _, child in ipairs(node.children) do
            local value = minimax(child, depth + 1, false)
            bestValue = math.max(bestValue, value)
        end
        return bestValue
    else
        local bestValue = math.huge
        for _, child in ipairs(node.children) do
            local value = minimax(child, depth + 1, true)
            bestValue = math.min(bestValue, value)
        end
        return bestValue
    end
end

function alphabeta(node, depth, alpha, beta, isMax)
    if #node.children == 0 then
        return node.value
    end
    
    if isMax then
        local value = -math.huge
        for _, child in ipairs(node.children) do
            value = math.max(value, alphabeta(child, depth + 1, alpha, beta, false))
            alpha = math.max(alpha, value)
            if beta <= alpha then
                break -- Beta cutoff
            end
        end
        return value
    else
        local value = math.huge
        for _, child in ipairs(node.children) do
            value = math.min(value, alphabeta(child, depth + 1, alpha, beta, true))
            beta = math.min(beta, value)
            if beta <= alpha then
                break -- Alpha cutoff
            end
        end
        return value
    end
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
    
    local result = minimax(root, 0, true)
    print("The optimal value is : " .. result)
    print(alphabeta(root, 0, -math.huge, math.huge, true));
end

main()
