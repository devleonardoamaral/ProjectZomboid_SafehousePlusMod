require "ISUI/ISPanel"
require "SP_SpawnPoints"
local UIUtils = require("ISUI/SP_UIUtils")
local SPUtils = require("SP_Utils")

ISClaimSafehouseUI = ISPanel:derive("ISClaimSafehouseUI")
ISClaimSafehouseUI.instance = nil

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

function ISClaimSafehouseUI:initialise()
    ISPanel.initialise(self)

    self.drawMethod = function ()
        self:onDrawHighlights()
    end

    Events.OnTick.Add(self.drawMethod)

    local y = 70
    local padX = 20
    local padY = 20
    local shortPadY = padY / 2

    local btnWid = (self.width - (2.5 * padX)) / 2
    local btnHgt = math.max(25, FONT_HGT_SMALL + 6)

    local statusLabelHeight = FONT_HGT_MEDIUM + 6
    local statusLabelText = getText("IGUI_ISClaimSafehousesUI_FailStatus")
    self.StatusLabel = ISLabel:new(self.width / 2, y, statusLabelHeight, statusLabelText, self.highlightNotColor.r,self.highlightNotColor.g,self.highlightNotColor.b,self.highlightNotColor.a, UIFont.Medium, true)
    self.StatusLabel.center = true
    self.StatusLabel:initialise()
    self.StatusLabel:instantiate()
    self:addChild(self.StatusLabel)
    y = y + statusLabelHeight + (padY * 1.5)

    local showHighlightTickBoxText = getText("IGUI_SafehouseUI_SafehouseLimits")
    local showHighlightTickBoxWidth = UIUtils.measureTextX(UIFont.Small, showHighlightTickBoxText) + 18
    self.showHighlightTickBox = ISTickBox:new(UIUtils.centerWidget(showHighlightTickBoxWidth, self.width), y, showHighlightTickBoxWidth, 18, "", self, ISClaimSafehouseUI.onClickShowHighlight);
    self.showHighlightTickBox:initialise()
    self.showHighlightTickBox:instantiate()
    self.showHighlightTickBox.selected[1] = self.showHighlighted
    self.showHighlightTickBox:addOption(showHighlightTickBoxText)
    self:addChild(self.showHighlightTickBox)
    y = y + UIUtils.measureFontY(UIFont.Small) + shortPadY

    self.claimButton = ISButton:new(padX, y, btnWid, btnHgt, getText("IGUI_ISClaimSafehousesUI_ClaimButton"), self, ISClaimSafehouseUI.onOptionMouseDown)
    self.claimButton.internal = "CLAIM"
    self.claimButton.backgroundColor = {r=0, g=0.3, b=0, a=0.8}
    self.claimButton.backgroundColorMouseOver = {r=0, g=0.6, b=0, a=0.8}
    self.claimButton:initialise()
    self.claimButton:instantiate()
    self.claimButton.enable = false
    self.claimButton.borderColor = self.buttonBorderColor
    self:addChild(self.claimButton)

    self.cancel = ISButton:new((padX * 1.5) + btnWid, y, btnWid, btnHgt, getText("UI_btn_close"), self, ISClaimSafehouseUI.onOptionMouseDown)
    self.cancel.internal = "CANCEL"
    self.cancel.backgroundColor = {r=0.3, g=0, b=0, a=0.8}
    self.cancel.backgroundColorMouseOver = {r=0.6, g=0, b=0, a=0.8}
    self.cancel:initialise()
    self.cancel:instantiate()
    self.cancel.borderColor = self.buttonBorderColor
    self:addChild(self.cancel)
    y = y + btnHgt + padY

    self:setHeight(y)
end

function ISClaimSafehouseUI:render()
    local titleFont = UIFont.Medium
    local titleText = getText("IGUI_ISClaimSafehousesUI_Title")

    self:drawText(
        titleText,
        UIUtils.centerTextX(titleFont, titleText, self.width),
        20,
        1,1,1,1,
        titleFont
    )
end

function ISClaimSafehouseUI:onClickShowHighlight(clickedOption, enabled)
    self.showHighlighted = enabled
end

function ISClaimSafehouseUI:onOptionMouseDown(button, x, y)
    if button.internal == "CLAIM" then
        if self:isMemberOrOwner() then
            self.claimButton.enable = false
            return
        end
        local safehouse = SafeHouse.addSafeHouse(self.x1, self.y1, self.safeWidth, self.safeHeight, self.player:getUsername(), false)
        local safehouseUI = ISSafehouseUI:new(getCore():getScreenWidth() / 2 - 250,getCore():getScreenHeight() / 2 - 225, 500, 450, safehouse, self.player)
        safehouseUI.highlightLimits = true
        safehouseUI:initialise()
        safehouseUI:addToUIManager()
        safehouseUI:bringToTop()
        self:close()
    elseif button.internal == "CANCEL" then
        self:close()
    end
end

function ISClaimSafehouseUI:updateStatusLabel(text, color)
    self.StatusLabel:setName(text)
    self.StatusLabel:setColor(color.r,color.g, color.b)
