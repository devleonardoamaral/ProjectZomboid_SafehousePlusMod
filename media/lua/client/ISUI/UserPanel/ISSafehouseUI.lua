UIUtils = require("ISUI/SP_UIUtils")

ISSafehouseUI = ISPanel:derive("ISSafehouseUI")
ISSafehouseUI.currentId = 0
ISSafehouseUI.instances = {}

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

function ISSafehouseUI:initialise()
    ISPanel.initialise(self)

    local y = 90
    local width = self:getWidth()

    local btnWid = 200
    local btnHgt = math.max(25, FONT_HGT_SMALL + 6)

    local smallBtnWid = 100
    local smallBtnHgt = FONT_HGT_SMALL + 4

    local padX = 20
    local padY = 20
    local shortPadY = 5

    local isOwner = self:isOwner()
    local isMember = self:isMember()
    local isAdmin = self:isAdmin()

    if not self.safehouse:getPlayers():contains(self.safehouse:getOwner()) then
        self.safehouse:addPlayer(self.safehouse:getOwner())
        self.safehouse:syncSafehouse()
    end

    local labelHeight = UIUtils.measureFontY(UIFont.Small) + 4

    self.coordLabel = ISLabel:new(padX + ((width - (padX * 2)) / 4), y, labelHeight, getText("IGUI_ISSafehouseUI_CoordLabel"), 1,1,1,1, UIFont.Small, true)
    self.coordLabel.center = true
    self.coordLabel:initialise()
    self.coordLabel:instantiate()
    self:addChild(self.coordLabel)

    self.sizeLabel = ISLabel:new(padX + (((width - (padX * 2)) / 4) * 3), y, labelHeight, getText("IGUI_ISSafehouseUI_SizeLabel"), 1,1,1,1, UIFont.Small, true)
    self.sizeLabel.center = true
    self.sizeLabel:initialise()
    self.sizeLabel:instantiate()
    self:addChild(self.sizeLabel)
    y = y + UIUtils.measureFontY(UIFont.Small) + shortPadY

    self.sizeText = ISLabel:new(padX + (((width - (padX * 2)) / 4) * 3), y, labelHeight, tostring(self.safehouseSize) .. " tiles²", 0.6,0.6,1,1, UIFont.Small, true)
    self.sizeText.center = true
    self.sizeText:initialise()
    self.sizeText:instantiate()
    self:addChild(self.sizeText)

    self.coordText1 = ISLabel:new(padX + ((width - (padX * 2)) / 4), y, labelHeight, "N:" .. tostring(self.x1) .. "," .. tostring(self.y1), 0.6,0.6,1,1, UIFont.Small, true)
    self.coordText1.center = true
    self.coordText1:initialise()
    self.coordText1:instantiate()
    self:addChild(self.coordText1)
    y = y + UIUtils.measureFontY(UIFont.Small) + shortPadY

    self.coordText2 = ISLabel:new(padX + ((width - (padX * 2)) / 4), y, labelHeight, "S:" .. tostring(self.x2) .. "," .. tostring(self.y2), 0.6,0.6,1,1, UIFont.Small, true)
    self.coordText2.center = true
    self.coordText2:initialise()
    self.coordText2:instantiate()
    self:addChild(self.coordText2)
    y = y + UIUtils.measureFontY(UIFont.Small) + padY

    local aY = padY

    self.reloadBtn = ISButton:new(padX, aY, smallBtnWid, smallBtnHgt, getText("IGUI_ISSafehouseUI_ReloadButton"), self, nil, ISSafehouseUI.onOptionMouseDown)
    self.reloadBtn:initialise()
    self.reloadBtn:instantiate()
    self.reloadBtn.internal = "REOPEN"
    self.reloadBtn.borderColor = self.buttonBorderColor
    self:addChild(self.reloadBtn)

    if isOwner or isAdmin then
        self.releaseBtn = ISButton:new(width - smallBtnWid - padX, aY, smallBtnWid, smallBtnHgt, getText("IGUI_ISSafehouseUI_ReleaseSafehouseButton"), self, nil, ISSafehouseUI.onOptionMouseDown)
        self.releaseBtn:initialise()
        self.releaseBtn:instantiate()
        self.releaseBtn.internal = "RELEASE"
        self.releaseBtn.backgroundColor = {r=0.3, g=0, b=0, a=0.8}
        self.releaseBtn.backgroundColorMouseOver = {r=0.6, g=0, b=0, a=0.8}
        self.releaseBtn.borderColor = self.buttonBorderColor
        self:addChild(self.releaseBtn)
        aY = aY + smallBtnHgt + shortPadY
    end

    if isMember then
        self.exitBtn = ISButton:new(width - smallBtnWid - padX, aY, smallBtnWid, smallBtnHgt, getText("IGUI_ISSafehouseUI_ExitSafehouseButton"), self, ISSafehouseUI.onOptionMouseDown)
        self.exitBtn:initialise()
        self.exitBtn:instantiate()
        self.exitBtn.internal = "EXIT"
        self.exitBtn.backgroundColor = {r=0.3, g=0, b=0, a=0.8}
        self.exitBtn.backgroundColorMouseOver = {r=0.6, g=0, b=0, a=0.8}
        self.exitBtn.borderColor = self.buttonBorderColor
        self:addChild(self.exitBtn)
    end
    
    self.titleEntryLabel = ISLabel:new(padX, y, labelHeight, getText("IGUI_ISSafehouseUI_NameLabel") .. ":", 1,1,1,1, UIFont.Small, true)
    self.titleEntryLabel:initialise()
    self.titleEntryLabel:instantiate()
    self:addChild(self.titleEntryLabel)

    local ownerEntryLabelHeight = UIUtils.measureFontY(UIFont.Small) + 4
    self.ownerEntryLabel = ISLabel:new(width - padX - btnWid, y, ownerEntryLabelHeight, getText("IGUI_ISSafehouseUI_OwnerLabel") .. ":", 1,1,1,1, UIFont.Small, true)
    self.ownerEntryLabel:initialise()
    self.ownerEntryLabel:instantiate()
    self:addChild(self.ownerEntryLabel)
    y = y + ownerEntryLabelHeight

    local titleText = self.safehouse:getTitle()
    self.titleEntry = ISTextEntryBox:new(titleText, padX, y, btnWid, btnHgt)
    self.titleEntry:initialise()
    self.titleEntry:instantiate()
    self.titleEntry.minTitleLength = 3
    self.titleEntry.maxTitleLength = 30
    self.titleEntry.isValid = true
    self.titleEntry.onTextChange = ISSafehouseUI.onTitleEntryTextChange
    self.titleEntry.onCommandEntered = ISSafehouseUI.onTitleEntryCommand
    self.titleEntry.target = self
    if not isOwner and not isAdmin then self.titleEntry:setEditable(false) end
    self:addChild(self.titleEntry)

    local ownerText = self.safehouse:getOwner()
    self.ownerEntry = ISTextEntryBox:new(ownerText, width - padX - btnWid, y, btnWid, btnHgt)
    self.ownerEntry:initialise()
    self.ownerEntry:instantiate()
    self.ownerEntry.isValid = true
    self.ownerEntry.onTextChange = ISSafehouseUI.onOwnerEntryTextChange
    self.ownerEntry.onCommandEntered = ISSafehouseUI.onOwnerEntryCommand
    self.ownerEntry.target = self
    if not isOwner and not isAdmin then self.ownerEntry:setEditable(false) end
    self:addChild(self.ownerEntry)
    y = y + btnHgt + padY

    local membersScrollListLabelHeight = UIUtils.measureFontY(UIFont.Small) + 4
    self.membersScrollListLabel = ISLabel:new(padX, y, membersScrollListLabelHeight, getText("IGUI_ISSafehouseUI_MembersScrollListLabel") .. ":", 1,1,1,1, UIFont.Small, true)
    self.membersScrollListLabel:initialise()
    self.membersScrollListLabel:instantiate()
    self:addChild(self.membersScrollListLabel)
    y = y + membersScrollListLabelHeight

    local membersScrollListWidth = self.width - (padX * 2)
    local membersScrollListHeight = 200
    self.membersScrollList = ISScrollingListBox:new(UIUtils.centerWidget(membersScrollListWidth, self.width), y, membersScrollListWidth, membersScrollListHeight)
    self.membersScrollList:initialise()
    self.membersScrollList:instantiate()
    self.membersScrollList:setFont(UIFont.Small, 4)
    self.membersScrollList.selected = 0
    self.membersScrollList.joypadParent = self
    self.membersScrollList.doDrawItem = ISSafehouseUI.doMemberListDrawItem
    self.membersScrollList.drawBorder = true
    self.membersScrollList.onMouseDown = ISSafehouseUI.onMemberListMouseDown
    --self.membersScrollList:setOnMouseDownFunction(self, ISSafehouseUI.showSafehouseUI)
    self.membersScrollList.target = self
    self:addChild(self.membersScrollList)
    y = y + membersScrollListHeight + shortPadY

    if self:isOwner() or self:isAdmin() then
        local btnMngWid = (width - (2 * padX) - (2 * shortPadY)) / 3

        local addMemberEntryText = ""
        self.addMemberEntry = ISTextEntryBox:new(addMemberEntryText, padX, y, btnMngWid, btnHgt)
        self.addMemberEntry:initialise()
        self.addMemberEntry:instantiate()
        self.addMemberEntry.isValid = true
        self.addMemberEntry.onTextChange = ISSafehouseUI.onAddMemberTextChange
        self.addMemberEntry.target = self
        if not isOwner and not isAdmin then self.addMemberEntry:setEditable(false) end
        self:addChild(self.addMemberEntry)

        self.addMemberBtn = ISButton:new(padX + btnMngWid + shortPadY, y, btnMngWid, btnHgt, getText("IGUI_ISSafehouseUI_AddMemberButton"), self, ISSafehouseUI.onOptionMouseDown)
        self.addMemberBtn:initialise()
        self.addMemberBtn:instantiate()
        self.addMemberBtn.internal = "ADDMEMBER"
        self.addMemberBtn.borderColor = self.buttonBorderColor
        self.addMemberBtn.enable = false
        self:addChild(self.addMemberBtn)

        self.removeMemberBtn = ISButton:new(padX + (btnMngWid * 2) + (shortPadY * 2), y, btnMngWid, btnHgt, getText("IGUI_ISSafehouseUI_RemoveMemberButton"), self, ISSafehouseUI.onOptionMouseDown)
        self.removeMemberBtn:initialise()
        self.removeMemberBtn:instantiate()
        self.removeMemberBtn.internal = "REMOVEMEMBER"
        self.removeMemberBtn.backgroundColor = {r=0.3, g=0, b=0, a=0.8}
        self.removeMemberBtn.backgroundColorMouseOver = {r=0.6, g=0, b=0, a=0.8}
        self.removeMemberBtn.borderColor = self.buttonBorderColor

        self:addChild(self.removeMemberBtn)
    end

    y = y + btnHgt + padY

    local showSafehouseLimitsText = getText("IGUI_SafehouseUI_SafehouseLimits")
    local showSafehouseLimitsWidth = UIUtils.measureTextX(UIFont.Small, showSafehouseLimitsText)
    self.showSafehouseLimits = ISTickBox:new(padX, y, showSafehouseLimitsWidth, 18, "", self, ISSafehouseUI.onClickShowSafehouseLimits);
    self.showSafehouseLimits:initialise()
    self.showSafehouseLimits:instantiate()
    self.showSafehouseLimits.selected[1] = self.highlightLimits
    self.showSafehouseLimits:addOption(showSafehouseLimitsText)
    self:addChild(self.showSafehouseLimits)

    y = y + 18 + shortPadY

    local respawnTickBoxText = getText("IGUI_SafehouseUI_Respawn")
    local respawnTickBoxWidth = UIUtils.measureTextX(UIFont.Small, respawnTickBoxText)
    self.respawnTickBox = ISTickBox:new(padX, y, respawnTickBoxWidth, 18, "", self, ISSafehouseUI.onClickRespawn)
    self.respawnTickBox:initialise()
    self.respawnTickBox:instantiate()
    self.respawnTickBox.selected[1] = self.safehouse:isRespawnInSafehouse(self.player:getUsername())
    self.respawnTickBox:addOption(respawnTickBoxText)
    self:addChild(self.respawnTickBox)
    self.respawnTickBox.enable = false

    if getServerOptions():getBoolean("SafehouseAllowRespawn") and self:isMemberOrOwner() then
        self.respawnTickBox.enable = true
    end

    self.cancel = ISButton:new(width - btnWid - padX, y, btnWid, btnHgt, getText("UI_btn_close"), self, ISSafehouseUI.onOptionMouseDown)
    self.cancel:initialise()
    self.cancel:instantiate()
    self.cancel.internal = "CANCEL"
    self.cancel.backgroundColor = {r=0.3, g=0, b=0, a=0.8}
    self.cancel.backgroundColorMouseOver = {r=0.6, g=0, b=0, a=0.8}
    self.cancel.borderColor = self.buttonBorderColor
    self:addChild(self.cancel)
    y = y + btnHgt + 20

    self:setHeight(y)
    self.height = y

    self:populateList()

    self:updateRemoveMemberBtn()
