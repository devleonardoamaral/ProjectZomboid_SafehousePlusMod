UIUtils = require("ISUI/SP_UIUtils")

ISSafehouseUI = ISPanel:derive("ISSafehouseUI")
ISSafehouseUI.instances = {}

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

function ISSafehouseUI:initialise()
    self.onDrawSafehouseLimits = function ()
        self:drawSafehouseLimits()
    end
    Events.OnTick.Add(self.onDrawSafehouseLimits)
    ISPanel.initialise(self)

    local y = 90
    local width = self:getWidth()

    local btnWid = 200
    local btnHgt = math.max(25, FONT_HGT_SMALL + 6)

    local smallBtnWid = 100
    local smallBtnHgt = FONT_HGT_SMALL + 4

    local padX = self.padX
    local padY = self.padX
    local shortPadY = 5

    local isOwner = self:isOwner()
    local isMember = self:isMember()
    local isAdmin = self:isAdmin()

    if not self.safehouse:getPlayers():contains(self.safehouse:getOwner()) then
        self.safehouse:addPlayer(self.safehouse:getOwner())
        self.safehouse:syncSafehouse()
    end

    local labelHeight = UIUtils.measureFontY(UIFont.Small) + 4

    self.CoordinatesLabel = ISLabel:new(padX + ((width - (padX * 2)) / 4), y, labelHeight, getText("IGUI_ISSafehouseUI_CoordLabel"), 1,1,1,1, UIFont.Small, true)
    self.CoordinatesLabel.center = true
    self.CoordinatesLabel:initialise()
    self.CoordinatesLabel:instantiate()
    self:addChild(self.CoordinatesLabel)

    self.AreaLabel = ISLabel:new(padX + (((width - (padX * 2)) / 4) * 3), y, labelHeight, getText("IGUI_ISSafehouseUI_SizeLabel"), 1,1,1,1, UIFont.Small, true)
    self.AreaLabel.center = true
    self.AreaLabel:initialise()
    self.AreaLabel:instantiate()
    self:addChild(self.AreaLabel)
    y = y + UIUtils.measureFontY(UIFont.Small) + shortPadY

    self.AreaTextLabel = ISLabel:new(padX + (((width - (padX * 2)) / 4) * 3), y, labelHeight, tostring(self.safehouseSize) .. " tiles²", 0.6,0.6,1,1, UIFont.Small, true)
    self.AreaTextLabel.center = true
    self.AreaTextLabel:initialise()
    self.AreaTextLabel:instantiate()
    self:addChild(self.AreaTextLabel)

    self.CoordinatesNorthTextLabel = ISLabel:new(padX + ((width - (padX * 2)) / 4), y, labelHeight, "N:" .. tostring(self.x1) .. "," .. tostring(self.y1), 0.6,0.6,1,1, UIFont.Small, true)
    self.CoordinatesNorthTextLabel.center = true
    self.CoordinatesNorthTextLabel:initialise()
    self.CoordinatesNorthTextLabel:instantiate()
    self:addChild(self.CoordinatesNorthTextLabel)
    y = y + UIUtils.measureFontY(UIFont.Small) + shortPadY

    self.CoordinatesSouthTextLabel = ISLabel:new(padX + ((width - (padX * 2)) / 4), y, labelHeight, "S:" .. tostring(self.x2) .. "," .. tostring(self.y2), 0.6,0.6,1,1, UIFont.Small, true)
    self.CoordinatesSouthTextLabel.center = true
    self.CoordinatesSouthTextLabel:initialise()
    self.CoordinatesSouthTextLabel:instantiate()
    self:addChild(self.CoordinatesSouthTextLabel)
    y = y + UIUtils.measureFontY(UIFont.Small) + padY

    local aY = padY

    self.UpdateButton = ISButton:new(padX, aY, smallBtnWid, smallBtnHgt, getText("IGUI_ISSafehouseUI_ReloadButton"), self, nil, ISSafehouseUI.onOptionMouseDown)
    self.UpdateButton:initialise()
    self.UpdateButton:instantiate()
    self.UpdateButton.internal = "REOPEN"
    self.UpdateButton.borderColor = self.buttonBorderColor
    self:addChild(self.UpdateButton)

    if isAdmin then
        self.TeleportButton = ISButton:new(padX, aY + smallBtnHgt + shortPadY, smallBtnWid, smallBtnHgt, getText("IGUI_ISSafehouseUI_TeleportButton"), self, nil, ISSafehouseUI.onOptionMouseDown)
        self.TeleportButton:initialise()
        self.TeleportButton:instantiate()
        self.TeleportButton.internal = "TELEPORT"
        self.TeleportButton.borderColor = self.buttonBorderColor
        self:addChild(self.TeleportButton)
    end

    if isOwner or isAdmin then
        self.ReleaseSafehouseButton = ISButton:new(width - smallBtnWid - padX, aY, smallBtnWid, smallBtnHgt, getText("IGUI_ISSafehouseUI_ReleaseSafehouseButton"), self, nil, ISSafehouseUI.onOptionMouseDown)
        self.ReleaseSafehouseButton:initialise()
        self.ReleaseSafehouseButton:instantiate()
        self.ReleaseSafehouseButton.internal = "RELEASE"
        self.ReleaseSafehouseButton.backgroundColor = {r=0.3, g=0, b=0, a=0.8}
        self.ReleaseSafehouseButton.backgroundColorMouseOver = {r=0.6, g=0, b=0, a=0.8}
        self.ReleaseSafehouseButton.borderColor = self.buttonBorderColor
        self:addChild(self.ReleaseSafehouseButton)
        aY = aY + smallBtnHgt + shortPadY
    end

    if isMember then
        self.ExitSafehouseButton = ISButton:new(width - smallBtnWid - padX, aY, smallBtnWid, smallBtnHgt, getText("IGUI_ISSafehouseUI_ExitSafehouseButton"), self, ISSafehouseUI.onOptionMouseDown)
        self.ExitSafehouseButton:initialise()
        self.ExitSafehouseButton:instantiate()
        self.ExitSafehouseButton.internal = "EXIT"
        self.ExitSafehouseButton.backgroundColor = {r=0.3, g=0, b=0, a=0.8}
        self.ExitSafehouseButton.backgroundColorMouseOver = {r=0.6, g=0, b=0, a=0.8}
        self.ExitSafehouseButton.borderColor = self.buttonBorderColor
        self:addChild(self.ExitSafehouseButton)
    end
    
    self.SafehouseTitleLabel = ISLabel:new(padX, y, labelHeight, getText("IGUI_ISSafehouseUI_NameLabel") .. ":", 1,1,1,1, UIFont.Small, true)
    self.SafehouseTitleLabel:initialise()
    self.SafehouseTitleLabel:instantiate()
    self:addChild(self.SafehouseTitleLabel)

    local SafehouseOwnerLabelHeight = UIUtils.measureFontY(UIFont.Small) + 4
    self.SafehouseOwnerLabel = ISLabel:new(width - padX - btnWid, y, SafehouseOwnerLabelHeight, getText("IGUI_ISSafehouseUI_OwnerLabel") .. ":", 1,1,1,1, UIFont.Small, true)
    self.SafehouseOwnerLabel:initialise()
    self.SafehouseOwnerLabel:instantiate()
    self:addChild(self.SafehouseOwnerLabel)
    y = y + SafehouseOwnerLabelHeight

    local titleText = self.safehouse:getTitle()
    self.SafehouseTitleEntry = ISTextEntryBox:new(titleText, padX, y, btnWid, btnHgt)
    self.SafehouseTitleEntry:initialise()
    self.SafehouseTitleEntry:instantiate()
    self.SafehouseTitleEntry.minLength = 3
    self.SafehouseTitleEntry.maxLength = 30
    self.SafehouseTitleEntry.isValid = false
    self.SafehouseTitleEntry.onTextChange = ISSafehouseUI.onSafehouseTitleEntryTextChange
    self.SafehouseTitleEntry.onCommandEntered = ISSafehouseUI.onSafehouseTitleEntryCommand
    self.SafehouseTitleEntry.target = self
    if not isOwner and not isAdmin then self.SafehouseTitleEntry:setEditable(false) end
    self:addChild(self.SafehouseTitleEntry)

    local ownerText = self.safehouse:getOwner()
    self.SafehouseOwnerEntry = ISTextEntryBox:new(ownerText, width - padX - btnWid, y, btnWid, btnHgt)
    self.SafehouseOwnerEntry:initialise()
    self.SafehouseOwnerEntry:instantiate()
    self.SafehouseOwnerEntry.isValid = false
    self.SafehouseOwnerEntry.onTextChange = ISSafehouseUI.onSafehouseOwnerEntryTextChange
    self.SafehouseOwnerEntry.onCommandEntered = ISSafehouseUI.onSafehouseOwnerEntryCommand
    self.SafehouseOwnerEntry.target = self
    if not isOwner and not isAdmin then self.SafehouseOwnerEntry:setEditable(false) end
    self:addChild(self.SafehouseOwnerEntry)
    y = y + btnHgt + padY

    local MembersScrollableListLabelHeight = UIUtils.measureFontY(UIFont.Small) + 4
    self.MembersScrollableListLabel = ISLabel:new(padX, y, MembersScrollableListLabelHeight, getText("IGUI_ISSafehouseUI_MembersScrollListLabel") .. ":", 1,1,1,1, UIFont.Small, true)
    self.MembersScrollableListLabel:initialise()
    self.MembersScrollableListLabel:instantiate()
    self:addChild(self.MembersScrollableListLabel)

    local SafehouseMembersLabelHeight = UIUtils.measureFontY(UIFont.Small) + 4
    local memberLimit = SandboxVars.SafehousePlus.MemberLimit <= 0 and getText("IGUI_ISSafehouseUI_SafehouseMembersUnlimitedLabel") or tostring(SandboxVars.SafehousePlus.MemberLimit)
    local SafehouseMembersLabelText = getText("IGUI_ISSafehouseUI_SafehouseMembersLabel") .. " (" .. tostring(self:numOfMembers()) .. " / " .. memberLimit .. ")"
    self.SafehouseMembersLabel = ISLabel:new(width - UIUtils.measureTextX(UIFont.Small, SafehouseMembersLabelText) - padX, y, SafehouseMembersLabelHeight, SafehouseMembersLabelText, 1,1,1,1, UIFont.Small, true)
    self.SafehouseMembersLabel:initialise()
    self.SafehouseMembersLabel:instantiate()
    self:addChild(self.SafehouseMembersLabel)
    y = y + SafehouseMembersLabelHeight

    local MemberScrollableListBoxWidth = self.width - (padX * 2)
    local MemberScrollableListBoxHeight = 200
    self.MemberScrollableListBox = ISScrollingListBox:new(UIUtils.centerWidget(MemberScrollableListBoxWidth, self.width), y, MemberScrollableListBoxWidth, MemberScrollableListBoxHeight)
    self.MemberScrollableListBox:initialise()
    self.MemberScrollableListBox:instantiate()
    self.MemberScrollableListBox:setFont(UIFont.Small, 4)
    self.MemberScrollableListBox.selected = 0
    self.MemberScrollableListBox.joypadParent = self
    self.MemberScrollableListBox.doDrawItem = ISSafehouseUI.doMemberScrollableListBoxDrawItem
    self.MemberScrollableListBox.drawBorder = true
    self.MemberScrollableListBox.onMouseDown = ISSafehouseUI.onMemberScrollableListBoxMouseDown
    self.MemberScrollableListBox.target = self
    self:addChild(self.MemberScrollableListBox)
    y = y + MemberScrollableListBoxHeight + shortPadY

    if self:isOwner() or self:isAdmin() then
        local btnMngWid = (width - (2 * padX) - (2 * shortPadY)) / 3

        local AddMemberEntryText = ""
        self.AddMemberEntry = ISTextEntryBox:new(AddMemberEntryText, padX, y, btnMngWid, btnHgt)
        self.AddMemberEntry:initialise()
        self.AddMemberEntry:instantiate()
        self.AddMemberEntry.isValid = false
        self.AddMemberEntry.onTextChange = ISSafehouseUI.onAddMemberEntryBoxTextChange
        self.AddMemberEntry.target = self
        if not isOwner and not isAdmin then self.AddMemberEntry:setEditable(false) end
        self:addChild(self.AddMemberEntry)

        self.AddMemberButton = ISButton:new(padX + btnMngWid + shortPadY, y, btnMngWid, btnHgt, getText("IGUI_ISSafehouseUI_AddMemberButton"), self, ISSafehouseUI.onOptionMouseDown)
        self.AddMemberButton:initialise()
        self.AddMemberButton:instantiate()
        self.AddMemberButton.internal = "ADDMEMBER"
        self.AddMemberButton.borderColor = self.buttonBorderColor
        self.AddMemberButton.enable = false
        self:addChild(self.AddMemberButton)

        self.RemoveMemberButton = ISButton:new(padX + (btnMngWid * 2) + (shortPadY * 2), y, btnMngWid, btnHgt, getText("IGUI_ISSafehouseUI_RemoveMemberButton"), self, ISSafehouseUI.onOptionMouseDown)
        self.RemoveMemberButton:initialise()
        self.RemoveMemberButton:instantiate()
        self.RemoveMemberButton.internal = "REMOVEMEMBER"
        self.RemoveMemberButton.backgroundColor = {r=0.3, g=0, b=0, a=0.8}
        self.RemoveMemberButton.backgroundColorMouseOver = {r=0.6, g=0, b=0, a=0.8}
        self.RemoveMemberButton.borderColor = self.buttonBorderColor

        self:addChild(self.RemoveMemberButton)
    end

    y = y + btnHgt + padY

    local ShowSafehouseLimitsTickBoxText = getText("IGUI_SafehouseUI_SafehouseLimits")
    local ShowSafehouseLimitsTickBoxWidth = UIUtils.measureTextX(UIFont.Small, ShowSafehouseLimitsTickBoxText)
    self.ShowSafehouseLimitsTickBox = ISTickBox:new(padX, y, ShowSafehouseLimitsTickBoxWidth, 18, "", self, ISSafehouseUI.onClickShowSafehouseLimits);
    self.ShowSafehouseLimitsTickBox:initialise()
    self.ShowSafehouseLimitsTickBox:instantiate()
    self.ShowSafehouseLimitsTickBox.selected[1] = self.highlightLimits
    self.ShowSafehouseLimitsTickBox:addOption(ShowSafehouseLimitsTickBoxText)
    self:addChild(self.ShowSafehouseLimitsTickBox)

    y = y + 18 + shortPadY

    local RespawnOnSafehouseTickBoxText = getText("IGUI_SafehouseUI_Respawn")
    local RespawnOnSafehouseTickBoxWidth = UIUtils.measureTextX(UIFont.Small, RespawnOnSafehouseTickBoxText)
    self.RespawnOnSafehouseTickBox = ISTickBox:new(padX, y, RespawnOnSafehouseTickBoxWidth, 18, "", self, ISSafehouseUI.onClickRespawn)
    self.RespawnOnSafehouseTickBox:initialise()
    self.RespawnOnSafehouseTickBox:instantiate()
    self.RespawnOnSafehouseTickBox.selected[1] = self.safehouse:isRespawnInSafehouse(self.player:getUsername())
    self.RespawnOnSafehouseTickBox:addOption(RespawnOnSafehouseTickBoxText)
    self:addChild(self.RespawnOnSafehouseTickBox)
    self.RespawnOnSafehouseTickBox.enable = false

    if getServerOptions():getBoolean("SafehouseAllowRespawn") and self:isMemberOrOwner() then
        self.RespawnOnSafehouseTickBox.enable = true
    end

    self.CancelButton = ISButton:new(width - btnWid - padX, y, btnWid, btnHgt, getText("UI_btn_close"), self, ISSafehouseUI.onOptionMouseDown)
    self.CancelButton:initialise()
    self.CancelButton:instantiate()
    self.CancelButton.internal = "CANCEL"
    self.CancelButton.backgroundColor = {r=0.3, g=0, b=0, a=0.8}
    self.CancelButton.backgroundColorMouseOver = {r=0.6, g=0, b=0, a=0.8}
    self.CancelButton.borderColor = self.buttonBorderColor
    self:addChild(self.CancelButton)
    y = y + btnHgt + 20

    self:setHeight(y)
    self.height = y

    self:updateScrollableMemberList()
    self:updateRemoveMemberButton()
