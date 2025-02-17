require "ISUI/ISPanel"
require "SP_SpawnPoints"
local UIUtils = require("SP_UIUtils")
local SPUtils = require("SP_Utils")

ISClaimSafehouseUI = ISPanel:derive("ISClaimSafehouseUI")
ISClaimSafehouseUI.instance = nil

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

function ISClaimSafehouseUI:initialise()
    ISPanel.initialise(self)

    local y = 70

    self.label_StatusMessage = UIUtils.createLabel(
        self, self.width / 2, y,
        self.mediumLabelHeight,
        self.statusText_OutsideArea,
        UIFont.Medium,
        self.highlightNotColor,
        true, 
        true
    )

    y = y + self.mediumLabelHeight + (self.padY * 1.5)

    self.label_Dimensions = UIUtils.createLabel(
        self, ((self.width - (2 * self.padX)) / 4) + self.padX, y,
        self.smallLabelHeight,
        getText("IGUI_ISClaimSafehousesUI_Label_Dimensions"),
        UIFont.Small,
        self.defaultTextColor,
        true, 
        true
    )
        
    self.label_Floors = UIUtils.createLabel(
        self, self.width / 2, y,
        self.smallLabelHeight,
        getText("IGUI_ISClaimSafehousesUI_Label_Floors"),
        UIFont.Small,
        self.defaultTextColor,
        true, 
        true
    )

    self.label_Area = UIUtils.createLabel(
        self, (((self.width - (2 * self.padX)) / 4) * 3) + self.padX, y,
        self.smallLabelHeight,
        getText("IGUI_ISClaimSafehousesUI_Label_Area"),
        UIFont.Small,
        self.defaultTextColor,
        true, 
        true
    )

    y = y + self.smallLabelHeight

    self.label_DimensionsText = UIUtils.createLabel(
        self, ((self.width - (2 * self.padX)) / 4) + self.padX, y,
        self.mediumLabelHeight,
        getText("IGUI_ISClaimSafehousesUI_Label_Unavailable"),
        UIFont.Medium,
        self.infoTextColor,
        true, 
        true
    )

    self.label_FloorsText = UIUtils.createLabel(
        self, self.width / 2, y,
        self.mediumLabelHeight,
        getText("IGUI_ISClaimSafehousesUI_Label_Unavailable"),
        UIFont.Medium,
        self.infoTextColor,
        true, 
        true
    )

    self.label_AreaText = UIUtils.createLabel(
        self, (((self.width - (2 * self.padX)) / 4) * 3) + self.padX, y,
        self.mediumLabelHeight,
        getText("IGUI_ISClaimSafehousesUI_Label_Unavailable"),
        UIFont.Medium,
        self.infoTextColor,
        true, 
        true
    )

    y = y + self.mediumLabelHeight + self.padY

    self.showHighlightTickBox = ISTickBox:new(
        UIUtils.centerWidget(self.tickBoxWidth, self.width), 
        y, 
        self.tickBoxWidth, 18, 
        "", 
        self, 
        ISClaimSafehouseUI.onClickShowHighlight
    )
    self.showHighlightTickBox:initialise()
    self.showHighlightTickBox:instantiate()
    self.showHighlightTickBox.selected[1] = self.isPerimeterHighlighted
    self.showHighlightTickBox:addOption(self.tickBoxText_highlightLocation)
    self:addChild(self.showHighlightTickBox)
    y = y + FONT_HGT_SMALL + self.padY

    self.claimButton = UIUtils.createButton(
        self, self.padX, y, 
        self.buttonWidth, self.buttonHeight,
        self.buttonText_Claim, 
        self, ISClaimSafehouseUI.onOptionMouseDown
    )
    self.claimButton.internal = "CLAIM"
    self.claimButton.backgroundColor = self.claimButton_bgColor
    self.claimButton.backgroundColorMouseOver = self.claimButton_bgColor_MouseOver
    self.claimButton.enable = false

    self.cancelButton = UIUtils.createButton(
        self, self.width - self.buttonWidth - self.padX, y, 
        self.buttonWidth, self.buttonHeight,
        self.buttonText_Cancel, 
        self, ISClaimSafehouseUI.onOptionMouseDown
    )
    self.cancelButton.internal = "CANCEL"
    self.cancelButton.backgroundColor = self.cancelButton_bgColor
    self.cancelButton.backgroundColorMouseOver = self.cancelButton_bgColor_MouseOver

    y = y + self.buttonHeight + self.padY

    self:setHeight(y)
    UIUtils.centerUIElementOnScreen(self, 0, (getCore():getScreenHeight() / 2) - (self.height * 0.80))

    if self.isPerimeterHighlighted then
        self:startDrawHighlightTask()
    end