end

function ISSafehouseUI:updateRemoveMemberBtn()
    local isOwner = self:isOwner()
    local isMember = self:isMember()
    local isAdmin = self:isAdmin()

    if self.removeMemberBtn then
        if isOwner or isAdmin then
            local selected = self.membersScrollList.selected

            if selected and self.membersScrollList.items[selected] then
                local memberName = self.membersScrollList.items[selected].item
                if self:isOwner(memberName) then
                    self.removeMemberBtn.enable = false
                else
                    self.removeMemberBtn.enable = true
                end
            else
                self.removeMemberBtn.enable = false
            end
        else
            if self.removeMemberBtn then
                self.removeMemberBtn.enable = false
            end
        end
    end
end

function ISSafehouseUI:updateButtons()
    local isOwner = self:isOwner()
    local isMember = self:isMember()
    local isAdmin = self:isAdmin()

    self:updateRemoveMemberBtn()

    if isOwner or isAdmin then
        if self.releaseBtn then
            self.releaseBtn.enable = true
        end

        if self.ownerEntry then
            self.ownerEntry:setEditable(true)
        end

        if self.titleEntry then
            self.titleEntry:setEditable(true)
        end

        if self.addMemberEntry then
            self.addMemberEntry:setEditable(true)
        end
    else
        if self.ownerEntry then
            self.ownerEntry:setEditable(false)
        end

        if self.titleEntry then
            self.titleEntry:setEditable(false)
        end

        if self.addMemberEntry then
            self.addMemberEntry:setEditable(false)
        end

        if self.releaseBtn then
            self.releaseBtn.enable = false
        end

        if self.addMemberBtn then
            self.addMemberBtn.enable = false
        end
    end

    if isMember then
        if self.exitBtn then
            self.exitBtn.enable = true
        end
    else
        if self.exitBtn then
            self.exitBtn.enable = false
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
    self:populateList()
    self:updateButtons()

    local safehouseName = self.safehouse:getTitle()
    local safehouseOwner = self.safehouse:getOwner()

    self.titleEntry:setText(safehouseName)
    self.ownerEntry:setText(safehouseOwner)
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

