--HUB
local options, linked, SaveManager = loadfile("CloudHub/PJS/base")()

--SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")


--VARIABLES
local client = Players.LocalPlayer
local parties = ReplicatedStorage:WaitForChild("parties")

local party;while not party do
	for i,v in parties:GetChildren() do
		if v.ownerid.Value == game.Players.LocalPlayer.Name then
			party = v
		end
	end
	task.wait()
end

for i, v in options do
    if typeof(v) == "table" and v.OnChanged then
        v:OnChanged(function() end)
    end
end

options.tHubJoin:OnChanged(function(Value)
    if Value then
        repeat ReplicatedStorage:WaitForChild("change_game_mode"):FireServer(party.gamemodeequiped, options.dHubMode.Value); task.wait(0.1) until party.gamemodeequiped.Value == options.dHubMode.Value
        ReplicatedStorage:WaitForChild("queu_up"):FireServer()
    end
end)

SaveManager:LoadAutoloadConfig()