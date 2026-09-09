local ProcessMsg = {}

local ColorChart = require(script.Parent.ColorChart)
local Prefixes = require(script.Parent.Prefix)

local function EnrichText(Text)
    for Symbol,Prefix in Prefixes do
		local Pattern = Symbol .. "(.-)" .. Symbol
    
		Text = Text:gsub(Pattern, function(Content)
			return `<{Prefix}>{Content}</{Prefix}>`
		end)
    end
    return Text
end

local function PaintText(Text)
	local Pattern = "%#" .. "(.-)" .. "%(" .."(.-)".. "%)"



    Text = Text:gsub(Pattern, function(Content, FontColor)
            if not ColorChart[FontColor:lower()] then FontColor = ColorChart.black else 
                FontColor = ColorChart[FontColor:lower()]:ToHex()
            end
        return `<font color="#{FontColor}">{Content}</font>`
    end)
    return Text
end

local function CorrectText(Text)
    return Text 
end

function ProcessMsg.PreProcess(Text : string)
    if string.len(Text) > 255 or string.len(Text) == 0 then return false end

    Text = string.gsub(Text, "^%s+", "")
    Text = string.gsub(Text, "%s+$", "" )
    return Text
end

function ProcessMsg.Process(Text : string)
    Text = string.gsub(Text, "^%s+", "")
    if string.len(Text) > 250 then return end

    Text = CorrectText(Text)
    Text = EnrichText(Text)
    Text = PaintText(Text)

    return Text
end


return ProcessMsg