end

function ISSafehouseUI:isAdmin()
    return self.player:isAccessLevel("admin")
end

function ISSafehouseUI:isOwner(playerName)
    playerName = playerName ~= nil and playerName or self.player:getUsername()
    return self.safehouse:getOwner() == playerName
end

function ISSafehouseUI:isMember(playerName)
    playerName = playerName ~= nil and playerName or self.player:getUsername()
    return self.safehouse:getPlayers():contains(playerName) and not self:isOwner()
end

-- Pode apresentar inconsistências antes da execução do ISSafehouseUI:updateScrollableMemberList.
function ISSafehouseUI:isMemberOrOwner(playerName)
    playerName = playerName ~= nil and playerName or self.player:getUsername()
    return self.safehouse:getPlayers():contains(playerName)
end

-- Pode apresentar inconsistências antes da execução do ISSafehouseUI:updateScrollableMemberList.
function ISSafehouseUI:isMemberOfASafehouse(playerName)
    local safehouses = SafeHouse.getSafehouseList()

    for i = 0, safehouses:size() - 1 do
        local safehouse = safehouses:get(i)

        if safehouse:getOwner() == playerName then
            return true
        end

        local players = safehouse:getPlayers()

        for j = 0, players:size() - 1 do
            if players:get(j) == playerName then
                return true
            end
        end
    end

    return false
