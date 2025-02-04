local spawnPointsReader = {}

function spawnPointsReader.readAll()
    local spawnpoints = {}
    for _, directory in ipairs(getMapDirectoryTable()) do
		print(directory)
        local filename = "media/maps/" .. directory .. "/spawnpoints.lua"

        if fileExists(filename) then 
            SpawnPoints = nil
            reloadLuaFile(filename)
            local spawnPointTable = SpawnPoints()
            
            for _, points in pairs(spawnPointTable) do
                for _, spawnPointData in pairs(points) do
                    table.insert(spawnpoints, spawnPointData)
                    --print("worldX " .. tostring(spawnpoints.worldX))
                    --print("worldY " .. tostring(spawnpoints.worldY))
                    --print("posX " .. tostring(spawnpoints.posX))
                    --print("posY " .. tostring(spawnpoints.posY))
                    --print("posZ " .. tostring(spawnpoints.posX))
                end
            end
        end
	end
    return spawnpoints
end

return spawnPointsReader