function ISSafehouseUI:populateList()
    self.membersScrollList:clear()
    local safehousePlayers = self.safehouse:getPlayers()

    for i=0, safehousePlayers:size() - 1 do
        local playerName = safehousePlayers:get(i)
        self.membersScrollList:addItem(playerName, playerName)
    end

    if #self.membersScrollList.items > 0 then
        self.membersScrollList.selected = 1
    end
end

function ISSafehouseUI:onMemberListMouseDown(x, y)
	if #self.items == 0 then return end
	local row = self:rowAt(x, y)

	if row > #self.items then
		row = nil
    elseif row < 1 then
		row = nil
	end
	
    if row ~= nil then
        self.selected = row
        local playerName = self.items[row].item

        if self.target.removeMemberBtn then
            if self.target:isOwner(playerName) then
                self.target.removeMemberBtn.enable = false
            else
                self.target.removeMemberBtn.enable = true
            end
        end

        getSoundManager():playUISound("UISelectListItem")
        if self.onmousedown then
            self.onmousedown(self.target, self.items[self.selected].item);
        end
    else
        if self.target.removeMemberBtn then
            self.target.removeMemberBtn.enable = false
        end
    end
end

function ISSafehouseUI:doMemberListDrawItem(y, item, alt)
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

function ISSafehouseUI:isMemberOrOwner(playerName)
    playerName = playerName ~= nil and playerName or self.player:getUsername()
    return self.safehouse:getPlayers():contains(playerName)
