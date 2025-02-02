require "ISUI/ISPanel"
require "ISUI/UserPanel/SP_ISPlayerSafehousesUI"
UIUtils = require("ISUI/SP_UIUtils")


ISUserPanelUI = ISPanel:derive("ISUserPanelUI")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)


function ISUserPanelUI:initialise()
    ISPanel.initialise(self)

    local btnWid = 200
    local btnHgt = math.max(25, FONT_HGT_SMALL + 6)
    local tickBoxHgt = FONT_HGT_SMALL + 6

    local showSelfUsernameText = getText("IGUI_UserPanel_ShowSelfUsername")
    local showSelfUsernameWidth = UIUtils.measureTextX(UIFont.Small, showSelfUsernameText) + 20
    local showConnectionInfoText = getText("IGUI_UserPanel_ShowConnectionInfo")
    local showConnectionInfoWidth = UIUtils.measureTextX(UIFont.Small, showConnectionInfoText) + 20
    local showServerInfoInfoText = getText("IGUI_UserPanel_ShowServerInfo")
    local showServerInfoInfoWidth = UIUtils.measureTextX(UIFont.Small, showServerInfoInfoText) + 20
    local howPingInfoInfoText = getText("IGUI_UserPanel_ShowPingInfo")
    local howPingInfoInfoWidth = UIUtils.measureTextX(UIFont.Small, howPingInfoInfoText) + 20

    local tickBoxWdt = math.max(showConnectionInfoWidth, showServerInfoInfoWidth, howPingInfoInfoWidth, showSelfUsernameWidth)

    local y = 70

    self.factionBtn = ISButton:new(UIUtils.centerWidget(btnWid, self.width), y, btnWid, btnHgt, getText("UI_userpanel_factionpanel"), self, ISUserPanelUI.onOptionMouseDown)
    self.factionBtn.internal = "FACTIONPANEL"
    self.factionBtn:initialise()
    self.factionBtn:instantiate()
    self.factionBtn.borderColor = self.buttonBorderColor
    self:addChild(self.factionBtn)
    self:updateFactionButton()
    y = y + btnHgt + 5

    self.safehouseBtn = ISButton:new(UIUtils.centerWidget(btnWid, self.width), y, btnWid, btnHgt, getText("IGUI_SafehouseUI_Safehouse"), self, ISUserPanelUI.onOptionMouseDown)
    self.safehouseBtn.internal = "SAFEHOUSEPANEL"
    self.safehouseBtn:initialise()
    self.safehouseBtn:instantiate()
    self.safehouseBtn.borderColor = self.buttonBorderColor
    self:addChild(self.safehouseBtn)
    y = y + btnHgt + 25

    self.showSelfUsername = ISTickBox:new(UIUtils.centerWidget(tickBoxWdt, self.width), y, tickBoxWdt, tickBoxHgt, showSelfUsernameText, self, ISUserPanelUI.onShowSelfUsername)
    self.showSelfUsername:initialise()
    self.showSelfUsername:instantiate()
    self.showSelfUsername.selected[1] = getCore():isShowYourUsername()
    self.showSelfUsername:addOption(showSelfUsernameText)
    self:addChild(self.showSelfUsername)
    y = y + tickBoxHgt + 5

    self.showConnectionInfo = ISTickBox:new(UIUtils.centerWidget(tickBoxWdt, self.width), y, tickBoxWdt, tickBoxHgt, showConnectionInfoText, self, ISUserPanelUI.onShowConnectionInfo)
    self.showConnectionInfo:initialise()
    self.showConnectionInfo:instantiate()
    self.showConnectionInfo.selected[1] = isShowConnectionInfo()
    self.showConnectionInfo:addOption(showConnectionInfoText)
    self:addChild(self.showConnectionInfo)
    y = y + tickBoxHgt + 5

    self.showServerInfo = ISTickBox:new(UIUtils.centerWidget(tickBoxWdt, self.width), y, tickBoxWdt, tickBoxHgt, showServerInfoInfoText, self, ISUserPanelUI.onShowServerInfo)
    self.showServerInfo:initialise()
    self.showServerInfo:instantiate()
    self.showServerInfo.selected[1] = isShowServerInfo()
    self.showServerInfo:addOption(showServerInfoInfoText)
    self:addChild(self.showServerInfo)
    y = y + tickBoxHgt + 5

    self.showPingInfo = ISTickBox:new(UIUtils.centerWidget(tickBoxWdt, self.width), y, tickBoxWdt, tickBoxHgt, howPingInfoInfoText, self, ISUserPanelUI.onShowPingInfo)
    self.showPingInfo:initialise()
    self.showPingInfo:instantiate()
    self.showPingInfo.selected[1] = isShowPingInfo()
    self.showPingInfo:addOption(howPingInfoInfoText)
    self:addChild(self.showPingInfo)
    y = y + tickBoxHgt + 25

    self.cancel = ISButton:new(UIUtils.centerWidget(btnWid, self.width), y, btnWid, btnHgt, getText("UI_btn_close"), self, ISUserPanelUI.onOptionMouseDown)
    self.cancel.internal = "CANCEL"
    self.cancel.backgroundColor = {r=0.3, g=0, b=0, a=0.8}
    self.cancel.backgroundColorMouseOver = {r=0.6, g=0, b=0, a=0.8}
    self.cancel:initialise()
    self.cancel:instantiate()
    self.cancel.borderColor = self.buttonBorderColor
    self:addChild(self.cancel)
    y = y + btnHgt + 20

    self:setHeight(y)
    self.height = y
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

