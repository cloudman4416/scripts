--LOBBY
local options, linked, SaveManager = loadfile("CloudHub/PJS/base")()

local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local client = game.Players.LocalPlayer
local maps = {
    ["Map 1"] = 17387475546;
    ["Map 2"] = 17387482786;
    ["Hub"] = 9321822839;
}


for i, v in options do
    if typeof(v) == "table" and v.OnChanged then
        v:OnChanged(function() end)
    end
end

options.tAutoJoin:OnChanged(function(Value)
    task.spawn(function()
        if Value then
            repeat task.wait() until game:IsLoaded()
            workspace.Is_Customization_place:WaitForChild("Slot3")
            client:WaitForChild("Slot")
            ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Apply_Slot"):InvokeServer(options["sSlot"].Value)
            while task.wait(1) do
                if options["tAutoJoin"].Value then
                    if options["iCode"].Value ~= "" then
                        game:GetService("ReplicatedStorage"):WaitForChild("handle_privateserver"):InvokeServer("join", options["iCode"].Value, maps[options["dMapSelect"].Value])
                    else
                        TeleportService:Teleport(maps[options["dMapSelect"].Value], client)
                    end
                end
            end
        end
    end)
end)

SaveManager:LoadAutoloadConfig()