end

function ISSafehouseUI:onAddMemberTextChange()
    local newOwner = self:getInternalText():match("^%s*(.-)%s*$")

    if #newOwner > 0 and not self.target:isMemberOrOwner(newOwner) then
        self:setValid(true)

        if self.target.addMemberBtn then
            self.target.addMemberBtn.enable = true
        end
    else
        self:setValid(false)

        if self.target.addMemberBtn then
            self.target.addMemberBtn.enable = false
        end
    end
end

function ISSafehouseUI:onTitleEntryTextChange()
    local text = self:getInternalText()

    if #text > self.maxTitleLength or #text < self.minTitleLength then
        self.isValid = false
        self:setValid(false)
    else
        self.isValid = true
        self:setValid(true)
    end
end

function ISSafehouseUI:onOwnerEntryTextChange()
    local oldOwner = self.target.safehouse:getOwner()
    local newOwner = self:getInternalText():match("^%s*(.-)%s*$")

    if oldOwner == newOwner then
        self:setValid(false)
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
            end
        end

        if (isMember and isOnline and not isOwner) or self.target:isAdmin() then
            self:setValid(true)
        else
            self:setValid(false)
        end
    end
end

function ISSafehouseUI:onTitleEntryCommand()
    local newName = self:getInternalText()
    
    if self.isValid and (self.target:isOwner() or self.target:isAdmin()) and self.target.safehouse:getTitle() ~= newName then
        self.target.safehouse:setTitle(newName)
        self.target:updateAll()
        self.target.safehouse:syncSafehouse()

        local modalWidth = 350
        local modalHeight = 100
        local modalX = self.target:getAbsoluteX() + ((self.target:getWidth() - modalWidth) / 2)
        local modalY = self.target:getAbsoluteY() + (((self.target:getHeight() / 2) - modalHeight) / 2)

        local modal = ISModalDialog:new(modalX, modalY, modalWidth, modalHeight, getText("IGUI_ISSafehouseUI_Dialog_SafehouseNameChange"), false, nil, nil)
        modal:initialise()
        modal:addToUIManager()
    else
        self:setText(self.target.safehouse:getTitle())
    end