end

function ISClaimSafehouseUI:stopDrawHighlightTask()
    Events.OnTick.Remove(self.drawMethod)
end

function ISClaimSafehouseUI:startDrawHighlightTask()
    self.drawMethod = function () self:onDrawHighlights() end
    Events.OnTick.Add(self.drawMethod)
end

function ISClaimSafehouseUI:render()
    self:drawTextCentre(
        self.titleText,
        self.width / 2,
        self.padY,
        1,1,1,1,
        self.titleFont
    )
end

function ISClaimSafehouseUI:onClickShowHighlight(clickedOption, enabled)
    if enabled then
        self:startDrawHighlightTask()
    else
        self:stopDrawHighlightTask() 
    end

    self.isPerimeterHighlighted = enabled
end

function ISClaimSafehouseUI:onOptionMouseDown(button)
    if button.internal == "CLAIM" then
        self:updateData()
        if not self.canClaim then
            self.claimButton.enable = false
            return
        end
        local safehouse = SafeHouse.addSafeHouse(self.x1, self.y1, self.safeWidth, self.safeHeight, self.player:getUsername(), false)
        safehouse:syncSafehouse()
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
    self.label_StatusMessage:setName(text)
    self.label_StatusMessage:setColor(color.r,color.g, color.b)
end

function ISClaimSafehouseUI:updateLocationInfos()
    if self.safeHeight and self.safeWidth and self.safeFloors then
        self.label_AreaText:setName(tostring(self.safeWidth * self.safeHeight) .. " " .. getText("IGUI_ISClaimSafehousesUI_Tiles") .. getText("IGUI_ISClaimSafehousesUI_Power"))
        self.label_DimensionsText:setName(tostring(self.safeWidth) .. " x " .. tostring(self.safeHeight))
        self.label_FloorsText:setName(tostring(self.safeFloors))
    else
        self.label_AreaText:setName(getText("IGUI_ISClaimSafehousesUI_Label_Unavailable"))
        self.label_DimensionsText:setName(getText("IGUI_ISClaimSafehousesUI_Label_Unavailable"))
        self.label_FloorsText:setName(getText("IGUI_ISClaimSafehousesUI_Label_Unavailable"))
    end
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
    end
end

function ISClaimSafehouseUI:updateCanClaim()
    local status = self.statusText_Success
    local canClaim = true
    local isResidential = false

    if self.isoBuilding then
        isResidential = self.isoBuilding:isResidential()
    end

    local allowNonResidential = getServerOptions():getOption("SafehouseAllowNonResidential") == "true" and true or false

    if not self.survivedLongEnough then
        canClaim = false
        status = self.statusText_SurvivalDaysRequired
    elseif self.isReachedLimit then
        canClaim = false
        status = self.statusText_MaxSafehousesReached
    elseif self.isMember then
        canClaim = false
        status = self.statusText_AlreadyMember
    elseif self.exceedsMaxFloors then
        canClaim = false
        status = self.statusText_ExceedsMaxFloors
    elseif not (self.x1 and self.y1 and self.x2 and self.y2 and self.safeWidth and self.safeHeight) then
        canClaim = false
        status = self.statusText_OutsideArea
    elseif self.isTooBig then
        canClaim = false
        status = self.statusText_AreaTooLarge
    elseif not allowNonResidential and not isResidential then
        canClaim = false
        status = self.statusText_NotResidential
    elseif self.overlap then
        canClaim = false
        status = self.statusText_OverlapExistingSafehouse
    elseif self.occupied then
        canClaim = false
        status = self.statusText_ClaimBlockedByEntities
    elseif self.isSpawn then
        canClaim = false
        status = self.statusText_SpawnLocation
    end

    self.canClaim = canClaim
    self.claimButton.enable = canClaim
    self.highlightColor = canClaim and self.highlightYesColor or self.highlightNotColor
    self:updateStatusLabel(status, self.highlightColor)
    self:updateLocationInfos()