function ISUserPanelUI:updateFactionButton()
    if not Faction.isAlreadyInFaction(self.player) then
        self.factionBtn.title = getText("IGUI_FactionUI_CreateFaction")

        if not Faction.canCreateFaction(self.player) then
            self.factionBtn.enable = false
            self.factionBtn.tooltip = getText("IGUI_FactionUI_FactionSurvivalDay", getServerOptions():getInteger("FactionDaySurvivedToCreate"))
        end
    else
        self.factionBtn.title = getText("UI_userpanel_factionpanel")
    end
end

function ISUserPanelUI:updateSafehouseButton()
    if SafeHouse.hasSafehouse(self.player) then
        self.safehouseBtn.enable = true
        self.safehouseBtn.tooltip = nil
    else
        self.safehouseBtn.enable = false
        self.safehouseBtn.tooltip = getText("Tooltip_IGUI_UserPanel_SafehouseButton_Disabled")
    end
end

function ISUserPanelUI:render()
    self:updateFactionButton()
    self:updateSafehouseButton()

    local titleFont = UIFont.Medium
    local titleText = getText("UI_mainscreen_userpanel")

    self:drawText(
        titleText,
        UIUtils.centerTextX(titleFont, titleText, self.width),
        20,
        1,1,1,1,
        titleFont
    )
end

function ISUserPanelUI:onOptionMouseDown(button, x, y)
    if button.internal == "SAFEHOUSEPANEL" then
        if self.playerSafehousesUI then
            self.playerSafehousesUI:close()
        end
        self.playerSafehousesUI = ISPlayerSafehousesUI:new(self.player)
        self.playerSafehousesUI:initialise()
        self.playerSafehousesUI:addToUIManager()
    end

    if button.internal == "FACTIONPANEL" then
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
    end

    if button.internal == "CANCEL" then
        self:close()
    end
end

function ISUserPanelUI:close()
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

    local o = {}
    o = ISPanel:new(x, y, 240, 280)
    setmetatable(o, self)
    self.__index = self
    self.player = player
    o.variableColor={r=0.9, g=0.55, b=0.1, a=1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=0.8}
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5}
    o.zOffsetSmallFont = 25
    o.moveWithMouse = true

    o.playerSafehousesUI = nil

    ISUserPanelUI.instance = o
    return o
end

local function OnGameStart()
    setShowConnectionInfo(true)
    setShowServerInfo(false)
    setShowPingInfo(true)
end

Events.OnGameStart.Add(OnGameStart)
Events.OnPlayerDeath.Add(ISUserPanelUI.OnPlayerDeath)