end

function ISSafehouseUI:numOfMembers()
    return self.safehouse:getPlayers():size()
end

-- Retorna o nome do membro selecionado na lista.
function ISSafehouseUI:getSelectedMemberFromScrollableList()
    -- Obtém o índice da linha selecionada na lista
    local selectedRow = self.MemberScrollableListBox.selected

    -- Verifica se o índice selecionado é válido
    if not selectedRow or selectedRow < 1 or selectedRow > #self.MemberScrollableListBox.items then
        self.MemberScrollableListBox.selected = nil -- Reseta a seleção se for inválida
        return nil
    end

    -- Retorna o item correspondente à linha selecionada
    local selectedItem = self.MemberScrollableListBox.items[selectedRow].item
    return selectedItem
end

function ISSafehouseUI:removeMember(playerName)
    if not getServerOptions():getBoolean("SafehouseAllowTrepass") then
        local players = getOnlinePlayers()
        for i=0, players:size() - 1 do
            local player = players:get(i)

            if player:getUsername() == playerName then
                if player:getX() >= self.safehouse:getX() - 1 and player:getX() < self.safehouse:getX2() + 1 and player:getY() >= self.safehouse:getY() - 1 and player:getY() < self.safehouse:getY2() + 1 then
                    self.safehouse:kickOutOfSafehouse(player)
                    break
                end
            end
        end
    end
    self.safehouse:removePlayer(playerName)
    self:updateScrollableMemberList()
