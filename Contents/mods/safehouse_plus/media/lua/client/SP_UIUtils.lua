local UIUtils = {}

function UIUtils.measureFontY(font)
    return getTextManager():getFontFromEnum(font):getLineHeight()
end

function UIUtils.measureTextX(font, text)
    return getTextManager():MeasureStringX(font, text)
end

function UIUtils.centerTextX(font, text, distance)
    local textWidth = UIUtils.measureTextX(font, text)
    return (distance - textWidth) / 2
end

function UIUtils.centerWidget(widgetSize, distance)
    return (distance - widgetSize) / 2
end

function UIUtils.highlightSquare(sq, r, g, b, a)
    if sq then
        local objects = sq:getObjects()
        for n = 0, objects:size() - 1 do
            local obj = objects:get(n)
            obj:setHighlighted(true)
            obj:setHighlightColor(r, g, b, a)
        end
    end
end

-- Cria e adiciona um botão a um objeto de UI.
function UIUtils.createButton(object, x, y, width, height, text, target, onClick)
    local button = ISButton:new(x, y, width, height, text, target, onClick)
    button:initialise()
    button:instantiate()
    object:addChild(button)
    return button
end

-- Cria e adiciona um label a um objeto de UI.
function UIUtils.createLabel(object, x, y, height, text, font, color, alignLeft, center)
    local label = ISLabel:new(x, y, height, text, color.r, color.g, color.b, color.a, font, alignLeft)
    label.center = center or false
    label:initialise()
    label:instantiate()
    object:addChild(label)
    return label
end

-- Centraliza o objeto de UI na tela, garantindo que ele fique posicionado no meio horizontal e verticalmente.
function UIUtils.centerUIElementOnScreen(object, xOffset, yOffset)
    local screenWidth = getCore():getScreenWidth()
    local screenHeight = getCore():getScreenHeight()
    object:setX((screenWidth - object.width) / 2 + (xOffset or 0))
    object:setY((screenHeight - object.height) / 2 + (yOffset or 0))
end

return UIUtils