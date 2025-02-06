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
    context:removeOptionByName(getText("ContextMenu_SafehouseClaim"))
end

Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)