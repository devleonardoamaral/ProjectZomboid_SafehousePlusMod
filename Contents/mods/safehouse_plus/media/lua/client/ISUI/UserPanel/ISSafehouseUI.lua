local SPUtils = require("SP_Utils")
local UIUtils = require("ISUI/SP_UIUtils")

ISSafehouseUI = ISPanel:derive("ISSafehouseUI")
ISSafehouseUI.instances = {}

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

function ISSafehouseUI:initialise()
    ISPanel.initialise(self)

    self.vipPlayers = SPUtils.splitStringIntoLookupTable(SandboxVars.SafehousePlus.SpecialPlayersList, ";")
    
    -- Verifica se o proprietário não está na lista de membros
    -- O jogo, em algumas ocasiões, remove o proprietário da lista de membros
    if not self.safehouse:getPlayers():contains(self.safehouse:getOwner()) then
        self.safehouse:addPlayer(self.safehouse:getOwner())
        self.safehouse:syncSafehouse()
    end

    local isOwner = self:isOwner()
    local isMember = self:isMember()
    local isAdmin = self:isAdmin()

    local y = 70

    self.padX = 20
    self.padY = 20
    self.shortPadX = self.padX / 2
    self.shortPadY = self.padY / 2

    local memberLimitStr = (
        SandboxVars.SafehousePlus.MemberLimit <= 0 
        and getText("IGUI_ISSafehouseUI_SafehouseMembersUnlimitedLabel") 
        or tostring(SandboxVars.SafehousePlus.MemberLimit)
    )

    self.coordLabelText = getText("IGUI_ISSafehouseUI_CoordLabel") .. ":"
    self.areaLabelText = getText("IGUI_ISSafehouseUI_SizeLabel") .. ":"
    self.areaText = tostring(self.safehouseSize) .. " tiles"
    self.coordNText = "N:" .. tostring(self.x1) .. "," .. tostring(self.y1)
    self.coordSText = "S:" .. tostring(self.x2) .. "," .. tostring(self.y2)
    self.reloadButtonText = getText("IGUI_ISSafehouseUI_ReloadButton")
    self.teleportButtonText = getText("IGUI_ISSafehouseUI_TeleportButton")
    self.releaseSafehouseButtonText = getText("IGUI_ISSafehouseUI_ReleaseSafehouseButton")
    self.exitSafehouseButtonText = getText("IGUI_ISSafehouseUI_ExitSafehouseButton")
    self.safehouseNameEntryLabelText = getText("IGUI_ISSafehouseUI_NameLabel") .. ":"
    self.safehouseNameEntryText = self.safehouse:getTitle()
    self.safehouseOwnerEntryLabelText = getText("IGUI_ISSafehouseUI_OwnerLabel") .. ":"
    self.safehouseOwnerEntryText = self.safehouse:getOwner()
    self.safehouseMemberLimitLabelText = (
        getText("IGUI_ISSafehouseUI_SafehouseMembersLabel") 
        .. " (" .. tostring(self:numOfMembers()) 
        .. " / " .. memberLimitStr .. ")"
    )
    self.addMemberButtonText = getText("IGUI_ISSafehouseUI_AddMemberButton")
    self.removeMemberButtonText = getText("IGUI_ISSafehouseUI_RemoveMemberButton")

    self.memberScrollListLabelText = getText("IGUI_ISSafehouseUI_ScrollListLabel") .. ":"
    self.addMemberLabelText = getText("IGUI_ISSafehouseUI_AddMemberLabel") .. ":"
    self.manageSafehouseLabelText = getText("IGUI_ISSafehouseUI_ManageSafehouseLabel")

    self.safehouseNameEntryTooltipDefaultText = getText("Tooltip_SafehousePlus_setNewSafehouseNameEntry_Default")
    self.safehouseOwnerEntryTooltipDefaultText = getText("Tooltip_SafehousePlus_setNewOwnerEntry_Default")
    self.addMemberEntryTooltipDefaultText = getText("Tooltip_SafehousePlus_AddMemberEntry_Default")
    
    self.showSafehouseTickBoxText = getText("IGUI_SafehouseUI_SafehouseLimits")
    self.respawnSafehouseTickBoxText = getText("IGUI_SafehouseUI_Respawn")

    local tickBoxesWidth = UIUtils.measureTextX(
        UIFont.Small, 
        #self.showSafehouseTickBoxText > #self.respawnSafehouseTickBoxText 
        and self.showSafehouseTickBoxText or self.respawnSafehouseTickBoxText
    ) + 20

    self.cancelButtonText = getText("UI_btn_close")

    self.ownerTagName = getText("IGUI_ISSafehouseUI_ItemOwnerTag")
    self.memberTagName = getText("IGUI_ISSafehouseUI_ItemMemberTag")

    self.maxTagWidth = UIUtils.measureTextX(UIFont.Small, #self.ownerTagName > #self.memberTagName and self.ownerTagName or self.memberTagName)
    self.safehouseNameWidth = UIUtils.measureTextX(UIFont.Small, "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOO")
    self.memberNameWidth = UIUtils.measureTextX(UIFont.Small, "OOOOOOOOOOOOOOOOOOOO")
    self.memberScrollListWidth = (self.padX * 2) + self.memberNameWidth + self.maxTagWidth + self.shortPadX
    self.memberScrollListHeight = 200

    self.minButtonWidth = 200
    self.minSmallButtonWidth = 100
    self.buttonHeight = math.max(25, FONT_HGT_SMALL + 6)
    self.smallButtonHeight = FONT_HGT_SMALL + 6

    self.tickBoxHeight = math.max(16, FONT_HGT_SMALL) + 4
    self.labelHeight = FONT_HGT_SMALL + 4
    self.mediumLabelHeight = FONT_HGT_MEDIUM + 6
    self.largeLabelHeight = FONT_HGT_LARGE + 8

    if self:isOwner() or self:isAdmin() then

    end

    self:setWidth(
        math.max(
            self.memberScrollListWidth,
            (tickBoxesWidth * 2) + self.shortPadX,
            (isOwner or isAdmin) and ((self.safehouseNameWidth * 2) + 4 + self.shortPadX) or 0
        ) + (2 * self.padX)
    )
    
    local usableWidth = self.width - (2 * self.padX)

    self.memberScrollListWidth = usableWidth
    
    local totalWidthForEntries = usableWidth - self.shortPadX
    local safehouseEntryWidth = totalWidthForEntries / 2

    local rightSmallButtonsWidth = math.max(
        UIUtils.measureTextX(UIFont.Small, self.releaseSafehouseButtonText),
        UIUtils.measureTextX(UIFont.Small, self.exitSafehouseButtonText),
        self.minSmallButtonWidth
    ) + 10

    local leftSmallButtonsWidth = math.max(
        UIUtils.measureTextX(UIFont.Small, self.teleportButtonText),
        UIUtils.measureTextX(UIFont.Small, self.reloadButtonText),
        self.minSmallButtonWidth
    ) + 10

    self.safehouseTitleLabel = ISLabel:new(self.width / 2, y, self.largeLabelHeight, self.safehouseNameEntryText, 0.6,0.6,1,1, UIFont.Large, true)
    self.safehouseTitleLabel.center = true
    self.safehouseTitleLabel:initialise()
    self.safehouseTitleLabel:instantiate()
    self:addChild(self.safehouseTitleLabel)
    local y = y + self.largeLabelHeight + self.padY
   
    self.coordLabel = ISLabel:new(self.padX + ((self.width - (self.padX * 2)) / 4) - 2.5, y, self.labelHeight, self.coordLabelText, 1,1,1,1, UIFont.Small, false)
    self.coordLabel:initialise()
    self.coordLabel:instantiate()
    self:addChild(self.coordLabel)

    self.areaLabel = ISLabel:new(self.padX + (((self.width - (self.padX * 2)) / 4) * 3) - 2.5, y, self.labelHeight, self.areaLabelText, 1,1,1,1, UIFont.Small, false)
    self.areaLabel:initialise()
    self.areaLabel:instantiate()
    self:addChild(self.areaLabel)

    self.area = ISLabel:new(self.padX + (((self.width - (self.padX * 2)) / 4) * 3) + 2.5, y, self.labelHeight, self.areaText, 0.6,0.6,1,1, UIFont.Small, true)
    self.area:initialise()
    self.area:instantiate()
    self:addChild(self.area)

    self.coodN = ISLabel:new(self.padX + ((self.width - (self.padX * 2)) / 4) + 2.5, y, self.labelHeight, self.coordNText, 0.6,0.6,1,1, UIFont.Small, true)
    self.coodN:initialise()
    self.coodN:instantiate()
    self:addChild(self.coodN)
    y = y + self.labelHeight

    self.coordS = ISLabel:new(self.padX + ((self.width - (self.padX * 2)) / 4) + 2.5, y, self.labelHeight, self.coordSText, 0.6,0.6,1,1, UIFont.Small, true)
    self.coordS:initialise()
    self.coordS:instantiate()
    self:addChild(self.coordS)
    y = y + self.labelHeight + self.padY

    local aY = self.padY

    self.reloadButton = ISButton:new(self.padX, aY, leftSmallButtonsWidth, self.smallButtonHeight, self.reloadButtonText, self, nil, ISSafehouseUI.onOptionMouseDown)
    self.reloadButton:initialise()
    self.reloadButton:instantiate()
    self.reloadButton.internal = "REOPEN"
    self.reloadButton.borderColor = self.buttonBorderColor
    self:addChild(self.reloadButton)

    if isAdmin then
        self.teleportButton = ISButton:new(self.padX, aY + self.smallButtonHeight + self.shortPadY, leftSmallButtonsWidth, self.smallButtonHeight, self.teleportButtonText, self, nil, ISSafehouseUI.onOptionMouseDown)
        self.teleportButton:initialise()
        self.teleportButton:instantiate()
        self.teleportButton.internal = "TELEPORT"
        self.teleportButton.borderColor = self.buttonBorderColor
        self:addChild(self.teleportButton)
    end

    if isOwner or isAdmin then
        self.releaseSafehouseButton = ISButton:new(self.width - rightSmallButtonsWidth - self.padX, aY, rightSmallButtonsWidth, self.smallButtonHeight, self.releaseSafehouseButtonText, self, nil, ISSafehouseUI.onOptionMouseDown)
        self.releaseSafehouseButton:initialise()
        self.releaseSafehouseButton:instantiate()
        self.releaseSafehouseButton.internal = "RELEASE"
        self.releaseSafehouseButton.backgroundColor = {r=0.3, g=0, b=0, a=0.8}
        self.releaseSafehouseButton.backgroundColorMouseOver = {r=0.6, g=0, b=0, a=0.8}
        self.releaseSafehouseButton.borderColor = self.buttonBorderColor
        self:addChild(self.releaseSafehouseButton)
        aY = aY + self.smallButtonHeight + self.shortPadY
    end

    if isMember then
        self.exitSafehouseButton = ISButton:new(self.width - rightSmallButtonsWidth - self.padX, aY, rightSmallButtonsWidth, self.smallButtonHeight, self.exitSafehouseButtonText, self, nil, ISSafehouseUI.onOptionMouseDown)
        self.exitSafehouseButton:initialise()
        self.exitSafehouseButton:instantiate()
        self.exitSafehouseButton.internal = "EXIT"
        self.exitSafehouseButton.backgroundColor = {r=0.3, g=0, b=0, a=0.8}
        self.exitSafehouseButton.backgroundColorMouseOver = {r=0.6, g=0, b=0, a=0.8}
        self.exitSafehouseButton.borderColor = self.buttonBorderColor
        self:addChild(self.exitSafehouseButton)
    end

    self.memberScrollListLabel = ISLabel:new(self.padX, y, self.labelHeight, self.memberScrollListLabelText, 1,1,1,1, UIFont.Small, true)
    self.memberScrollListLabel:initialise()
    self.memberScrollListLabel:instantiate()
    self:addChild(self.memberScrollListLabel)
    
    self.safehouseMembersLimitLabel = ISLabel:new(self.padX + usableWidth, y, self.labelHeight, self.safehouseMemberLimitLabelText, 1,1,1,1, UIFont.Small, false)
    self.safehouseMembersLimitLabel:initialise()
    self.safehouseMembersLimitLabel:instantiate()
    self:addChild(self.safehouseMembersLimitLabel)
    y = y + self.labelHeight

    self.memberScrollList = ISScrollingListBox:new(self.padX, y, self.memberScrollListWidth, self.memberScrollListHeight)
    self.memberScrollList:initialise()
    self.memberScrollList:instantiate()
    self.memberScrollList:setFont(UIFont.Small, 4)
    self.memberScrollList.selected = 0
    self.memberScrollList.joypadParent = self
    self.memberScrollList.doDrawItem = ISSafehouseUI.doMemberScrollListDrawItem
    self.memberScrollList.drawBorder = true
    self.memberScrollList.onMouseDown = ISSafehouseUI.onMemberScrollListMouseDown
    self:addChild(self.memberScrollList)
    y = y + self.memberScrollListHeight + self.padY

    if isOwner or isAdmin then
        self.manageSafehouseLabel = ISLabel:new(self.width / 2, y, self.labelHeight, self.manageSafehouseLabelText, 1,1,1,1, UIFont.Medium, true)
        self.manageSafehouseLabel.center = true
        self.manageSafehouseLabel:initialise()
        self.manageSafehouseLabel:instantiate()
        self:addChild(self.manageSafehouseLabel)
        y = y + self.mediumLabelHeight

        self.safehouseNameEntryLabel = ISLabel:new(self.padX, y, self.labelHeight, self.safehouseNameEntryLabelText, 1,1,1,1, UIFont.Small, true)
        self.safehouseNameEntryLabel:initialise()
        self.safehouseNameEntryLabel:instantiate()
        self:addChild(self.safehouseNameEntryLabel)

        self.safehouseOwnerEntryLabel = ISLabel:new(self.padX + safehouseEntryWidth + self.shortPadX, y, self.labelHeight, self.safehouseOwnerEntryLabelText, 1,1,1,1, UIFont.Small, true)
        self.safehouseOwnerEntryLabel:initialise()
        self.safehouseOwnerEntryLabel:instantiate()
        self:addChild(self.safehouseOwnerEntryLabel)
        y = y + self.labelHeight

        self.safehouseNameEntry = ISTextEntryBox:new(self.safehouseNameEntryText, self.padX, y, safehouseEntryWidth, self.buttonHeight)
        self.safehouseNameEntry:initialise()
        self.safehouseNameEntry:instantiate()
        self.safehouseNameEntry.minLength = 3
        self.safehouseNameEntry.maxLength = 30
        self.safehouseNameEntry.isValid = false
        self.safehouseNameEntry.onTextChange = ISSafehouseUI.onSafehouseNameEntryTextChange
        self.safehouseNameEntry.onCommandEntered = ISSafehouseUI.onSafehouseNameEntryCommand
        if not isOwner and not isAdmin then self.safehouseNameEntry:setEditable(false) end
        self:addChild(self.safehouseNameEntry)

        self.safehouseOwnerEntry = ISTextEntryBox:new(self.safehouseOwnerEntryText, self.padX + safehouseEntryWidth + self.shortPadX, y, safehouseEntryWidth, self.buttonHeight)
        self.safehouseOwnerEntry:initialise()
        self.safehouseOwnerEntry:instantiate()
        self.safehouseOwnerEntry.isValid = false
        self.safehouseOwnerEntry.onTextChange = ISSafehouseUI.onSafehouseOwnerEntryTextChange
        self.safehouseOwnerEntry.onCommandEntered = ISSafehouseUI.onSafehouseOwnerEntryCommand
        if not isOwner and not isAdmin then self.safehouseOwnerEntry:setEditable(false) end
        self:addChild(self.safehouseOwnerEntry)
        y = y + self.buttonHeight + self.shortPadY

        self.addMemberEntryLabel = ISLabel:new(self.padX, y, self.labelHeight, self.addMemberLabelText, 1,1,1,1, UIFont.Small, true)
        self.addMemberEntryLabel:initialise()
        self.addMemberEntryLabel:instantiate()
        self:addChild(self.addMemberEntryLabel)
        y = y + self.labelHeight

        self.addMemberEntry = ISTextEntryBox:new("", self.padX, y, safehouseEntryWidth, self.buttonHeight)
        self.addMemberEntry:initialise()
        self.addMemberEntry:instantiate()
        self.addMemberEntry.isValid = false
        self.addMemberEntry.onTextChange = ISSafehouseUI.onAddMemberEntryBoxTextChange
        self.addMemberEntry.onCommandEntered = ISSafehouseUI.onAddMemberEntryCommand
        self.addMemberEntry.tooltip = getText("Tooltip_SafehousePlus_AddMemberEntry_Default")
        self:addChild(self.addMemberEntry)

        self.addMemberButton = ISButton:new(self.padX + safehouseEntryWidth + self.shortPadY, y, safehouseEntryWidth, self.buttonHeight, self.addMemberButtonText, self, ISSafehouseUI.onOptionMouseDown)
        self.addMemberButton:initialise()
        self.addMemberButton:instantiate()
        self.addMemberButton.internal = "ADDMEMBER"
        self.addMemberButton.borderColor = self.buttonBorderColor
        self.addMemberButton.enable = false
        self:addChild(self.addMemberButton)

        y = y + self.buttonHeight + (self.shortPadY / 2) 

        self.removeMemberButton = ISButton:new(self.width - safehouseEntryWidth - self.padX, y, safehouseEntryWidth, self.buttonHeight, self.removeMemberButtonText, self, ISSafehouseUI.onOptionMouseDown)
        self.removeMemberButton:initialise()
        self.removeMemberButton:instantiate()
        self.removeMemberButton.internal = "REMOVEMEMBER"
        self.removeMemberButton.backgroundColor = {r=0.3, g=0, b=0, a=0.8}
        self.removeMemberButton.backgroundColorMouseOver = {r=0.6, g=0, b=0, a=0.8}
        self.removeMemberButton.borderColor = self.buttonBorderColor
        self:addChild(self.removeMemberButton)
        y = y + self.buttonHeight + self.padY
    else
        y = y + self.tickBoxHeight + self.padY
    end
    


    self.cancelButton = ISButton:new(self.width - safehouseEntryWidth - self.padX, y, safehouseEntryWidth, self.buttonHeight, self.cancelButtonText, self, ISSafehouseUI.onOptionMouseDown)
    self.cancelButton:initialise()
    self.cancelButton:instantiate()
    self.cancelButton.internal = "CANCEL"
    self.cancelButton.backgroundColor = {r=0.3, g=0, b=0, a=0.8}
    self.cancelButton.backgroundColorMouseOver = {r=0.6, g=0, b=0, a=0.8}
    self.cancelButton.borderColor = self.buttonBorderColor
    self:addChild(self.cancelButton)

    y = y + self.buttonHeight + self.padY
    
    self:setHeight(y)

    y = y - self.tickBoxHeight - self.padY
    
    self.respawnSafehouseTickBox = ISTickBox:new(self.padX, y, UIUtils.measureTextX(UIFont.Small, self.respawnSafehouseTickBoxText), 18, "", self, ISSafehouseUI.onClickRespawn)
    self.respawnSafehouseTickBox:initialise()
    self.respawnSafehouseTickBox:instantiate()
    self.respawnSafehouseTickBox.selected[1] = self.safehouse:isRespawnInSafehouse(self.player:getUsername())
    self.respawnSafehouseTickBox:addOption(self.respawnSafehouseTickBoxText)
    self:addChild(self.respawnSafehouseTickBox)
    self.respawnSafehouseTickBox.enable = false

    y = y - self.tickBoxHeight - self.shortPadY
    
    self.showSafehouseLimitsTickBox = ISTickBox:new(self.padX, y, UIUtils.measureTextX(UIFont.Small, self.showSafehouseTickBoxText), 18, "", self, ISSafehouseUI.onClickShowSafehouseLimits);
    self.showSafehouseLimitsTickBox:initialise()
    self.showSafehouseLimitsTickBox:instantiate()
    self.showSafehouseLimitsTickBox.selected[1] = self.highlightLimits
    self.showSafehouseLimitsTickBox:addOption(self.showSafehouseTickBoxText)
    self:addChild(self.showSafehouseLimitsTickBox)


    self:updateScrollableMemberList()
    self:updateButtons()

    self.onDrawSafehouseLimits = function ()
        self:drawSafehouseLimits()
    end

    Events.OnTick.Add(self.onDrawSafehouseLimits)

    local x = (getCore():getScreenWidth() - self.width) / 2
    local y = (getCore():getScreenHeight() - self.height) / 2

    self:setX(x)
    self:setY(y)
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

function ISSafehouseUI:getPlayerOwnedSafehouseCount(playerName)
    playerName = playerName ~= nil and playerName or self.player:getUsername()
    local safehouses = SafeHouse.getSafehouseList()
    local numOfSafehouses = 0

    for i = 0, safehouses:size() - 1 do
        local safehouse = safehouses:get(i)

        if safehouse:getOwner() == playerName then
            numOfSafehouses = numOfSafehouses + 1
        end
    end

    return numOfSafehouses
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
    local selectedRow = self.memberScrollList.selected

    -- Verifica se o índice selecionado é válido
    if not selectedRow or selectedRow < 1 or selectedRow > #self.memberScrollList.items then
        self.memberScrollList.selected = nil -- Reseta a seleção se for inválida
        return nil
    end

    -- Retorna o item correspondente à linha selecionada
    local selectedItem = self.memberScrollList.items[selectedRow].item
    return selectedItem
end

function ISSafehouseUI:removeMember(playerName)
    if not getServerOptions():getBoolean("SafehouseAllowTrepass") then
        local players = getOnlinePlayers()
        
        for i=0, players:size() - 1 do
            local player = players:get(i)
            local pX = math.floor(player:getX())
            local py = math.floor(player:getY())

            if player:getUsername() == playerName then
                if pX >= self.x1 and pX <= self.x2 and py >= self.y1 and py <= self.y2 then
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
    if not self.safehouseMembersLimitLabel then return end

    local x = self.safehouseMembersLimitLabel:getX()
    local y = self.safehouseMembersLimitLabel:getY()

    local memberLimit = SandboxVars.SafehousePlus.MemberLimit <= 0 and getText("IGUI_ISSafehouseUI_SafehouseMembersUnlimitedLabel") or tostring(SandboxVars.SafehousePlus.MemberLimit)
    local safehouseMembersLimitLabelText = getText("IGUI_ISSafehouseUI_SafehouseMembersLabel") .. " (" .. tostring(self:numOfMembers()) .. " / " .. memberLimit .. ")"
    self.safehouseMembersLimitLabel:setName(safehouseMembersLimitLabelText)
    self.safehouseMembersLimitLabel.x = self:getWidth() - UIUtils.measureTextX(UIFont.Small, safehouseMembersLimitLabelText) - self.padX
end

function ISSafehouseUI:updateRemoveMemberButton()
    if not self.removeMemberButton then
        return
    end

    local isOwner = self:isOwner()
    local isAdmin = self:isAdmin()
    local selectedMember = self:getSelectedMemberFromScrollableList()

    if (isOwner or isAdmin) and selectedMember ~= nil and selectedMember then
        self.removeMemberButton.enable = not self:isOwner(selectedMember)
    else
        self.removeMemberButton.enable = false
    end
end

function ISSafehouseUI:updateButtons()
    local isOwner = self:isOwner()
    local isMember = self:isMember()
    local isAdmin = self:isAdmin()

    self:updateRemoveMemberButton()

    if getServerOptions():getBoolean("SafehouseAllowRespawn") and self:isMemberOrOwner() then
        self.respawnSafehouseTickBox.enable = true
    else
        self.respawnSafehouseTickBox.enable = false
    end

    if isOwner or isAdmin then
        if self.releaseSafehouseButton then
            self.releaseSafehouseButton.enable = true
        end

        if self.safehouseOwnerEntry then
            self.safehouseOwnerEntry:setEditable(true)
        end

        if self.safehouseNameEntry then
            self.safehouseNameEntry:setEditable(true)
        end

        if self.addMemberEntry then
            self.addMemberEntry:setEditable(true)
        end
    else
        if self.safehouseOwnerEntry then
            self.safehouseOwnerEntry:setEditable(false)
        end

        if self.safehouseNameEntry then
            self.safehouseNameEntry:setEditable(false)
        end

        if self.addMemberEntry then
            self.addMemberEntry:setEditable(false)
        end

        if self.releaseSafehouseButton then
            self.releaseSafehouseButton.enable = false
        end

        if self.addMemberButton then
            self.addMemberButton.enable = false
        end
    end

    if isMember then
        if self.exitSafehouseButton then
            self.exitSafehouseButton.enable = true
        end
    else
        if self.exitSafehouseButton then
            self.exitSafehouseButton.enable = false
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
    -- local safehouseOwner = self.safehouse:getOwner()

    self.safehouseTitleLabel:setName(safehouseName)
end

function ISSafehouseUI.OnSafehousesChanged()
    for i, safeWindow in pairs(ISSafehouseUI.instances) do
        local safehouse = safeWindow.safehouse

        if not SafeHouse.getSafehouseList():contains(safehouse) then
            safeWindow:close()
        else
            safeWindow:updateAll()
        end
    end
end

function ISSafehouseUI:updateScrollableMemberList()
    self.memberScrollList:clear()
    local safehousePlayers = self.safehouse:getPlayers()
    local owner = self.safehouse:getOwner()
    local selected = self.memberScrollList.selected

    if not safehousePlayers:contains(owner) then
        self.safehouse:addPlayer(owner)
    end

    for i=0, safehousePlayers:size() - 1 do
        local playerName = safehousePlayers:get(i)
        self.memberScrollList:addItem(playerName, playerName)
    end

    if selected > #self.memberScrollList.items then
        self.memberScrollList.selected = math.min(#self.memberScrollList.items, 1)
    end

    
    self:updateMemberLimitLabel()
end

function ISSafehouseUI:onMemberScrollListMouseDown(x, y)
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
        self.parent:updateRemoveMemberButton()
        if self.onmousedown then
            self.onmousedown(self.parent, self.items[self.selected].item);
        end
    end
end

function ISSafehouseUI:doMemberScrollListDrawItem(y, item, alt)
	if not item.height then item.height = self.itemheight end
    local padX = 15

    if self.selected == item.index then
        self:drawRect(0, y, self:getWidth(), item.height-1, 0.3, 0.7, 0.35, 0.15)
    end

    if self.parent.safehouse:getOwner() == item.item then
        self:drawTextRight(self.parent.ownerTagName, self.width - self.parent.shortPadX - self.parent.padX, y + self.itemPadY, 0.9, 0.0, 0.0, 0.9, self.font)
    else
        self:drawTextRight(self.parent.memberTagName, self.width - self.parent.shortPadX - self.parent.padX, y + self.itemPadY, 0.0, 0.9, 0.0, 0.9, self.font)
    end

	self:drawRectBorder(0, y, self:getWidth(), item.height, 0.5, self.borderColor.r, self.borderColor.g, self.borderColor.b)
	self:drawText(item.text, self.parent.shortPadX, y + self.itemPadY, 0.9, 0.9, 0.9, 0.9, self.font)
	y = y + item.height

	return y
end

function ISSafehouseUI:onAddMemberEntryBoxTextChange()
    if not self.parent.addMemberButton then return end
    
    local newMember = self:getInternalText():match("^%s*(.-)%s*$") -- Remove espaços extras
    local canAddMember = false
    local setValidColor = false
    local tooltip = nil

    local isAdmin = self.parent:isAdmin()
    
    local isEmptyName = #newMember == 0
    local isMemberOrOwner = self.parent:isMemberOrOwner(newMember)
    
    local memberLimit = SandboxVars.SafehousePlus.MemberLimit
    local hasMemberLimit = SandboxVars.SafehousePlus.MemberLimit > 0
    local numOfMembers = self.parent:numOfMembers()
    local reachedLimit = hasMemberLimit and numOfMembers >= memberLimit and not isAdmin

    local isMultipleSafehouse = SandboxVars.SafehousePlus.MultipleSafehouse
    local isMemberOfASafehouse = self.parent:isMemberOfASafehouse(newMember) and not isAdmin

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
        tooltip = self.addMemberEntryTooltipDefaultText
        canAddMember = true
        setValidColor = true
    end

    self.tooltip = tooltip
    self.isValid = canAddMember
    self:setValid(setValidColor)
    self.parent.addMemberButton.enable = canAddMember
end

function ISSafehouseUI:onAddMemberEntryCommand()
    if self.isValid then
        self.parent:addMemberButtonAction()
    end
end

function ISSafehouseUI:onSafehouseNameEntryTextChange()
    local newName = self:getInternalText()

    if self.parent.safehouse:getTitle() == newName then
        self.isValid = false
        self:setValid(true)
        return
    end

    if #newName > self.minLength and #newName <= self.maxLength and (self.parent:isOwner() or self.parent:isAdmin()) then
        self.isValid = true
        self:setValid(true)
    else
        self.isValid = false
        self:setValid(false)
    end
end

function ISSafehouseUI:onSafehouseNameEntryCommand()
    if self.isValid then
        local newName = self:getInternalText()
        self.parent.safehouse:setTitle(newName)
        self.parent.safehouseTitleLabel:setName(newName)
        self.parent.safehouse:syncSafehouse()
        self:setValid(true)
        self.isValid = false

        local modalWidth = 350
        local modalHeight = 100
        local modalX = self.parent:getAbsoluteX() + ((self.parent:getWidth() - modalWidth) / 2)
        local modalY = self.parent:getAbsoluteY() + (((self.parent:getHeight() / 2) - modalHeight) / 2)
        local modal = ISModalDialog:new(modalX, modalY, modalWidth, modalHeight, getText("IGUI_ISSafehouseUI_Dialog_SafehouseNameChange"), false, nil, nil)
        modal:initialise()
        modal:addToUIManager()
    else
        self:setText(self.parent.safehouse:getTitle())
        self:setValid(true)
        self.isValid = false
    end
end

function ISSafehouseUI:onSafehouseOwnerEntryTextChange()
    local oldOwner = self.parent.safehouse:getOwner()
    local newOwner = self:getInternalText():match("^%s*(.-)%s*$")
    local isAdmin = self.parent:isAdmin()

    local canSetOwner = false
    local setValidColor = false
    local tooltip = nil

    if oldOwner == newOwner or #newOwner == 0 then
        canSetOwner = false
        setValidColor = true
    else
        local isMember = false
        local isOnline = false
        local isVip = self.parent.vipPlayers[newOwner]
        
        local ownerLimit = (
            isVip
            and SandboxVars.SafehousePlus.SpecialPlayersOwnerLimit 
            or SandboxVars.SafehousePlus.OwnerLimit
        )
        local playerOwnedSafehouseCount = self.parent:getPlayerOwnedSafehouseCount(newOwner)
        local isReachedOwnedLimit = playerOwnedSafehouseCount >= ownerLimit
        
        if isVip then
            if playerOwnedSafehouseCount >= SandboxVars.SafehousePlus.SpecialPlayersOwnerLimit then
                isReachedOwnedLimit = true
            end
        else
            if playerOwnedSafehouseCount >= SandboxVars.SafehousePlus.OwnerLimit then
                isReachedOwnedLimit = true
            end
        end

        local players = self.parent.safehouse:getPlayers()
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

        if not isAdmin then
            if not isMember then
                tooltip = getText("Tooltip_SafehousePlus_setNewOwnerEntry_isMember", newOwner)
            elseif not isOnline then
                tooltip = getText("Tooltip_SafehousePlus_setNewOwnerEntry_isOnline", newOwner)
            elseif isReachedOwnedLimit then
                tooltip = getText("Tooltip_SafehousePlus_setNewOwnerEntry_isReachedOwnedLimit", newOwner)
            end
        end

        if (isMember and isOnline and not isReachedOwnedLimit) or isAdmin then
            canSetOwner = true
            setValidColor = true
        end   
    end

    self.isValid = canSetOwner
    self:setValid(setValidColor)
    self.tooltip = tooltip
end

function ISSafehouseUI:onSafehouseOwnerEntryCommand()
    if self.isValid then
        local newOwner = self:getInternalText():match("^%s*(.-)%s*$")
        self.parent.safehouse:setOwner(newOwner)
        self.parent.safehouse:syncSafehouse()
        self.parent:updateScrollableMemberList()

        local modalWidth = 350
        local modalHeight = 100
        local modalX = self.parent:getAbsoluteX() + ((self.parent:getWidth() - modalWidth) / 2)
        local modalY = self.parent:getAbsoluteY() + (((self.parent:getHeight() / 2) - modalHeight) / 2)
        local modal = ISModalDialog:new(modalX, modalY, modalWidth, modalHeight, getText("IGUI_ISSafehouseUI_Dialog_OwnerChange"), false, nil, nil)
        modal:initialise()
        modal:addToUIManager()
    end
end

function ISSafehouseUI:onClickRespawn(clickedOption, enabled)
    self.safehouse:setRespawnInSafehouse(enabled, self.player:getUsername())
end

function ISSafehouseUI:prerender()
    ISPanel.prerender(self)

    if self.safehouseNameEntry then 
        if not self.safehouseNameEntry:isFocused() then
            self.safehouseNameEntry:setText(self.safehouse:getTitle())
            self.safehouseNameEntry.tooltip = self.safehouseNameEntryTooltipDefaultText
        else
            self.safehouseNameEntry.tooltip = nil
        end
    end

    if self.safehouseOwnerEntry and not self.safehouseOwnerEntry:isFocused() then
        self.safehouseOwnerEntry:setText(self.safehouse:getOwner())
        self.safehouseOwnerEntry.tooltip = self.safehouseOwnerEntryTooltipDefaultText
    end

    if self.addMemberEntry and not self.addMemberEntry:isFocused() then
        self.addMemberEntry.tooltip = self.addMemberEntryTooltipDefaultText
    end
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
    local x2 = self.x2
    local y2 = self.y2

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
    if not self.addMemberEntry.isValid then return end
    local newMember = self.addMemberEntry:getInternalText():match("^%s*(.-)%s*$")
    self.safehouse:addPlayer(newMember)
    self:updateScrollableMemberList()
    self:updateMemberLimitLabel()
    self.safehouse:syncSafehouse()
    self.addMemberButton.enable = false
    self.addMemberEntry.isValid = false
    self.addMemberEntry:setText("")
    self.addMemberEntry:setValid(true)
end

function ISSafehouseUI:removeMemberButtonAction()
    if not (self:isOwner() or self:isAdmin()) then return end
    local selected = self.memberScrollList.selected
    if not selected or not self.memberScrollList.items or #self.memberScrollList.items < 1 or #self.memberScrollList.items < selected then
        return
    end
    local memberName = self.memberScrollList.items[selected].item
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
    o.x2 = o.safehouse:getX2() - 1
    o.y2 = o.safehouse:getY2() - 1

    -- Garantir que x1 < x2 e y1 < y2
    if o.x1 > o.x2 then
        o.x1, o.x2 = o.x2, o.x1
    end
    if o.y1 > o.y2 then
        o.y1, o.y2 = o.y2, o.y1
    end

    o.safehouseSize = (o.x2 + 1 - o.x1) * (o.y2 + 1 - o.y1) 

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

