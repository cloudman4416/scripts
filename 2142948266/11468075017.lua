--DUNGEON
local options, linked, SaveManager = loadfile("CloudHub/PJS/base")()

if not options then return true end

-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local exec = identifyexecutor()
local isBadExec = false
if table.find({"Xeno", "Solara"}, exec) then
    local data = loadstring(game:HttpGet("https://raw.githubusercontent.com/cloudman4416/scripts/refs/heads/main/2142948266/modular.lua"), "modular")()
    isBadExec = true
	getgenv().require = function(source)
        return data[source:GetFullName()]
    end
end

-- VARS

for i, v in pairs(ReplicatedStorage.Ouwigahara.Bosses:GetChildren()) do
    linked.ouwi_names[v.Name] = require(v).Name
end

for i, v in pairs(ReplicatedStorage.Ouwigahara.Mobs:GetChildren()) do
    linked.ouwi_names[v.Name] = require(v).Name
end