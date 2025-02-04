local spawnPointsReader = require("SP_SpawnPointsReader")
local SPUtils = require("SP_Utils")

SPSpawnPoints = {}
SPSpawnPointSet = {}
SPSpawnPointSetMask = 1000000

local function OnGameStart()
    SPSpawnPoints = spawnPointsReader.readAll()

    for _, point in pairs(SPSpawnPoints) do
        local gX = point.worldX * 300 + point.posX + 0.5
        local gY = point.worldY * 300 + point.posY + 0.5

        -- Cria um ID único mesclando as duas coordenadas
        SPSpawnPointSet[SPUtils.mergeInt(gX, gY, SPSpawnPointSetMask)] = true
    end
end

Events.OnGameStart.Add(OnGameStart)