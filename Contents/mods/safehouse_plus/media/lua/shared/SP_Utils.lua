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

return Utils