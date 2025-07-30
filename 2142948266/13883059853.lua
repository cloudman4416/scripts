--MAP 2 PRIV
local options, linked, SaveManager = loadfile("CloudHub/PJS/base")()

-- SERVICES
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- VARS
local client = Players.LocalPlayer
repeat task.wait() until ReplicatedStorage.Player_Data:FindFirstChild(client.Name)
local playerValues = ReplicatedStorage.PlayerValues:WaitForChild(client.Name, 1)
local playerData = ReplicatedStorage.Player_Data:WaitForChild(client.Name, 1)
local Handle_Initiate_S = ReplicatedStorage.Remotes.To_Server:WaitForChild("Handle_Initiate_S")
local Handle_Initiate_S_ = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("To_Server"):WaitForChild("Handle_Initiate_S_")
local gameId = game.PlaceId


linked.bosses = {}
for i, v in workspace.Mobs.Bosses:GetDescendants() do
    if v:IsA("Configuration") and v:FindFirstChild("Npc_Configuration") then
        local info = require(v.Npc_Configuration)
        linked.bosses[info["Name"]] = info["Npc_Spawning"]["Spawn_Locations"][1]
    end
end
local temp = {
    workspace.Mobs.Heikin["Reaper Boss"];
    workspace.Mobs.Village_1_quest_bandits.BanditBoss;
}
for i, v in temp do
    local info = require(v.Npc_Configuration)
    linked.bosses[info["Name"]] = info["Npc_Spawning"]["Spawn_Locations"][1]
end

temp = nil