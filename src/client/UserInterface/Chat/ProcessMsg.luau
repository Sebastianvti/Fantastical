local ProcessMsg = {}

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
	local Pattern = "%C%/" .. "(.-)" .. "%C%/%(%d+%,%d+%,%d+%)"
    local Color = string.match(Text, "%d+%,%d+%,%d+")
    local Split = string.split(Color, ",")

    game:GetService("Players").LocalPlayer.PlayerGui.UserInterface.Messaging.Window.ChatWindow.BorderColor3 = Color3.fromRGB(Split[1], Split[2], Split[3]) -- not pretty but its a nothing burger code

	Text = Text:gsub(Pattern, function(Content)
		return `<font color="rgb({Color})">{Content}</font>`
	end)
    
    return Text
end

local function CorrectText(Text)
    return Text
end

function ProcessMsg.Process(Text : string)
    Text = string.gsub(Text, "^%s+", "")
    if string.len(Text) > 250 then return end

    Text = CorrectText(Text)
    Text = EnrichText(Text)
    Text = PaintText(Text)

    print(Text)
    return Text
end


return ProcessMsg