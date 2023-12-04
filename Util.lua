local function lookupify(src, list)
    list = list or {}
    local srcType = type(src)
    if srcType == 'string' then
        local len = src:len() 
        for i = 1, len do 
            list[src:sub(i, i)] = true
        end
    elseif srcType == 'table' then
        local len = #src 
        for i = 1, len do
            list[src[i]] = true
        end
    end

    return list
end

return {
	lookupify = lookupify
}