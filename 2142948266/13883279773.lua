--MAP 1 PRIV
local options, linked, SaveManager = loadfile("CloudHub/PJS/base")()

-- SERVICES

-- VARS

options.tAutoFlower:OnChanged(function(Value)
    if Value then
        options["tAutoBoss"]:SetValue(false)
        local farmhelp = linked.farmHelper()
        while options["tAutoFlower"].Value do
            for i, v in ipairs(workspace.Demon_Flowers_Spawn:GetChildren()) do
                if v:IsA("Model") and options["tAutoFlower"].Value then
                    pcall(function()
                        linked.tweento(v:GetModelCFrame()).Completed:Wait()
                        v["Cube.002"].CFrame = v["Cube.002"].CFrame * CFrame.new(0, 5, 0)
                        task.wait(0.5)
                        fireproximityprompt(v["Cube.002"].Pick_Demon_Flower_Thing)
                        task.wait(0.5)
                    end)
                end
            end
        end
        farmhelp:Disconnect()
    end
end)