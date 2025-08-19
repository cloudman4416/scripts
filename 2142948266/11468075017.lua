--DUNGEON
local options, linked, SaveManager = loadfile("CloudHub/PJS/base")()

-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- VARS

for i, v in pairs(ReplicatedStorage.Ouwigahara.Bosses:GetChildren()) do
    linked.ouwi_names[v.Name] = require(v).Name
end

for i, v in pairs(ReplicatedStorage.Ouwigahara.Mobs:GetChildren()) do
    linked.ouwi_names[v.Name] = require(v).Name
end