end

function ISSafehouseUI:updateMemberLimitLabel()
    if not self.SafehouseMembersLabel then return end

    local x = self.SafehouseMembersLabel:getX()
    local y = self.SafehouseMembersLabel:getY()

    local memberLimit = SandboxVars.SafehousePlus.MemberLimit <= 0 and getText("IGUI_ISSafehouseUI_SafehouseMembersUnlimitedLabel") or tostring(SandboxVars.SafehousePlus.MemberLimit)
    local SafehouseMembersLabelText = getText("IGUI_ISSafehouseUI_SafehouseMembersLabel") .. " (" .. tostring(self:numOfMembers()) .. " / " .. memberLimit .. ")"
    self.SafehouseMembersLabel:setName(SafehouseMembersLabelText)
    self.SafehouseMembersLabel.x = self:getWidth() - UIUtils.measureTextX(UIFont.Small, SafehouseMembersLabelText) - self.padX
end

function ISSafehouseUI:updateRemoveMemberButton()
    if not self.RemoveMemberButton then
        return
    end

    local isOwner = self:isOwner()
    local isAdmin = self:isAdmin()
    local selectedMember = self:getSelectedMemberFromScrollableList()

    if (isOwner or isAdmin) and selectedMember ~= nil and selectedMember then
        self.RemoveMemberButton.enable = not self:isOwner(selectedMember)
    else
        self.RemoveMemberButton.enable = false
    end
