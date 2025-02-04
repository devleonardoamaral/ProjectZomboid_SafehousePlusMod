local function OnFillWorldObjectContextMenu(playerNum, context, worldObjects, test)
    context:removeOptionByName(getText("ContextMenu_SafehouseClaim"))
end

Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)