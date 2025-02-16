require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISScrollingListBox"
require "ISUI/ISTextEntryBox"

local UIUtils = require("SP_UIUtils")

ISPlayerSafehousesUI = ISPanel:derive("ISPlayerSafehousesUI")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

function ISPlayerSafehousesUI:initialise()
    ISPanel.initialise(self)

    local y = 70
    
    self.padX = 20
    self.padY = 20
    self.shortPadX = self.padX / 2
    self.shortPadY = self.padY / 2

    self.buttonHeight = math.max(25, FONT_HGT_SMALL + 6)
    self.listBoxHeight = getCore():getScreenHeight() / 3
    self.labelHeight = FONT_HGT_SMALL + 4

    self.claimButtonText = getText("IGUI_ISPlayerSafehousesUI_ClaimButton")
    self.cancelButtonText = getText("UI_btn_close")
    self.filterEntryLabelText = getText("IGUI_ISPlayerSafehousesUI_FilterLabel") .. ":"

    self.safehousesListBoxItemNameLabel = getText("IGUI_ISPlayerSafehousesUI_ItemName") .. ": "
    self.safehousesListBoxItemOwnerLabel = getText("IGUI_ISPlayerSafehousesUI_ItemOwner") .. ": "
    self.safehousesListBoxItemCoordLabel = getText("IGUI_ISPlayerSafehousesUI_ItemCoord") .. ": "

    self.safehousesListBoxItemNameLabelWidth = UIUtils.measureTextX(UIFont.Small, self.safehousesListBoxItemNameLabel)
    self.safehousesListBoxItemOwnerLabelWidth = UIUtils.measureTextX(UIFont.Small, self.safehousesListBoxItemOwnerLabel)
    self.safehousesListBoxItemCoordLabelWidth = UIUtils.measureTextX(UIFont.Small, self.safehousesListBoxItemCoordLabel)

    self.safehousesListBoxItemNameTextWidth = UIUtils.measureTextX(UIFont.Small, "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOO")
    self.safehousesListBoxItemOwnerTextWidth = UIUtils.measureTextX(UIFont.Small, "OOOOOOOOOOOOOOOOOOOO")
    self.safehousesListBoxItemCoordTextWidth = UIUtils.measureTextX(UIFont.Small, "OOOOO,OOOOO x OOOOO,OOOOO")

    self.buttonWidth = math.max(
        UIUtils.measureTextX(UIFont.Small, self.claimButtonText),
        UIUtils.measureTextX(UIFont.Small, self.cancelButtonText)
    ) + 20

    self.safehousesListBoxWidth = (
        self.padX + (self.shortPadX * 2)
        + self.safehousesListBoxItemNameLabelWidth
        + self.safehousesListBoxItemCoordTextWidth
        + self.safehousesListBoxItemOwnerLabelWidth
        + self.safehousesListBoxItemOwnerTextWidth
        + self.safehousesListBoxItemCoordLabelWidth
        + self.safehousesListBoxItemCoordTextWidth
    )

    self.filterEntryWidth = self.safehousesListBoxWidth * 0.5
    self:setWidth(self.safehousesListBoxWidth + (2 * self.padX))

    local filterLabelHeight = UIUtils.measureFontY(UIFont.Small) + 4
    self.filterLabel = ISLabel:new(self.padX, y - filterLabelHeight, filterLabelHeight, self.filterEntryLabelText, 1,1,1,1, UIFont.Small, true)
    self.filterLabel:initialise()
    self.filterLabel:instantiate()
    self:addChild(self.filterLabel)

    self.filterEntry = ISTextEntryBox:new("", self.padX, y, self.filterEntryWidth, self.buttonHeight)
    self.filterEntry:initialise()
    self.filterEntry:instantiate()
    self:addChild(self.filterEntry)
    y = y + self.buttonHeight + self.shortPadY

    self.safehousesListBox = ISScrollingListBox:new(self.padX, y, self.safehousesListBoxWidth, self.listBoxHeight)
    self.safehousesListBox.shortPadX = self.shortPadX
    self.safehousesListBox.itemTextColor = self.itemTextColor
    self.safehousesListBox.itemNameLabel = self.safehousesListBoxItemNameLabel
    self.safehousesListBox.itemOwnerLabel = self.safehousesListBoxItemOwnerLabel
    self.safehousesListBox.itemCoordLabel = self.safehousesListBoxItemCoordLabel
    self.safehousesListBox.itemNameLabelWidth = self.safehousesListBoxItemNameLabelWidth
    self.safehousesListBox.itemOwnerLabelWidth = self.safehousesListBoxItemOwnerLabelWidth
    self.safehousesListBox.itemCoordLabelWidth = self.safehousesListBoxItemCoordLabelWidth
    self.safehousesListBox.itemNameTextWidth = self.safehousesListBoxItemNameTextWidth
    self.safehousesListBox.itemOwnerTextWidth = self.safehousesListBoxItemOwnerTextWidth
    self.safehousesListBox.itemCoordTextWidth = self.safehousesListBoxItemCoordTextWidth
    self.safehousesListBox:initialise()
    self.safehousesListBox:instantiate()
    self.safehousesListBox:setFont(UIFont.Small, 8)
    self.safehousesListBox.selected = 0
    self.safehousesListBox.joypadParent = self
    self.safehousesListBox.doDrawItem = self.doDrawItem
    self.safehousesListBox.drawBorder = true
    self.safehousesListBox.onMouseDown = ISPlayerSafehousesUI.onListBoxMouseDown
    self.safehousesListBox:setOnMouseDownFunction(self, ISPlayerSafehousesUI.showSafehouseUI)
    self:addChild(self.safehousesListBox)
    y = y + self.listBoxHeight + self.padY

    local rightButtonsXOffset = self.width - self.buttonWidth - self.padX

    self.claimButton = ISButton:new(self.padX, y, self.buttonWidth, self.buttonHeight, self.claimButtonText, self, nil, ISPlayerSafehousesUI.onOptionMouseDown)
    self.claimButton.internal = "CLAIM"
    self.claimButton.backgroundColor = {r=0, g=0.3, b=0, a=0.8}
    self.claimButton.backgroundColorMouseOver = {r=0, g=0.6, b=0, a=0.8}
    self.claimButton:initialise()
    self.claimButton:instantiate()
    self.claimButton.borderColor = self.buttonBorderColor
    self:addChild(self.claimButton)

    self.cancel = ISButton:new(rightButtonsXOffset, y, self.buttonWidth, self.buttonHeight, self.cancelButtonText, self, nil, ISPlayerSafehousesUI.onOptionMouseDown)
    self.cancel.internal = "CANCEL"
    self.cancel.backgroundColor = {r=0.3, g=0, b=0, a=0.8}
    self.cancel.backgroundColorMouseOver = {r=0.6, g=0, b=0, a=0.8}
    self.cancel:initialise()
    self.cancel:instantiate()
    self.cancel.borderColor = self.buttonBorderColor
    self:addChild(self.cancel)
    y = y + self.buttonHeight + self.padY

    self:setHeight(y)
    self:centerMiddle()
    self:populateList()