end

function ISClaimSafehouseUI:updateCoords(x1, y1, x2, y2)
    self.x1 = x1
    self.y1 = y1
    self.x2 = x2
    self.y2 = y2

    if self.x1 and self.y1 and self.x2 and self.y2 then
        self.safeWidth = x2 - x1
        self.safeHeight = y2 - y1
    else
        self.safeWidth = nil
        self.safeHeight = nil
        self:updateCanClaim()
    end
end

function ISClaimSafehouseUI:updateCanClaim()
    local status = getText("IGUI_ISClaimSafehousesUI_SuccessStatus")
    local canClaim = true
    local isResidential = false

    if self.isoBuilding then
        isResidential = self.isoBuilding:isResidential()
    end

    local allowNonResidential = getServerOptions():getOption("SafehouseAllowNonResidential") == "true" and true or false

    if self.isOwner then
        canClaim = false
        status = getText("IGUI_ISClaimSafehousesUI_isOwnerStatus")
    elseif self.isMember then
        canClaim = false
        status = getText("IGUI_ISClaimSafehousesUI_isMemberStatus")
    elseif not (self.x1 and self.y1 and self.x2 and self.y2 and self.safeWidth and self.safeHeight) then
        canClaim = false
        status = getText("IGUI_ISClaimSafehousesUI_FailStatus")
    elseif self.isTooBig then
        canClaim = false
        status = getText("IGUI_ISClaimSafehousesUI_isTooBigStatus")
    elseif not allowNonResidential and not isResidential then
        canClaim = false
        status = getText("IGUI_ISClaimSafehousesUI_ResidentialStatus")
    elseif self.overlap then
        canClaim = false
        status = getText("IGUI_ISClaimSafehousesUI_OverlapStatus")
    elseif self.occupied then
        canClaim = false
        status = getText("IGUI_ISClaimSafehousesUI_EmptyStatus")
    elseif self.isSpawn then
        canClaim = false
        status = getText("IGUI_ISClaimSafehousesUI_SpawnStatus")
    end

    self.canClaim = canClaim
    self.claimButton.enable = canClaim
    self.highlightColor = canClaim and self.highlightYesColor or self.highlightNotColor
    self:updateStatusLabel(status, self.highlightColor)
end

function ISClaimSafehouseUI:isMemberOrOwner()
    self.isMember = false
    self.isOwner = false

    if not self.isAdmin then
        local safehouses = SafeHouse.getSafehouseList()
        local playerName = self.player:getUsername()

        for i = 0, safehouses:size() - 1 do
            local safehouse = safehouses:get(i)

            if safehouse:getOwner() == playerName then
                self.isOwner = true
                self:updateCanClaim()
                return
            end

            if not SandboxVars.SafehousePlus.MultipleSafehouse then
                local players = safehouse:getPlayers()
                if players and players:contains(playerName) then
                    self.isMember = true
                    self:updateCanClaim()
                    return
                end
            end
        end
    end

    return (self.isMember or self.isOwner) and true or false
end

function ISClaimSafehouseUI:updateData()
    self.isMember = false
    self.isOwner = false

    if not self.isAdmin then
        local safehouses = SafeHouse.getSafehouseList()
        local playerName = self.player:getUsername()

        for i = 0, safehouses:size() - 1 do
            local safehouse = safehouses:get(i)

            if safehouse:getOwner() == playerName then
                self.isOwner = true
                self:updateCanClaim()
                return
            end

            if not SandboxVars.SafehousePlus.MultipleSafehouse then
                local players = safehouse:getPlayers()
                if players and players:contains(playerName) then
                    self.isMember = true
                    self:updateCanClaim()
                    return
                end
            end
        end
    end

    self.gridSquare = self.player:getCurrentSquare()

    if not self.gridSquare then 
        self:updateCoords()
        return 
    end

    self.isoBuilding = self.gridSquare:getBuilding()
    if not self.isoBuilding then 
        self:updateCoords()
        return 
    end

    self.buildingDef = self.isoBuilding:getDef()
    if not self.buildingDef then 
        self:updateCoords()
        return 
    end

    self:updateCoords(
        math.min(self.buildingDef:getX(), self.buildingDef:getX2()) - 2,
        math.min(self.buildingDef:getY(), self.buildingDef:getY2()) - 2,
        math.max(self.buildingDef:getX(), self.buildingDef:getX2()) + 2,
        math.max(self.buildingDef:getY(), self.buildingDef:getY2()) + 2
    )

    local overlap = false
    local hasIsoCharacter = false
    local isSpawn = false


    local itsTooBig = false

    if (self.safeWidth > SandboxVars.SafehousePlus.MaxSafehouseSize) or (self.safeHeight > SandboxVars.SafehousePlus.MaxSafehouseSize) then
        itsTooBig = true
    else
        local brk = false
        for x = self.x1, self.x2 - 1 do
            for y = self.y1, self.y2 - 1 do
                if SPSpawnPointSet[SPUtils.mergeInt(x, y, SPSpawnPointSetMask)] then
                    isSpawn = true
                    brk = true
                    break
                end

                local sq = getCell():getGridSquare(x, y, 0)
                if not sq then
                    itsTooBig = true
                    brk = true
                    break
                end

                if SafeHouse.getSafeHouse(sq) then
                    overlap = true
                    brk = true
                    break
                end
                
                for z=0, 7 do
                    sq = getCell():getGridSquare(x, y, z)
                    if sq then
                        if sq:getZombie() then
                            hasIsoCharacter = true
                            brk = true
                            break
                        end

                        local player = sq:getPlayer()
                        if player and player:getUsername() ~= self.player:getUsername() then
                            hasIsoCharacter = true
                            brk = true
                            break
                        end
                    end
                end

                if brk then break end
            end

            if brk then break end
        end
    end

    self.isTooBig = itsTooBig
    self.isSpawn = isSpawn
    self.occupied = hasIsoCharacter
    self.overlap = overlap
    self:updateCanClaim()