end

function ISClaimSafehouseUI:isSafehouseMember()
    local isMember = false
    local safehouses = SafeHouse.getSafehouseList()

    for i = 0, safehouses:size() - 1 do
        local safehouse = safehouses:get(i)
        local players = safehouse:getPlayers()

        if players and players:contains(self.username) then
            isMember = true
        end
    end

    return isMember
end

function ISClaimSafehouseUI:updateData()
    self.isMember = false
    self.isReachedLimit = false
    self.exceedsMaxFloors = false
    self.survivedLongEnough = true
    
    if not self.isAdmin then
        self.survivedLongEnough = math.floor(self.player:getHoursSurvived() / 24) >= self.survivedDaysToClaim
    
        if not self.survivedLongEnough then
            self:updateCanClaim()
            return
        end

        local numOwnedSafehouses = #Utils.getOwnedSafehouses(self.username)

        if numOwnedSafehouses >= self.maxSafehousesLimit then
            self.isReachedLimit = true
            self:updateCanClaim()
            return
        end

        if not SandboxVars.SafehousePlus.MultipleSafehouse then
            if self:isSafehouseMember() then
                self.isMember = true
                self:updateCanClaim()
                return
            end
        end
    end

    self.gridSquare = self.player:getCurrentSquare()

    if not self.gridSquare then 
        self:updateCoords()
        self:updateCanClaim()
        return 
    end

    self.isoBuilding = self.gridSquare:getBuilding()
    if not self.isoBuilding then 
        self:updateCoords()
        self:updateCanClaim()
        return 
    end

    self.buildingDef = self.isoBuilding:getDef()
    if not self.buildingDef then 
        self:updateCoords()
        self:updateCanClaim()
        return 
    end
    
    local rooms = self.buildingDef:getRooms()
    self.safeFloors = 0

    for i = 0, rooms:size() - 1 do
        local room = rooms:get(i)
        local z = room:getZ()

        if z > self.safeFloors then
            self.safeFloors = z
        end
    end

    self:updateCoords(
        math.min(self.buildingDef:getX(), self.buildingDef:getX2()) - 2,
        math.min(self.buildingDef:getY(), self.buildingDef:getY2()) - 2,
        math.max(self.buildingDef:getX(), self.buildingDef:getX2()) + 2,
        math.max(self.buildingDef:getY(), self.buildingDef:getY2()) + 2
    )

    if self.safeFloors > SandboxVars.SafehousePlus.MaxSafehouseFloors then
        self.exceedsMaxFloors = true
        self:updateCanClaim()
        return
    end

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
                
                for z=0, self.safeFloors do
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
    if self.updateCounter > 0 then
        self.updateCounter = self.updateCounter - 1
    else
        self:updateData()
        self.updateCounter = self.updateSpeed
    end

    local playerSq = self.player:getCurrentSquare()

    if playerSq then
        UIUtils.highlightSquare(
            playerSq, 
            self.highlightColor.r, 
            self.highlightColor.g, 
            self.highlightColor.b, 
            self.highlightColor.a
        )
    end

    -- Verifica se as coordenadas estão válidas e se a área não é muito grande
    if not (self.x1 and self.y1 and self.x2 and self.y2) or self.isTooBig or not self.isPerimeterHighlighted then 
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
    self:stopDrawHighlightTask() 
    self:setVisible(false)
    self:removeFromUIManager()
    ISClaimSafehouseUI.instance = nil
end

