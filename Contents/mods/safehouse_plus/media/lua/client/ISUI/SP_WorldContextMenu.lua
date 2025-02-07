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
        local tooltip = ISWorldObjectContextMenu.addToolTip()
        -- tooltip:setName(getText("ContextMenu_SafehouseClaim"))
        tooltip.description = "<RGB:1,0,0> " .. getText("Tooltip_SafehousePlus_ContextMenu_Warning")
        tooltip:setName(getText("Tooltip_SafehousePlus_ContextMenu_WarningName"))
        option.toolTip = tooltip
        option.notAvailable = true
    end
end

Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)