end

function ISClaimSafehouseUI:onDrawHighlights()
    -- Atualiza os dados a cada "updateSpeed" iterações
    if self.updateCounter > 0 then
        self.updateCounter = self.updateCounter - 1
    else
        self:updateData()
        self.updateCounter = self.updateSpeed
    end

    -- Verifica se as coordenadas estão válidas e se a área não é muito grande
    if not (self.x1 and self.y1 and self.x2 and self.y2) or self.isTooBig or not self.showHighlighted then 
        return 
    end

    -- Desenha highlights apenas nas bordas
    local x1, y1, x2, y2 = self.x1, self.y1, self.x2, self.y2
    local sq

    -- Desenha nas bordas horizontais (y == y1 ou y == y2 - 1)
    for x = x1, x2 - 1 do
        sq = getCell():getGridSquare(x, y1, 0)
        if sq then
            UIUtils.highlightSquare(
                sq, 
                self.highlightColor.r, 
                self.highlightColor.g, 
                self.highlightColor.b, 
                self.highlightColor.a
            )
        end
        sq = getCell():getGridSquare(x, y2 - 1, 0)
        if sq then
            UIUtils.highlightSquare(
                sq, 
                self.highlightColor.r, 
                self.highlightColor.g, 
                self.highlightColor.b, 
                self.highlightColor.a
            )
        end
    end

    -- Desenha nas bordas verticais (x == x1 ou x == x2 - 1)
    for y = y1, y2 - 1 do
        sq = getCell():getGridSquare(x1, y, 0)
        if sq then
            UIUtils.highlightSquare(
                sq, 
                self.highlightColor.r, 
                self.highlightColor.g, 
                self.highlightColor.b, 
                self.highlightColor.a
            )
        end
        sq = getCell():getGridSquare(x2 - 1, y, 0)
        if sq then
            UIUtils.highlightSquare(
                sq, 
                self.highlightColor.r, 
                self.highlightColor.g, 
                self.highlightColor.b, 
                self.highlightColor.a
            )
        end
    end
end

function ISClaimSafehouseUI:close()
    Events.OnTick.Remove(self.drawMethod)
    self:setVisible(false)
    self:removeFromUIManager()
    ISClaimSafehouseUI.instance = nil
end

function ISClaimSafehouseUI.OnPlayerDeath()
    if ISClaimSafehouseUI.instance then
        ISClaimSafehouseUI.instance:close()
    end
end

function ISClaimSafehouseUI:new(player)
    if ISClaimSafehouseUI.instance then
        ISClaimSafehouseUI.instance:close()
    end

    local width = 400
    local height = 200

    local x = (getCore():getScreenWidth() - width) / 2
    local y = (getCore():getScreenHeight() - height) - ((getCore():getScreenHeight() / 100) * 8)

    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.player = player
    o.isAdmin = o.player:isAccessLevel("admin")

    o.gridSquare = nil

    o.variableColor={r=0.9, g=0.55, b=0.1, a=1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=0.8}
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5}

    o.x1 = nil
    o.x2 = nil
    o.y1 = nil
    o.y2 = nil

    o.safeWidth = nil
    o.safeHeight = nil

    o.highlightYesColor = {r=0, g=1, b=0, a=1}
    o.highlightNotColor = {r=1, g=0, b=0, a=1}
    o.highlightPlayerColor = {r=0, g=0, b=1, a=1}

    o.highlightColor = o.highlightYesColor
    o.buildingDef = nil
    o.isoBuilding = nil

    o.canClaim = false
    o.overlap = false
    o.isTooBig = false
    o.isSpawn = false
    o.occupied = false
    o.isMember = false
    o.isOwner = false

    o.showHighlighted = SandboxVars.SafehousePlus.FloorHighlighOnClaimUIOpen

    o.updateSpeed = 100
    o.updateCounter = o.updateSpeed

    o.moveWithMouse = true

    ISClaimSafehouseUI.instance = o
    return o
end

Events.OnPlayerDeath.Add(ISClaimSafehouseUI.OnPlayerDeath)