end

function ISSafehouseUI:updateButtons()
    local isOwner = self:isOwner()
    local isMember = self:isMember()
    local isAdmin = self:isAdmin()

    self:updateRemoveMemberButton()

    if isOwner or isAdmin then
        if self.ReleaseSafehouseButton then
            self.ReleaseSafehouseButton.enable = true
        end

        if self.SafehouseOwnerEntry then
            self.SafehouseOwnerEntry:setEditable(true)
        end

        if self.SafehouseTitleEntry then
            self.SafehouseTitleEntry:setEditable(true)
        end

        if self.AddMemberEntry then
            self.AddMemberEntry:setEditable(true)
        end
    else
        if self.SafehouseOwnerEntry then
            self.SafehouseOwnerEntry:setEditable(false)
        end

        if self.SafehouseTitleEntry then
            self.SafehouseTitleEntry:setEditable(false)
        end

        if self.AddMemberEntry then
            self.AddMemberEntry:setEditable(false)
        end

        if self.ReleaseSafehouseButton then
            self.ReleaseSafehouseButton.enable = false
        end

        if self.AddMemberButton then
            self.AddMemberButton.enable = false
        end
    end

    if isMember then
        if self.ExitSafehouseButton then
            self.ExitSafehouseButton.enable = true
        end
    else
        if self.ExitSafehouseButton then
            self.ExitSafehouseButton.enable = false
        end
    end
end

function ISSafehouseUI:onClickRespawn(clickedOption, enabled)
    self.safehouse:setRespawnInSafehouse(enabled, self.player:getUsername())
end

function ISSafehouseUI:onClickShowSafehouseLimits(clickedOption, enabled)
    self.highlightLimits = enabled
end

function ISSafehouseUI:updateAll()
    self:updateScrollableMemberList()
    self:updateButtons()

    local safehouseName = self.safehouse:getTitle()
    local safehouseOwner = self.safehouse:getOwner()

    self.SafehouseTitleEntry:setText(safehouseName)
    self.SafehouseOwnerEntry:setText(safehouseOwner)
end

function ISSafehouseUI.OnSafehousesChanged()
    for i, safeWindow in pairs(ISSafehouseUI.instances) do
        local safehouse = safeWindow.safehouse

        if not SafeHouse.getSafehouseList():contains(safehouse) then
            safeWindow:close()
        else
            safeWindow:updateScrollableMemberList()
            safeWindow:updateButtons()
        end
    end
end