end

function ISSafehouseUI:onOwnerEntryCommand()
    local oldOwner = self.target.safehouse:getOwner()
    local newOwner = self:getInternalText():match("^%s*(.-)%s*$")

    if oldOwner == newOwner then
        self:setText(self.target.safehouse:getOwner())
        self:setValid(false)
        return
    end

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
        end
    end

    if (isMember and isOnline and not isOwner) or self.target:isAdmin() then
        self.target.safehouse:setOwner(newOwner)
        self.target.safehouse:addPlayer(newOwner)
        self.target.safehouse:syncSafehouse()
        self.target:updateAll()

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

    if not self.highlightLimits then return end

    local x1 = self.safehouse:getX()
    local y1 = self.safehouse:getY()
    local x2 = self.safehouse:getX2()
    local y2 = self.safehouse:getY2()

    -- Garantir que x1 < x2 e y1 < y2
    if x1 > x2 then
        x1, x2 = x2, x1
    end
    if y1 > y2 then
        y1, y2 = y2, y1
    end

    x2 = x2 - 1
    y2 = y2 - 1

    local r, g, b, a = 0.6, 1, 0.6, 1

    -- Percorrer a borda superior (y = y1)
    for x = x1, x2 do
        local sq = getCell():getGridSquare(x, y1, 0)
        if sq then
            UIUtils.highlightSquare(sq, r, g, b, a)
        end
    end

    -- Percorrer a borda inferior (y = y2)
    for x = x1, x2 do
        local sq = getCell():getGridSquare(x, y2, 0)
        if sq then
            UIUtils.highlightSquare(sq, r, g, b, a)
        end
    end

    -- Percorrer a borda esquerda (x = x1)
    for y = y1 + 1, y2 - 1 do
        local sq = getCell():getGridSquare(x1, y, 0)
        if sq then
            UIUtils.highlightSquare(sq, r, g, b, a)
        end
    end

    -- Percorrer a borda direita (x = x2)
    for y = y1 + 1, y2 - 1 do
        local sq = getCell():getGridSquare(x2, y, 0)
        if sq then
            UIUtils.highlightSquare(sq, r, g, b, a)
        end
    end
