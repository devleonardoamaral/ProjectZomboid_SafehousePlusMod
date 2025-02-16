require "ISUI/ISPanel"
require "ISUI/UserPanel/SP_ISPlayerSafehousesUI"
require "ISUI/UserPanel/SP_ISClaimSafehouseUI"
local UIUtils = require("SP_UIUtils")

ISUserPanelUI = ISPanel:derive("ISUserPanelUI")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

function ISUserPanelUI:initialise()
    ISPanel.initialise(self)
    setJoypadFocus(self.playerNum, self)

    local y = 70
    
    self.titleFont = UIFont.Medium
    self.titleText = getText("UI_mainscreen_userpanel")
    
    self.buttonFont = UIFont.Small
    self.tickBoxFont = UIFont.Small
    
    self.padX = 50
    self.padY = 20
    
    self.buttonHeight = math.max(25, FONT_HGT_SMALL + 6)
    self.tickBoxHeight = FONT_HGT_SMALL + 6

    local buttonPadY = self.buttonHeight + (self.padY / 4)
    local tickBoxPadY = self.tickBoxHeight + (self.padY / 4)
    
    self.factionPanelButtonText = getText("UI_userpanel_factionpanel")
    self.factionCreateButtonText = getText("IGUI_FactionUI_CreateFaction")
    self.safehouseButtonText = getText("IGUI_SafehouseUI_Safehouse")
    self.ticketsButtonText = getText("UI_userpanel_tickets")
    self.serverOptionButtonText = getText("IGUI_AdminPanel_SeeServerOptions")
    self.cancelButtonText = getText("UI_btn_close")

    self.maxButtonWidth = math.max(
        UIUtils.measureTextX(self.buttonFont, self.factionPanelButtonText),
        UIUtils.measureTextX(self.buttonFont, self.factionCreateButtonText),
        UIUtils.measureTextX(self.buttonFont, self.safehouseButtonText),
        UIUtils.measureTextX(self.buttonFont, self.ticketsButtonText),
        UIUtils.measureTextX(self.buttonFont, self.serverOptionButtonText),
        UIUtils.measureTextX(self.buttonFont, self.cancelButtonText)
    ) + 10

    self.showSelfUsernameText = getText("IGUI_UserPanel_ShowSelfUsername")
    self.showConnectionInfoText = getText("IGUI_UserPanel_ShowConnectionInfo")
    self.showServerInfoInfoText = getText("IGUI_UserPanel_ShowServerInfo")
    self.showPingInfoInfoText = getText("IGUI_UserPanel_ShowPingInfo")

    self.maxTickBoxWidth = math.max(
        UIUtils.measureTextX(self.tickBoxFont, self.showSelfUsernameText),
        UIUtils.measureTextX(self.tickBoxFont, self.showConnectionInfoText),
        UIUtils.measureTextX(self.tickBoxFont, self.showServerInfoInfoText),
        UIUtils.measureTextX(self.tickBoxFont, self.showPingInfoInfoText)
    ) + 20

    self.maxWidgetsWidth = math.max(self.maxButtonWidth, self.maxTickBoxWidth)
    self:setWidth(self.maxWidgetsWidth + (2 * self.padX))

    self.buttonCenterX = (self.width - self.maxButtonWidth) / 2
    self.tickBoxCenterX = (self.width - self.maxTickBoxWidth) / 2

    self.factionButton = ISButton:new(self.buttonCenterX, y, self.maxButtonWidth, self.buttonHeight, self.factionPanelButtonText, self, ISUserPanelUI.onMouseClick)
    self.factionButton.internal = "FACTIONPANEL"
    self.factionButton:initialise()
    self.factionButton:instantiate()
    self.factionButton.borderColor = self.buttonBorderColor
    self:addChild(self.factionButton)
    self:updateFactionButton()
    y = y + buttonPadY

    local joypad = JoypadState.joypads[self.playerNum + 1]
    if joypad and joypad.player == self.playerNum then
        self.factionButton:setJoypadFocused(true)
    end

    table.insert(self.joypadFocusList, self.factionButton)

    self.safehouseButton = ISButton:new(self.buttonCenterX, y, self.maxButtonWidth, self.buttonHeight, self.safehouseButtonText, self, ISUserPanelUI.onMouseClick)
    self.safehouseButton.internal = "SAFEHOUSEPANEL"
    self.safehouseButton:initialise()
    self.safehouseButton:instantiate()
    self.safehouseButton.borderColor = self.buttonBorderColor
    self:addChild(self.safehouseButton)
    y = y + buttonPadY
    table.insert(self.joypadFocusList, self.safehouseButton)

    if SandboxVars.SafehousePlus.ShowTicketsButton then
        self.ticketsButton = ISButton:new(self.buttonCenterX, y, self.maxButtonWidth, self.buttonHeight, self.ticketsButtonText, self, ISUserPanelUI.onMouseClick)
        self.ticketsButton.internal = "TICKETS"
        self.ticketsButton:initialise()
        self.ticketsButton:instantiate()
        self.ticketsButton.borderColor = self.buttonBorderColor
        self:addChild(self.ticketsButton)
        y = y + buttonPadY

        table.insert(self.joypadFocusList, self.ticketsButton)
    end

    if SandboxVars.SafehousePlus.ShowServerOptionsButton then
        self.serverOptionButton = ISButton:new(self.buttonCenterX, y, self.maxButtonWidth, self.buttonHeight, self.serverOptionButtonText, self, ISUserPanelUI.onMouseClick)
        self.serverOptionButton.internal = "SERVEROPTIONS"
        self.serverOptionButton:initialise()
        self.serverOptionButton:instantiate()
        self.serverOptionButton.borderColor = self.buttonBorderColor
        self:addChild(self.serverOptionButton)
        y = y + buttonPadY

        table.insert(self.joypadFocusList, self.serverOptionButton)
    end

    y = y + self.padY

    self.showSelfUsernameTickBox = ISTickBox:new(self.tickBoxCenterX, y, self.maxTickBoxWidth, self.tickBoxHeight, self.showSelfUsernameText, self, ISUserPanelUI.onShowSelfUsername)
    self.showSelfUsernameTickBox:initialise()
    self.showSelfUsernameTickBox:instantiate()
    self.showSelfUsernameTickBox.selected[1] = getCore():isShowYourUsername()
    self.showSelfUsernameTickBox:addOption(self.showSelfUsernameText)
    self:addChild(self.showSelfUsernameTickBox)
    y = y + tickBoxPadY

    table.insert(self.joypadFocusList, self.showSelfUsernameTickBox)

    self.showConnectionInfoTickBox = ISTickBox:new(self.tickBoxCenterX, y, self.maxTickBoxWidth, self.tickBoxHeight, self.showConnectionInfoText, self, ISUserPanelUI.onShowConnectionInfo)
    self.showConnectionInfoTickBox:initialise()
    self.showConnectionInfoTickBox:instantiate()
    self.showConnectionInfoTickBox.selected[1] = isShowConnectionInfo()
    self.showConnectionInfoTickBox:addOption(self.showConnectionInfoText)
    self:addChild(self.showConnectionInfoTickBox)
    y = y + tickBoxPadY

    table.insert(self.joypadFocusList, self.showConnectionInfoTickBox)

    self.showServerInfoTickBox = ISTickBox:new(self.tickBoxCenterX, y, self.maxTickBoxWidth, self.tickBoxHeight, self.showServerInfoInfoText, self, ISUserPanelUI.onShowServerInfo)
    self.showServerInfoTickBox:initialise()
    self.showServerInfoTickBox:instantiate()
    self.showServerInfoTickBox.selected[1] = isShowServerInfo()
    self.showServerInfoTickBox:addOption(self.showServerInfoInfoText)
    self:addChild(self.showServerInfoTickBox)
    y = y + tickBoxPadY

    table.insert(self.joypadFocusList, self.showServerInfoTickBox)

    self.showPingInfoTickBox = ISTickBox:new(self.tickBoxCenterX, y, self.maxTickBoxWidth, self.tickBoxHeight, self.showPingInfoInfoText, self, ISUserPanelUI.onShowPingInfo)
    self.showPingInfoTickBox:initialise()
    self.showPingInfoTickBox:instantiate()
    self.showPingInfoTickBox.selected[1] = isShowPingInfo()
    self.showPingInfoTickBox:addOption(self.showPingInfoInfoText)
    self:addChild(self.showPingInfoTickBox)
    y = y + tickBoxPadY + self.padY

    table.insert(self.joypadFocusList, self.showPingInfoTickBox)

    self.cancelButton = ISButton:new(self.buttonCenterX, y, self.maxButtonWidth, self.buttonHeight, self.cancelButtonText, self, ISUserPanelUI.onMouseClick)
    self.cancelButton.internal = "CANCEL"
    self.cancelButton.backgroundColor = {r=0.3, g=0, b=0, a=0.8}
    self.cancelButton.backgroundColorMouseOver = {r=0.6, g=0, b=0, a=0.8}
    self.cancelButton:initialise()
    self.cancelButton:instantiate()
    self.cancelButton.borderColor = self.buttonBorderColor
    self:addChild(self.cancelButton)
    y = y + self.buttonHeight + self.padY

    table.insert(self.joypadFocusList, self.cancelButton)

    self:setHeight(y)
