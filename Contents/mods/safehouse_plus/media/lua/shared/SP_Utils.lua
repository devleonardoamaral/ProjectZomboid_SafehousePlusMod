local Utils = Utils or {}

function Utils.mergeInt(int1, int2, intMask)
    local int1 = math.floor(int1)
    local int2 = math.floor(int2)
    local mergedInt = (int1 * intMask) + int2
    return mergedInt
end

function Utils.unmergeInt(mergedInt, intMask)
    local int1 = math.floor(mergedInt / intMask)
    local int2 = mergedInt % intMask
    return int1, int2
end

function Utils.splitStringIntoLookupTable(text, separator)
    local result = {}
        
    for item in string.gmatch(text, "[^%" .. separator .. "]+") do
        item = string.gsub(item, "^%s*(.-)%s*$", "%1")
        
        if item ~= "" then
            result[item] = true
        end
    end
    
    return result
end

return Utils