end

function ISSafehouseUI:onOptionMouseDown(button, x, y)
    if button.internal == "ADDMEMBER" then
        if self:isOwner() or self:isAdmin() then
            local newMember = self.addMemberEntry:getInternalText():match("^%s*(.-)%s*$")
            if #newMember > 0 and not self:isMember(newMember) then
                self.safehouse:addPlayer(newMember)
                self:updateAll()
                self.safehouse:syncSafehouse()
            end
        end
    elseif button.internal == "REMOVEMEMBER" then
        if self:isOwner() or self:isAdmin() then
            local selected = self.membersScrollList.selected
            if not selected then return end
            if not self.membersScrollList.items then return end
            if #self.membersScrollList.items < 1 then return end
            if #self.membersScrollList.items < selected then return end
            local memberName = self.membersScrollList.items[selected].item
            if self:isOwner(memberName) then return end
            self:removeMember(memberName)
            self:updateAll()
            self.safehouse:syncSafehouse()
        end
    elseif button.internal == "RELEASE" then
        if self:isOwner() or self:isAdmin() then
            self.safehouse:removeSafeHouse(getPlayerFromUsername(self.safehouse:getOwner()))
            self:close()
        end
    elseif button.internal == "REOPEN" then
        ISSafehouseUI.reopen(self.id)
    elseif button.internal == "EXIT" then
        if self:isOwner() then return end
        self:removeMember(self.player:getUsername())
        ISSafehouseUI.OnPlayerDeath()
    elseif button.internal == "CANCEL" then
        self:close()
    end
end

function ISSafehouseUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
    ISSafehouseUI.instances[self.id] = nil
end

function ISSafehouseUI.OnPlayerDeath()
    for i, safeWindow in pairs(ISSafehouseUI.instances) do
        safeWindow:close()
    end
end

function ISSafehouseUI.reopen(id)
    local player = ISSafehouseUI.instances[id].player
    local safehouse = ISSafehouseUI.instances[id].safehouse
    local x = ISSafehouseUI.instances[id]:getAbsoluteX()
    local y = ISSafehouseUI.instances[id]:getAbsoluteY()
    ISSafehouseUI.instances[id]:close()
    local safehouseUI = ISSafehouseUI:new(x, y, 500, 450, safehouse, player)
    safehouseUI:initialise()
    safehouseUI:addToUIManager()
    safehouseUI:bringToTop()
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
    o.moveWithMouse = true

    o.updateTick = 0
    o.updateTickMax = 120
    
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=0.8}
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5}

    o.highlightLimits = false

    ISSafehouseUI.currentId = ISSafehouseUI.currentId + 1
    o.id = ISSafehouseUI.currentId 
    ISSafehouseUI.instances[o.id] = o
    return o
end

Events.OnSafehousesChanged.Add(ISSafehouseUI.OnSafehousesChanged)
Events.OnPlayerDeath.Add(ISSafehouseUI.OnPlayerDeath)

-- local p = getPlayer(); local sq = p:getCurrentSquare(); local s = SafeHouse.getSafeHouse(sq); s:addPlayer("debora"); s:syncSafehouse()
-- reloadLuaFile("/home/leonardoamaral/Zomboid/mods/usep_safehouse_plus/media/lua/client/ISUI/UserPanel/ISSafehouseUI.lua")