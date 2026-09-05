local ClientCommands = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Shared.Net)


local formats = {
	["%*%*"] = "b", -- Bold
	["%*"] = "i", -- Italic
	["%~%~"] = "s", -- Strikethrough
	["%_%_"] = "u", -- Underline

}

local Commands = {
	yell = {"yell", "y"},
	whisper = {"whisper", "w"},
	thought = {"thought", "t"}
}

-- if the command follows normal logic, then return command and msg
-- if the command follows abnormal logic, like thoughts, then return false and make your own stuff

function ClientCommands.CheckForRichText(msg)
	for symbol, tag in pairs(formats) do
		local pattern = symbol .. "(.-)" .. symbol

		msg = msg:gsub(pattern, function(content)
			return `<{tag}>{content}</{tag}>`
		end)
	end

	return msg
end

function ClientCommands.IdentifyCommand(command, msg, SendTo)
	for prefix, names in pairs(Commands) do
		for _, name in pairs(names) do
			if command:lower() == name then
				command = prefix
				return ClientCommands[command](command, msg, SendTo)
			end
		end
	end
	ClientCommands.admin(command, msg)
	return false
end

function ClientCommands.yell(command, msg)
	command = "yell"
	msg = msg:upper()
	return {command, msg}
end

function ClientCommands.whisper(command, msg)
	command = "whisper"
	msg = ("[w] "..msg)
	return {command, msg}
end

function ClientCommands.thought(command, msg, SendTo)
	command = "thought"
	msg = ("[t] "..msg)
	SendTo[LocalPlayer.Name] = true

	msg = ClientCommands.CheckForRichText(msg)
	Network.Message:send({players = SendTo, Message = msg, ChatCommand = command})
	return false
end

function ClientCommands.admin(command, msg)
	Network.AdminCommand:send({PrefixCommand = command, msg = msg})
end


return ClientCommands
