require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISScrollingListBox"
require "ISUI/ISTextEntryBox"

UIUtils = require("ISUI/SP_UIUtils")

ISPlayerSafehousesUI = ISPanel:derive("ISSafehousesList")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

function ISPlayerSafehousesUI:initialise()
    ISPanel.initialise(self)

    local padX = 20
    local padY = 20
    local btnWid = (self.width / 2) - (padX * 1.5)
    local btnHgt = math.max(25, FONT_HGT_SMALL + 6)

    local y = 70

    local datasWidth = self.width - (padX * 2)
    local datasHeight = 365
    self.datas = ISScrollingListBox:new(UIUtils.centerWidget(datasWidth, self.width), y, datasWidth, datasHeight)
    self.datas:initialise()
    self.datas:instantiate()
    self.datas:setFont(UIFont.Small, 8)
    self.datas.selected = 0
    self.datas.joypadParent = self
    self.datas.doDrawItem = self.doDrawItem
    self.datas.drawBorder = true
    self.datas.onMouseDown = ISPlayerSafehousesUI.onListBoxMouseDown
    self.datas:setOnMouseDownFunction(self, ISPlayerSafehousesUI.showSafehouseUI)
    self:addChild(self.datas)
    y = y + datasHeight + padY

    local filterLabelHeight = UIUtils.measureFontY(UIFont.Small) + 4
    self.filterLabel = ISLabel:new(padX, y, filterLabelHeight, getText("IGUI_ISPlayerSafehousesUI_FilterLabel") .. ":", 1,1,1,1, UIFont.Small, true)
    self.filterLabel:initialise()
    self.filterLabel:instantiate()
    self:addChild(self.filterLabel)
    y = y + filterLabelHeight

    self.filterEntry = ISTextEntryBox:new("",padX, y, btnWid, btnHgt)
    self.filterEntry:initialise()
    self.filterEntry:instantiate()
    self:addChild(self.filterEntry)

    self.cancel = ISButton:new(self.width - btnWid - padX, y, btnWid, btnHgt, getText("UI_btn_close"), self, nil, ISPlayerSafehousesUI.onOptionMouseDown)
    self.cancel.internal = "CANCEL"
    self.cancel.backgroundColor = {r=0.3, g=0, b=0, a=0.8}
    self.cancel.backgroundColorMouseOver = {r=0.6, g=0, b=0, a=0.8}
    self.cancel:initialise()
    self.cancel:instantiate()
    self.cancel.borderColor = self.buttonBorderColor
    self:addChild(self.cancel)
    y = y + btnHgt + padY

    self:setHeight(y)
    self.height = y

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
    local textPadX = 15
    local x = textPadX

    local label = getText("IGUI_ISPlayerSafehousesUI_ItemName") .. ": "
    local labelWidth = UIUtils.measureTextX(UIFont.NewSmall, label)
	self:drawText(label, x, y + self.itemPadY, 1, 1, 1, 1, self.font)
    x = x + labelWidth

    local text = safe:getTitle()
    local textWidth = UIUtils.measureTextX(self.font, text)
    self:drawText(text, x, y + self.itemPadY, 0.9, 0.9, 0.9, 0.9, self.font)
    x = self:getWidth() / 3

    local label = getText("IGUI_ISPlayerSafehousesUI_ItemOwner") .. ": "
    local labelWidth = UIUtils.measureTextX(UIFont.NewSmall, label)
	self:drawText(label, x, y + self.itemPadY, 1, 1, 1, 1, self.font)
    x = x + labelWidth

    local text = safe:getOwner()
    local textWidth = UIUtils.measureTextX(self.font, text)
    self:drawText(text, x, y + self.itemPadY, 0.9, 0.9, 0.9, 0.9, self.font)
    
    local label = getText("IGUI_ISPlayerSafehousesUI_ItemCoord") .. ": "
    local labelWidth = UIUtils.measureTextX(UIFont.NewSmall, label)
    local text = tostring(safe:getX()) .. "," .. tostring(safe:getY()) .. " x " .. tostring(safe:getX2()) .. "," .. tostring(safe:getY2())
    local textWidth = UIUtils.measureTextX(self.font, text)
    x = self:getWidth() - 225

	self:drawText(label, x, y + self.itemPadY, 1, 1, 1, 1, self.font)
    x = x + labelWidth
    self:drawText(text, x, y + self.itemPadY, 0.9, 0.9, 0.9, 0.9, self.font)

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
    
    self.datas:clear()
    for i=0, SafeHouse.getSafehouseList():size() - 1 do
        local safe = SafeHouse.getSafehouseList():get(i)
        local safeOwner = string.lower(safe:getOwner())
        local safeName = string.lower(safe:getTitle())

        if safe:playerAllowed(self.player) then
            if filter then
                local findSafeOwner = safeOwner:find(filter, 1, true)
                local findSafeName = safeName:find(filter, 1, true)

                if findSafeOwner or findSafeName then
                    self.datas:addItem(safeName, safe)
                end
            else
                self.datas:addItem(safeName, safe)
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
end

function ISPlayerSafehousesUI:onOptionMouseDown(button, x, y)
    getSoundManager():playUISound("UISelectListItem")
    
    if button.internal == "CANCEL" then
        self:close()
    elseif button.internal == "VIEW" then
        self:showSafehouseUI(self, self.datas.items[self.datas.selected].item)
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

function ISPlayerSafehousesUI:new(player)
    if ISPlayerSafehousesUI.instance then
        ISPlayerSafehousesUI.instance:close()
    end

    local width = 700
    local height = 550

    x = (getCore():getScreenWidth() - width) / 2
    y = (getCore():getScreenHeight() - height) / 2

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

    o.populateFrequencyMax = 50
    o.populateFrequency = 50
    ISPlayerSafehousesUI.instance = o
    return o
end

Events.OnPlayerDeath.Add(ISPlayerSafehousesUI.OnPlayerDeath)

-- local p = getPlayer(); local sq = p:getCurrentSquare(); local s = SafeHouse.getSafeHouse(sq); print(s:playerAllowed(p))