end

function ISPlayerSafehousesUI:render()
    local titleFont = UIFont.Medium
    local titleText = getText("IGUI_ISPlayerSafehousesUI_Title", string.upper(self.player:getUsername()))

    self:drawText(
        titleText,
        UIUtils.centerTextX(titleFont, titleText, self.width),
        20,
        1,1,1,1,
        titleFont
    )
end

function ISPlayerSafehousesUI:doDrawItem(y, item, alt)
	if not item.height then item.height = self.itemheight end -- compatibililty

    local mouseY = self:getMouseY()
    local mouseX = self:getMouseX()
    local itemStart = (self.itemheight * item.index) - self.itemheight
    local itemEnd = item.index * self.itemheight

    if self:isMouseOver() and mouseY > itemStart and mouseY <= itemEnd and mouseX >= 0 and mouseX <= self:getWidth() then
        self.selected = item.index
        self:drawRect(0, y, self:getWidth(), item.height-1, 0.3, 0.7, 0.35, 0.15)
    end

	self:drawRectBorder(0, y, self:getWidth(), item.height, 0.5, self.borderColor.r, self.borderColor.g, self.borderColor.b)

    local safe = item.item
    local x = self.shortPadX

	self:drawText(
        self.itemNameLabel, 
        x, y + self.itemPadY, 
        1, 1, 1, 1, 
        self.font
    )

    x = x + self.itemNameLabelWidth

    local text = safe:getTitle()
    self:drawText(
        text, 
        x, y + self.itemPadY, 
        self.itemTextColor.r, self.itemTextColor.g, self.itemTextColor.b, self.itemTextColor.a, 
        self.font
    )

    x = x + self.itemNameTextWidth + self.shortPadX

    self:drawText(
        self.itemOwnerLabel, 
        x, y + self.itemPadY, 
        1, 1, 1, 1, 
        self.font
    )

    x = x + self.itemOwnerLabelWidth

    local text = safe:getOwner()
    self:drawText(
        text, 
        x, y + self.itemPadY, 
        self.itemTextColor.r, self.itemTextColor.g, self.itemTextColor.b, self.itemTextColor.a, 
        self.font
    )

    x = self.width - self.itemCoordLabelWidth - self.itemCoordTextWidth

    self:drawText(
        self.itemCoordLabel, 
        x, y + self.itemPadY, 
        1, 1, 1, 1, 
        self.font
    )

    x = x + self.itemCoordLabelWidth

    local text = tostring(safe:getX()) .. "," .. tostring(safe:getY()) .. " x " .. tostring(safe:getX2() - 1) .. "," .. tostring(safe:getY2() - 1)
    self:drawText(
        text, 
        x, y + self.itemPadY, 
        self.itemTextColor.r, self.itemTextColor.g, self.itemTextColor.b, self.itemTextColor.a, 
        self.font
    )

	y = y + item.height
	return y