function ISSafehouseUI:updateScrollableMemberList()
    self.MemberScrollableListBox:clear()
    local safehousePlayers = self.safehouse:getPlayers()
    local owner = self.safehouse:getOwner()
    local selected = self.MemberScrollableListBox.selected

    if not safehousePlayers:contains(owner) then
        self.safehouse:addPlayer(owner)
    end

    for i=0, safehousePlayers:size() - 1 do
        local playerName = safehousePlayers:get(i)
        self.MemberScrollableListBox:addItem(playerName, playerName)
    end

    if selected > #self.MemberScrollableListBox.items then
        self.MemberScrollableListBox.selected = math.min(#self.MemberScrollableListBox.items, 1)
    end

    
    self:updateMemberLimitLabel()
end

function ISSafehouseUI:onMemberScrollableListBoxMouseDown(x, y)
	if #self.items == 0 then return end
    
	local row = self:rowAt(x, y)
    
	if row > #self.items then
		row = nil
    elseif row < 1 then
		row = nil
	end
	
    if row ~= nil then
        getSoundManager():playUISound("UISelectListItem")
        self.selected = row
        self.target:updateRemoveMemberButton()
        if self.onmousedown then
            self.onmousedown(self.target, self.items[self.selected].item);
        end
    end
end

function ISSafehouseUI:doMemberScrollableListBoxDrawItem(y, item, alt)
	if not item.height then item.height = self.itemheight end
    local padX = 15

    if self.selected == item.index then
        self:drawRect(0, y, self:getWidth(), item.height-1, 0.3, 0.7, 0.35, 0.15)
    end

    if self.target.safehouse:getOwner() == item.item then
        local text = getText("IGUI_ISSafehouseUI_ItemOwnerTag")
        local textWidth = UIUtils.measureTextX(self.font, text)
        self:drawText(text, self:getWidth() - padX - textWidth, y + self.itemPadY, 0.9, 0.0, 0.0, 0.9, self.font)
    else
        local text = getText("IGUI_ISSafehouseUI_ItemMemberTag")
        local textWidth = UIUtils.measureTextX(self.font, text)
        self:drawText(text, self:getWidth() - padX - textWidth, y + self.itemPadY, 0.0, 0.9, 0.0, 0.9, self.font)
    end

	self:drawRectBorder(0, y, self:getWidth(), item.height, 0.5, self.borderColor.r, self.borderColor.g, self.borderColor.b)
	self:drawText(item.text, padX, y + self.itemPadY, 0.9, 0.9, 0.9, 0.9, self.font)
	y = y + item.height

	return y
end

function ISSafehouseUI:onAddMemberEntryBoxTextChange()
    if not self.target.AddMemberButton then return end
    
    local newMember = self:getInternalText():match("^%s*(.-)%s*$") -- Remove espaços extras
    local canAddMember = false
    local setValidColor = false
    local tooltip = nil

    local isAdmin = self.target:isAdmin()
    
    local isEmptyName = #newMember == 0
    local isMemberOrOwner = self.target:isMemberOrOwner(newMember)
    
    local memberLimit = SandboxVars.SafehousePlus.MemberLimit
    local hasMemberLimit = SandboxVars.SafehousePlus.MemberLimit > 0
    local numOfMembers = self.target:numOfMembers()
    local reachedLimit = hasMemberLimit and numOfMembers >= memberLimit and not isAdmin

    local isMultipleSafehouse = SandboxVars.SafehousePlus.MultipleSafehouse
    local isMemberOfASafehouse = self.target:isMemberOfASafehouse(newMember) and not isAdmin

    if reachedLimit then
        tooltip = getText("Tooltip_SafehousePlus_AddMemberEntry_ReachedLimit")
    elseif isEmptyName then
        tooltip = getText("Tooltip_SafehousePlus_AddMemberEntry_WrongEntry")
        setValidColor = true
    elseif isMemberOrOwner then
        tooltip = getText("Tooltip_SafehousePlus_AddMemberEntry_AlreadyIsMember", newMember)
    elseif not isMultipleSafehouse and isMemberOfASafehouse then
        tooltip = getText("Tooltip_SafehousePlus_AddMemberEntry_AlreadyInASafehouse", newMember)
    else
        canAddMember = true
        setValidColor = true
    end

    self.tooltip = tooltip
    self.isValid = canAddMember
    self:setValid(setValidColor)
    self.target.AddMemberButton.enable = canAddMember
end

function ISSafehouseUI:onSafehouseTitleEntryTextChange()
    local newName = self:getInternalText()

    if self.target.safehouse:getTitle() == newName then
        self.isValid = false
        self:setValid(true)
        return
    end

    if #newName > self.minLength and #newName <= self.maxLength and (self.target:isOwner() or self.target:isAdmin()) then
        self.isValid = true
        self:setValid(true)
    else
        self.isValid = false
        self:setValid(false)
    end
end

function ISSafehouseUI:onSafehouseTitleEntryCommand()
    local newName = self:getInternalText()
    
    if self.isValid then
        self.target.safehouse:setTitle(newName)
        self.target.safehouse:syncSafehouse()
        self:setValid(true)
        self.isValid = false

        local modalWidth = 350
        local modalHeight = 100
        local modalX = self.target:getAbsoluteX() + ((self.target:getWidth() - modalWidth) / 2)
        local modalY = self.target:getAbsoluteY() + (((self.target:getHeight() / 2) - modalHeight) / 2)
        local modal = ISModalDialog:new(modalX, modalY, modalWidth, modalHeight, getText("IGUI_ISSafehouseUI_Dialog_SafehouseNameChange"), false, nil, nil)
        modal:initialise()
        modal:addToUIManager()
    else
        self:setText(self.target.safehouse:getTitle())
        self:setValid(true)
        self.isValid = false
    end
end

function ISSafehouseUI:onSafehouseOwnerEntryTextChange()
    local oldOwner = self.target.safehouse:getOwner()
    local newOwner = self:getInternalText():match("^%s*(.-)%s*$")
    local isAdmin = self.target:isAdmin()

    local canSetOwner = false
    local setValidColor = false
    local tooltip = nil

    if oldOwner == newOwner or #newOwner == 0 then
        canSetOwner = false
        setValidColor = true
    else
        local isMember = false
        local isOnline = false
        local isOwner = false

        local players = self.target.safehouse:getPlayers()
        for i = 0, players:size() - 1 do
            local player = players:get(i)

            if player == newOwner then
                isMember = true
                break
            end
        end

        players = getOnlinePlayers()
        for i = 0, players:size() - 1 do
            local player = players:get(i)
            if player:getUsername() == newOwner then
                isOnline = true
                break
            end
        end

        local safes = SafeHouse.getSafehouseList()
        for i = 0, safes:size() - 1 do
            local safe = safes:get(i)
            if safe:getOwner() == newOwner then
                isOwner = true
                break
            end
        end

        if not isAdmin then
            if not isMember then
                tooltip = getText("Tooltip_SafehousePlus_setNewOwnerEntry_isMember", newOwner)
            elseif not isOnline then
                tooltip = getText("Tooltip_SafehousePlus_setNewOwnerEntry_isOnline", newOwner)
            elseif isOwner then
                tooltip = getText("Tooltip_SafehousePlus_setNewOwnerEntry_isOwner", newOwner)
            end
        end

        if (isMember and isOnline and not isOwner) or isAdmin then
            canSetOwner = true
            setValidColor = true
        end   
    end

    self.isValid = canSetOwner
    self:setValid(setValidColor)
    self.tooltip = tooltip
end

function ISSafehouseUI:onSafehouseOwnerEntryCommand()
    local newOwner = self:getInternalText():match("^%s*(.-)%s*$")

    if self.isValid then
        self.target.safehouse:setOwner(newOwner)
        self.target.safehouse:syncSafehouse()
        self.target:updateScrollableMemberList()

        local modalWidth = 350
        local modalHeight = 100
        local modalX = self.target:getAbsoluteX() + ((self.target:getWidth() - modalWidth) / 2)
        local modalY = self.target:getAbsoluteY() + (((self.target:getHeight() / 2) - modalHeight) / 2)
        local modal = ISModalDialog:new(modalX, modalY, modalWidth, modalHeight, getText("IGUI_ISSafehouseUI_Dialog_OwnerChange"), false, nil, nil)
        modal:initialise()
        modal:addToUIManager()
    end
end

function ISSafehouseUI:onClickRespawn(clickedOption, enabled)
    self.safehouse:setRespawnInSafehouse(enabled, self.player:getUsername())
end

function ISSafehouseUI:render()
    local z = 20
    local titleFont = UIFont.Medium
    local titleText = getText("IGUI_ISSafehouseUI_Title")

    self:drawText(
        titleText,
        UIUtils.centerTextX(titleFont, titleText, self.width),
        z,
        1,1,1,1,
        titleFont
    )
end


function ISSafehouseUI:drawSafehouseLimits()
    if not self.highlightLimits then return end

    local x1 = self.x1
    local y1 = self.y1
    local x2 = self.x2 - 1
    local y2 = self.y2 - 1

    local r = self.highlightColor.r
    local g = self.highlightColor.g
    local b = self.highlightColor.b
    local a = self.highlightColor.a

    for x = x1, x2 do
        local sq = getCell():getGridSquare(x, y1, 0)
        if sq then
            UIUtils.highlightSquare(sq, r, g, b, a)
        end
    end

    for x = x1, x2 do
        local sq = getCell():getGridSquare(x, y2, 0)
        if sq then
            UIUtils.highlightSquare(sq, r, g, b, a)
        end
    end

    for y = y1 + 1, y2 - 1 do
        local sq = getCell():getGridSquare(x1, y, 0)
        if sq then
            UIUtils.highlightSquare(sq, r, g, b, a)
        end
    end

    for y = y1 + 1, y2 - 1 do
        local sq = getCell():getGridSquare(x2, y, 0)
        if sq then
            UIUtils.highlightSquare(sq, r, g, b, a)
        end
    end
end

function ISSafehouseUI:addMemberButtonAction()
    if not self.AddMemberEntry.isValid then return end

    local newMember = self.AddMemberEntry:getInternalText():match("^%s*(.-)%s*$")
    self.safehouse:addPlayer(newMember)
    self:updateScrollableMemberList()
    self:updateMemberLimitLabel()
    self.safehouse:syncSafehouse()
    self.AddMemberButton.enable = false
    self.AddMemberEntry:setText("")
    self.AddMemberEntry:setValid(true)
end

function ISSafehouseUI:removeMemberButtonAction()
    if not (self:isOwner() or self:isAdmin()) then return end
    local selected = self.MemberScrollableListBox.selected
    if not selected or not self.MemberScrollableListBox.items or #self.MemberScrollableListBox.items < 1 or #self.MemberScrollableListBox.items < selected then
        return
    end
    local memberName = self.MemberScrollableListBox.items[selected].item
    if self:isOwner(memberName) then return end
    self:removeMember(memberName)
    self:updateAll()
    self.safehouse:syncSafehouse()
end

function ISSafehouseUI:releaseButtonAction()
    if self:isOwner() or self:isAdmin() then
        self.safehouse:removeSafeHouse(getPlayerFromUsername(self.safehouse:getOwner()))
        self:close()
    end    
end

function ISSafehouseUI:exitSafehouseButtonAction()
    if self:isOwner() then return end
    self:removeMember(self.player:getUsername())
    ISSafehouseUI.closeAllInstances()
end

function ISSafehouseUI:teleportPlayerToSafehouse()
    self.player:setX(self.x2)
    self.player:setY(self.y2)
    self.player:setZ(0)

    self.player:setLx(self.x2)
    self.player:setLy(self.y2)
    self.player:setLz(0)
end

function ISSafehouseUI:onOptionMouseDown(button, x, y)
    local actions = {
        ADDMEMBER = function() self:addMemberButtonAction() end,
        REMOVEMEMBER = function() self:removeMemberButtonAction() end,
        RELEASE = function() self:releaseButtonAction() end,
        TELEPORT = function() self:teleportPlayerToSafehouse() end,
        REOPEN = function() ISSafehouseUI.updateInstance(self.id) end,
        EXIT = function() self:exitSafehouseButtonAction() end,
        CANCEL = function() self:close() end
    }

    local action = actions[button.internal]
    if action then action() end
end

function ISSafehouseUI:close()
    if self.onDrawSafehouseLimits ~= nil then
        Events.OnTick.Remove(self.onDrawSafehouseLimits)
    end
    self:setVisible(false)
    self:removeFromUIManager()
    ISSafehouseUI.instances[self.id] = nil
end

function ISSafehouseUI.closeAllInstances()
    for i, safeWindow in pairs(ISSafehouseUI.instances) do
        safeWindow:close()
    end
end

function ISSafehouseUI.updateInstance(id)
    local instance = ISSafehouseUI.instances[id]

    local player = instance.player
    local safehouse = instance.safehouse
    local x = instance:getAbsoluteX()
    local y = instance:getAbsoluteY()
    local highlightLimits = instance.highlightLimits

    instance:close()

    local safehouseUI = ISSafehouseUI:new(x, y, 500, 450, safehouse, player)
    safehouseUI.highlightLimits = highlightLimits
    safehouseUI:initialise()
    safehouseUI:addToUIManager()
    safehouseUI:bringToTop()
end

function ISSafehouseUI.updateAllInstances()
    for i, safeWindow in pairs(ISSafehouseUI.instances) do
        ISSafehouseUI.updateInstance(i)
    end
end

function ISSafehouseUI:new(x, y, width, height, safehouse, player)
    local o = {}

    width = 460
    height = 450

    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    if y == 0 then
        o.y = o:getMouseY() - (height / 2)
        o:setY(o.y)
    end

    if x == 0 then
        o.x = o:getMouseX() - (width / 2)
        o:setX(o.x)
    end

    o.player = player
    o.safehouse = safehouse

    o.x1 = o.safehouse:getX()
    o.y1 = o.safehouse:getY()
    o.x2 = o.safehouse:getX2()
    o.y2 = o.safehouse:getY2()

    -- Garantir que x1 < x2 e y1 < y2
    if o.x1 > o.x2 then
        o.x1, o.x2 = o.x2, o.x1
    end
    if o.y1 > o.y2 then
        o.y1, o.y2 = o.y2, o.y1
    end

    o.safehouseSize = (o.x2 - o.x1) * (o.y2 - o.y1) 

    o.width = width
    o.height = height
    o.padX = 20
    o.moveWithMouse = true
    
    o.backgroundColor = {r=0, g=0, b=0, a=0.8}
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5}
    o.highlightColor = {r=0, g=0.8, b=1, a=1}

    o.highlightLimits = false

    o.id = o.safehouse:getId()

    if ISSafehouseUI.instances[o.id] ~= nil then
        ISSafehouseUI.instances[o.id]:close()
    end

    ISSafehouseUI.instances[o.id] = o
    return o
end

Events.OnSafehousesChanged.Add(ISSafehouseUI.OnSafehousesChanged)
Events.OnPlayerDeath.Add(ISSafehouseUI.closeAllInstances)

-- local p = getPlayer(); local sq = p:getCurrentSquare(); local objs = sq:getObjects(); for i = 0, objs:size() - 1 do objs:get(i):setHighlightColor(1,0,0,1);objs:get(i):setHighlighted(true) end
-- local p = getPlayer(); local sq = p:getCurrentSquare(); local s = SafeHouse.getSafeHouse(sq); s:addPlayer("debora"); s:syncSafehouse()
-- reloadLuaFile("/home/leonardoamaral/Zomboid/mods/project_zomboid_safehouse_plus/media/lua/client/ISUI/UserPanel/ISSafehouseUI.lua")
-- SandboxVars.SafehousePlus.MultipleSafehouse
