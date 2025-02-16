local function onJoypadOpenUserPanelUI(target, playerNum)
    local x = (playerNum % 2) + 1
    local y = math.floor(playerNum / 2) + 1
    local userPanel = ISUserPanelUI:new(-x, -y, 1, 1, getSpecificPlayer(playerNum))
    userPanel:initialise()
    userPanel:addToUIManager()
    userPanel:bringToTop()
end

local function OnFillWorldObjectContextMenu(playerNum, context, worldObjects, test)
    local joypad = JoypadState.joypads[playerNum + 1]
    if joypad and joypad.player == playerNum then
        local userPanelContextMenu = context:addOptionOnTop("Menu Cliente", context, onJoypadOpenUserPanelUI, playerNum)
    end

    local option = context:getOptionFromName(getText("ContextMenu_SafehouseClaim"))
    if option then
        option.toolTip = nil
        option.target = nil
        option.param1 = getPlayer()
        option.onSelect = function (target, player)
            local claimUI = ISClaimSafehouseUI:new(player)
            claimUI:initialise()
            claimUI:addToUIManager()
            claimUI:bringToTop()
        end
        option.notAvailable = false
    end
end

Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)