end

function ISUserPanelUI:getJoypadFocusWidget()
    return self.joypadFocusList[(math.abs(self.joypadFocusNum) % #self.joypadFocusList) + 1]    
end

function ISUserPanelUI:onJoypadDown(button)
    if button == Joypad.AButton then
        local currentFocus = self:getJoypadFocusWidget()
        if not currentFocus then return end

        if currentFocus.Type == "ISButton" and currentFocus.enable and currentFocus.onclick then
            currentFocus.onclick(currentFocus.target, currentFocus, 0, 0)
        elseif currentFocus.Type == "ISTickBox" and currentFocus.enable and currentFocus.changeOptionMethod ~= nil then
            currentFocus:forceClick()
        end
    elseif button == Joypad.BButton then
        self:close()
    end
end

function ISUserPanelUI:onJoypadDirUp()
    local prevFocus = self:getJoypadFocusWidget()
    if prevFocus then prevFocus:setJoypadFocused(false) end
    self.joypadFocusNum = self.joypadFocusNum - 1

    if self.joypadFocusNum < 1 then
        self.joypadFocusNum = #self.joypadFocusList
    end

    local currentFocus = self:getJoypadFocusWidget()
    currentFocus:setJoypadFocused(true)
end

function ISUserPanelUI:onJoypadDirDown()
    local prevFocus = self:getJoypadFocusWidget()
    if prevFocus then prevFocus:setJoypadFocused(false) end
    self.joypadFocusNum = self.joypadFocusNum + 1

    if self.joypadFocusNum > #self.joypadFocusList then
        self.joypadFocusNum = 1
    end

    local currentFocus = self:getJoypadFocusWidget()
    currentFocus:setJoypadFocused(true)
end

function ISUserPanelUI:updateFactionButton()
    if Faction.isAlreadyInFaction(self.player) then
        self.factionButton.title = self.factionPanelButtonText
    else
        self.factionButton.title = self.factionCreateButtonText

        if not Faction.canCreateFaction(self.player) then
            self.factionButton.enable = false
            self.factionButton.tooltip = getText("IGUI_FactionUI_FactionSurvivalDay", getServerOptions():getInteger("FactionDaySurvivedToCreate"))
        end
    end
end

function ISUserPanelUI:render()
    self:updateFactionButton()

    self:drawTextCentre(
        self.titleText,
        self.width / 2,
        self.padY,
        1,1,1,1,
        self.titleFont
    )
end

function ISUserPanelUI:setVisible(visible)
    self.javaObject:setVisible(visible)
end

function ISUserPanelUI:onShowSelfUsername(option, enabled)
    getCore():setShowYourUsername(enabled)
end

function ISUserPanelUI:onShowConnectionInfo(option, enabled)
    setShowConnectionInfo(enabled)
end

function ISUserPanelUI:onShowServerInfo(option, enabled)
    setShowServerInfo(enabled)
end

function ISUserPanelUI:onShowPingInfo(option, enabled)
    setShowPingInfo(enabled)
end

function ISUserPanelUI:onMouseClick(button, arg1, arg2, arg3, arg4)
    if button.internal == "SAFEHOUSEPANEL" then
        if self.playerSafehousesUI then
            self.playerSafehousesUI:close()
        end
        self.playerSafehousesUI = ISPlayerSafehousesUI:new(self.player)
        self.playerSafehousesUI:initialise()
        self.playerSafehousesUI:addToUIManager()
        self:close()

    elseif button.internal == "FACTIONPANEL" then
        if ISFactionUI.instance then
            ISFactionUI.instance:close()
        end
        if ISCreateFactionUI.instance then
            ISCreateFactionUI.instance:close()
        end
        if Faction.isAlreadyInFaction(self.player) then
            local modal = ISFactionUI:new(getCore():getScreenWidth() / 2 - 250, getCore():getScreenHeight() / 2 - 225, 500, 450, Faction.getPlayerFaction(self.player), self.player)
            modal:initialise()
            modal:addToUIManager()
        else
            local modal = ISCreateFactionUI:new(self.x + 100, self.y + 100, 350, 250, self.player)
            modal:initialise()
            modal:addToUIManager()
        end
        self:close()

    elseif button.internal == "TICKETS" then
        if ISTicketsUI.instance then
            ISTicketsUI.instance:close()
        end
        local modal = ISTicketsUI:new(getCore():getScreenWidth() / 2 - 250, getCore():getScreenHeight() / 2 - 225, 500, 450, self.player);
        modal:initialise();
        modal:addToUIManager();
        self:close()
    
    elseif button.internal == "SERVEROPTIONS" then
        if ISServerOptions.instance then
            ISServerOptions.instance:close()
        end
        local ui = ISServerOptions:new(50,50,600,600, self.player)
        ui:initialise();
        ui:addToUIManager();
        self:close()

    elseif button.internal == "CANCEL" then
        self:close()
    end
end

function ISUserPanelUI:close()
    setJoypadFocus(self.player:getPlayerNum(), nil)
    self:setVisible(false)
    self:removeFromUIManager()
    ISUserPanelUI.instance = nil
end

function ISUserPanelUI.OnPlayerDeath()
    if ISUserPanelUI.instance then
        ISUserPanelUI.instance:close()
    end
end

function ISUserPanelUI:new(x, y, width, height, player)
    if ISUserPanelUI.instance then
        ISUserPanelUI.instance:close()
    end

    width = 240
    height = 280

    local screenX = getCore():getScreenWidth()
    local screenY = getCore():getScreenHeight()

    if x > -1 and y > -1 then
        x = (screenX / 2) * 0.1
        y = (screenY - height) / 2 * 0.20
    else
        -- joypad support
        local posX = math.abs(x)
        local posY = math.abs(y)

        x = ((screenX / 2) * 0.1) + ((screenX / 2) * (posX - 1))
        y = ((screenY - height) / 2 * 0.20) + ((screenY / 2) * (posY - 1))
    end

    local o = {}
    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.player = player
    o.playerNum = o.player:getPlayerNum()

    o.variableColor={r=0.9, g=0.55, b=0.1, a=1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=0.8}
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5}
    o.zOffsetSmallFont = 25
    o.moveWithMouse = true

    o.joypadFocusNum = 0
    o.joypadFocusList = {}

    o.playerSafehousesUI = nil

    ISUserPanelUI.instance = o
    return o
end

local function OnGameStart()
    setShowConnectionInfo(SandboxVars.SafehousePlus.ShowConnectionInfoOnLogin)
    setShowServerInfo(SandboxVars.SafehousePlus.ShowServerInfoOnLogin)
    setShowPingInfo(SandboxVars.SafehousePlus.ShowPingOnLogin)
end

Events.OnGameStart.Add(OnGameStart)
Events.OnPlayerDeath.Add(ISUserPanelUI.OnPlayerDeath)