function ISClaimSafehouseUI:new(player)
    -- Verifica se já existe uma instância e a fecha, se necessário
    if ISClaimSafehouseUI.instance then
        ISClaimSafehouseUI.instance:close()
    end

    -- Configurações iniciais da janela
    local width = 400
    local height = 200
    local x = 0
    local y = 0

    -- Cria uma nova instância da UI
    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    -- Definições dos widgets
    o.padX = 20
    o.padY = 20
    o.shortPadX = o.padX / 2
    o.shortPadY = o.padY / 2

    -- Cores para destaque (highlight)
    o.highlightYesColor = {r=0, g=1, b=0, a=1}
    o.highlightNotColor = {r=1, g=0, b=0, a=1}
    o.highlightPlayerColor = {r=0, g=0, b=1, a=1}

    -- Cores da UI
    o.claimButton_bgColor = {r=0, g=0.3, b=0, a=0.8}
    o.claimButton_bgColor_MouseOver = {r=0, g=0.6, b=0, a=0.8}
    o.cancelButton_bgColor = {r=0.3, g=0, b=0, a=0.8}
    o.cancelButton_bgColor_MouseOver = {r=0.6, g=0, b=0, a=0.8}

    -- Cores do Texto
    o.defaultTextColor = {r=1, g=1, b=1, a=1}
    o.infoTextColor = {r=0.6, g=0.6, b=1,a=1}

    -- Configurações do jogador e da UI
    o.player = player
    o.username = player:getUsername()
    o.isAdmin = o.player:isAccessLevel("admin")
    o.survivedDaysToClaim = tonumber(getServerOptions():getOption("SafehouseDaySurvivedToClaim"))
    o.isPerimeterHighlighted = SandboxVars.SafehousePlus.FloorHighlighOnClaimUIOpen

    local vipPlayers = SPUtils.splitStringIntoLookupTable(SandboxVars.SafehousePlus.SpecialPlayersList, ";")
    local isVip = vipPlayers[o.username]

    o.maxSafehousesLimit = (
        isVip
        and SandboxVars.SafehousePlus.SpecialPlayersOwnerLimit 
        or SandboxVars.SafehousePlus.OwnerLimit
    )

    -- Configurações de atualização
    o.updateSpeed = 30
    o.updateCounter = o.updateSpeed

    -- Configurações de interação
    o.moveWithMouse = true

    -- Variáveis de estado da UI
    o.gridSquare = nil
    o.x1, o.x2, o.y1, o.y2 = nil, nil, nil, nil
    o.safeWidth, o.safeHeight = nil, nil
    o.highlightColor = o.highlightYesColor
    o.buildingDef = nil
    o.isoBuilding = nil
    o.safeFloors = nil

    -- Variáveis de validação
    o.canClaim = false
    o.overlap = false
    o.isTooBig = false
    o.isSpawn = false
    o.occupied = false
    o.isMember = false
    o.isReachedLimit = false
    o.exceedsMaxFloors = false

    -- Textos traduzidos para a UI
    o.titleText = getText("IGUI_ISClaimSafehousesUI_Title")
    o.buttonText_Claim = getText("IGUI_ISClaimSafehousesUI_Button_Claim")
    o.buttonText_Cancel = getText("UI_btn_close")
    o.tickBoxText_highlightLocation = getText("IGUI_SafehouseUI_TickBox_HighlightLocation")
    o.statusText_Success = getText("IGUI_ISClaimSafehousesUI_Status_Success")
    o.statusText_OutsideArea = getText("IGUI_ISClaimSafehousesUI_Status_OutsideArea")
    o.statusText_OverlapExistingSafehouse = getText("IGUI_ISClaimSafehousesUI_Status_OverlapsExistingSafehouse")
    o.statusText_NotResidential = getText("IGUI_ISClaimSafehousesUI_Status_NotResidential")
    o.statusText_ClaimBlockedByEntities = getText("IGUI_ISClaimSafehousesUI_Status_ClaimBlockedByEntities")
    o.statusText_SpawnLocation = getText("IGUI_ISClaimSafehousesUI_Status_SpawnLocation")
    o.statusText_AreaTooLarge = getText("IGUI_ISClaimSafehousesUI_Status_AreaTooLarge")
    o.statusText_AlreadyMember = getText("IGUI_ISClaimSafehousesUI_Status_AlreadyMember")
    o.statusText_MaxSafehousesReached = getText("IGUI_ISClaimSafehousesUI_Status_MaxSafehousesReached")
    o.statusText_SurvivalDaysRequired = getText("IGUI_ISClaimSafehousesUI_Status_SurvivalDaysRequired", o.survivedDaysToClaim)
    o.statusText_ExceedsMaxFloors = getText("IGUI_ISClaimSafehousesUI_Status_ExceedsMaxFloors")

    -- Fontes
    o.font = UIFont.Small
    o.titleFont = UIFont.Medium
    o.font_Height = UIUtils.measureFontY(o.font)
    o.titleFont_Height = UIUtils.measureFontY(o.titleFont)

    -- Diensões dos textos
    o.titleText_Width = UIUtils.measureTextX(o.titleFont, o.titleText)
    o.buttonText_Claim_Width = UIUtils.measureTextX(o.font, o.buttonText_Claim)
    o.buttonText_Cancel_Width = UIUtils.measureTextX(o.font, o.buttonText_Cancel)
    o.statusText_Success_Width = UIUtils.measureTextX(o.font, o.statusText_Success)
    o.statusText_OutsideArea_Width = UIUtils.measureTextX(o.font, o.statusText_OutsideArea)
    o.statusText_OverlapExistingSafehouse_Width = UIUtils.measureTextX(o.font, o.statusText_OverlapExistingSafehouse)
    o.statusText_NotResidential_Width = UIUtils.measureTextX(o.font, o.statusText_NotResidential)
    o.statusText_ClaimBlockedByEntities_Width = UIUtils.measureTextX(o.font, o.statusText_ClaimBlockedByEntities)
    o.statusText_SpawnLocation_Width = UIUtils.measureTextX(o.font, o.statusText_SpawnLocation)
    o.statusText_AreaTooLarge_Width = UIUtils.measureTextX(o.font, o.statusText_AreaTooLarge)
    o.statusText_AlreadyMember_Width = UIUtils.measureTextX(o.font, o.statusText_AlreadyMember)
    o.statusText_MaxSafehousesReached_Width = UIUtils.measureTextX(o.font, o.statusText_MaxSafehousesReached)
    o.statusText_SurvivalDaysRequired_Width = UIUtils.measureTextX(o.font, o.statusText_SurvivalDaysRequired)

    -- Calcula a largura máxima dos textos de status
    o.maxStatusTextWidth = math.max(
        o.statusText_OutsideArea_Width,
        o.statusText_Success_Width,
        o.statusText_AlreadyMember_Width,
        o.statusText_AreaTooLarge_Width,
        o.statusText_OverlapExistingSafehouse_Width,
        o.statusText_NotResidential_Width,
        o.statusText_ClaimBlockedByEntities_Width,
        o.statusText_SpawnLocation_Width,
        o.statusText_MaxSafehousesReached_Width
    )

    -- Dimensões dos widgets
    o.buttonHeight = math.max(25, FONT_HGT_SMALL + 6)
    o.minButtonWidth = 200
    o.buttonWidth = math.max(
        (math.max(o.titleText_Width, o.maxStatusTextWidth) / 2) - o.shortPadX,
        (math.max(o.buttonText_Claim_Width, o.buttonText_Cancel_Width) / 2) + o.padX,
        o.minButtonWidth
    )

    o.mediumLabelHeight = FONT_HGT_SMALL + 6
    o.smallLabelHeight = FONT_HGT_SMALL + 4

    o.tickBoxWidth = UIUtils.measureTextX(UIFont.Small, o.tickBoxText_highlightLocation) + 18

    o:setWidth(
        math.max(
            o.titleText_Width,
            o.maxStatusTextWidth,
            (o.buttonWidth * 2) + o.shortPadX
        ) + (2 * o.padX)
    )

    -- Armazena a instância atual na classe
    ISClaimSafehouseUI.instance = o
    return o
end

function ISClaimSafehouseUI.OnPlayerDeath()
    if ISClaimSafehouseUI.instance then
        ISClaimSafehouseUI.instance:close()
    end
end

Events.OnPlayerDeath.Add(ISClaimSafehouseUI.OnPlayerDeath)
