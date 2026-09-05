local Finalizer = {}

local TextChatService = game:GetService("TextChatService")

-- Written by Inker831, Approx 25th June, 2026

-- Abbreviations and their full forms
local abbreviations = {
	["mp"] = "Military Police",
	["sg"] = "Stationary Guard",
	["rc"] = "Reclamation Corps",
	["sl"] = "Scouting Legion",
	["ugc"] = "Asyle",
	["tc"] = "Trainee Corps",
	["idc"] = "I don't care",
	["idk"] = "I don't know",
}

-- Formatting symbols
local formats = {
	{"%%", "b"},
	{"%*%", "u"},
	{"%~%~", "s"},
	{"%*", "i"},
}

local function makeCaseInsensitive(str)
	local pattern = ""
	for i = 1, #str do
		local char = str:sub(i, i)
		if char:match("%a") then
			local lower = char:lower()
			local upper = char:upper()
			pattern = pattern .. "[" .. lower .. upper .. "]"
		else
			pattern = pattern .. char
		end
	end
	return pattern
end

local function replaceAbbreviations(message)
	for abbr, fullForm in pairs(abbreviations) do
		local ciPattern = makeCaseInsensitive(abbr)
		local pattern = "%f[%a]" .. ciPattern .. "%f[%A]"

		message = string.gsub(message, pattern, fullForm)
	end

	return message
end

-- ensure that the first letter of a sentence is capitalized despite other symbols before it.
local function capitalizeSentences(message)
	message = message:gsub("^%s*(%a)", function(c) return c:upper() end)
	message = message:gsub("([.!?]%s+)(%a)", function(punct, c) return punct .. c:upper() end)
	return message
end

local function checkForRichText(msg)
	for _, formatData in ipairs(formats) do
		local symbol = formatData[1]
		local tag = formatData[2]
		local pattern = symbol .. "(.-)" .. symbol

		msg = msg:gsub(pattern, function(content)
			return "<" .. tag .. ">" .. content .. "</" .. tag .. ">"
		end)
	end

	return msg
end

function Finalizer.Process(msg)
	msg = replaceAbbreviations(msg)
--	msg = capitalizeSentences(msg) removed until next chat system development period
	msg = checkForRichText(msg)
	
	return msg
end


-- Public

return Finalizer
