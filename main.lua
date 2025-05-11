
function minimax(depth, nodeIndex, isMax, scores, h)
    if (depth == h) then
        return scores[nodeIndex + 1]  
    end
    
    if (isMax) then
        return math.max(
            minimax(depth + 1, nodeIndex * 2, false, scores, h),
            minimax(depth + 1, nodeIndex * 2 + 1, false, scores, h)
        )
    
    else
        return math.min(
            minimax(depth + 1, nodeIndex * 2, true, scores, h),
            minimax(depth + 1, nodeIndex * 2 + 1, true, scores, h)
        )
    end
end

function log2(n)
    return (n == 1) and 0 or (1 + log2(math.floor(n / 2)))
end

function main()
    local scores = {3, 5, 2, 9, 12, 5, 23, 23}
    local n = #scores
    local h = log2(n)
    local res = minimax(0, 0, true, scores, h)
    print("The optimal value is : " .. res)
end

main()