end

function ISPlayerSafehousesUI:onListBoxMouseDown(x, y)
	if #self.items == 0 then return end
	local row = self:rowAt(x, y)

	if row > #self.items then
		row = nil
    elseif row < 1 then
		row = nil
	end
	
    if row ~= nil then
        self.selected = row
        getSoundManager():playUISound("UISelectListItem")
        if self.onmousedown then
            self.onmousedown(self.target, self.items[self.selected].item);
        end
    end
end

function ISPlayerSafehousesUI:populateList(filter)
    if filter == "" or filter == nil then
        filter = nil
    end
    
    self.safehousesListBox:clear()
    for i=0, SafeHouse.getSafehouseList():size() - 1 do
        local safe = SafeHouse.getSafehouseList():get(i)
        local safeOwner = string.lower(safe:getOwner())
        local safeName = string.lower(safe:getTitle())

        if safe:playerAllowed(self.player) then
            if filter then
                local findSafeOwner = safeOwner:find(filter, 1, true)
                local findSafeName = safeName:find(filter, 1, true)

                if findSafeOwner or findSafeName then
                    self.safehousesListBox:addItem(safeName, safe)
                end
            else
                self.safehousesListBox:addItem(safeName, safe)
            end
        end
    end
end

function ISPlayerSafehousesUI.filterTask()
    if not ISPlayerSafehousesUI.instance then return end

    if ISPlayerSafehousesUI.instance.populateFrequency > 0 then
        ISPlayerSafehousesUI.instance.populateFrequency = ISPlayerSafehousesUI.instance.populateFrequency - 1
        return
    else
        ISPlayerSafehousesUI.instance.populateFrequency = ISPlayerSafehousesUI.instance.populateFrequencyMax
    end
    
    local filterText = string.lower(ISPlayerSafehousesUI.instance.filterEntry:getInternalText())
    filterText = filterText:match("^%s*(.-)%s*$")

    ISPlayerSafehousesUI.instance:populateList(filterText)
