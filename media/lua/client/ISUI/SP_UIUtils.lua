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

return UIUtils