end

function ISPlayerSafehousesUI:onMouseMove(dx, dy)
    if not self.filterTaskRunning then
        self.filterTaskRunning = true
        Events.OnTick.Add(self.filterTask)
    end

    if not self.moveWithMouse then return end
    self.mouseOver = true

    if self.moving then
        if self.parent then
            self.parent:setX(self.parent.x + dx)
            self.parent:setY(self.parent.y + dy)
        else
            self:setX(self.x + dx)
            self:setY(self.y + dy)
            self:bringToTop()
        end
    end
end

function ISPlayerSafehousesUI:onMouseMoveOutside(dx, dy)
    if self.filterTaskRunning then
        Events.OnTick.Remove(self.filterTask)
        self.filterTaskRunning = false
    end
end

function ISPlayerSafehousesUI:showSafehouseUI(item)
    local safehouseUI = ISSafehouseUI:new(getCore():getScreenWidth() / 2 - 250,getCore():getScreenHeight() / 2 - 225, 500, 450, item, self.player)
    safehouseUI:initialise()
    safehouseUI:addToUIManager()
    safehouseUI:bringToTop()
    self:close()
end

function ISPlayerSafehousesUI:onOptionMouseDown(button, x, y)
    getSoundManager():playUISound("UISelectListItem")
    
    if button.internal == "CANCEL" then
        self:close()
    elseif button.internal == "VIEW" then
        self:showSafehouseUI(self, self.safehousesListBox.items[self.safehousesListBox.selected].item)
    elseif button.internal == "CLAIM" then
        local claimUI = ISClaimSafehouseUI:new(self.player)
        claimUI:initialise()
        claimUI:addToUIManager()
        claimUI:bringToTop()
        self:close()
    end
end

function ISPlayerSafehousesUI:close()
    Events.OnTick.Remove(ISPlayerSafehousesUI.filterTask)
    self:setVisible(false)
    self:removeFromUIManager()
    ISPlayerSafehousesUI.instance = nil
end

function ISPlayerSafehousesUI.OnPlayerDeath()
    if ISPlayerSafehousesUI.instance then
        ISPlayerSafehousesUI.instance:close()
    end
end

function ISPlayerSafehousesUI.OnSafehousesChanged()
    if ISPlayerSafehousesUI.instance then
        ISPlayerSafehousesUI.instance:populateList()
    end
end

function ISPlayerSafehousesUI:centerMiddle()
    local x = (getCore():getScreenWidth() - self.width) / 2
    local y = (getCore():getScreenHeight() - self.height) / 2

    self:setX(x)
    self:setY(y)
end

function ISPlayerSafehousesUI:new(player)
    if ISPlayerSafehousesUI.instance then
        ISPlayerSafehousesUI.instance:close()
    end

    local width = 700
    local height = 550

    local x = (getCore():getScreenWidth() - width) / 2
    local y = (getCore():getScreenHeight() - height) / 2

    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.player = player

    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=0.8}
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5}

    o.selectedSafehouse = nil
    o.moveWithMouse = true

    o.filterTaskRunning = false

    o.populateFrequencyMax = 10
    o.populateFrequency = 10

    o.itemTextColor = {r=0.6, g=0.6, b=1, a=1}

    ISPlayerSafehousesUI.instance = o
    return o
end

Events.OnPlayerDeath.Add(ISPlayerSafehousesUI.OnPlayerDeath)
Events.OnSafehousesChanged.Add(ISPlayerSafehousesUI.OnSafehousesChanged)