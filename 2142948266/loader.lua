--Loader
local GuiService = game:GetService("GuiService")
GuiService.ErrorMessageChanged:Connect(function()
	TeleportService:Teleport(5956785391, client)
end)

if identifyexecutor() == "Solara" then
    local Library = loadstring(game:HttpGetAsync("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    local modules = "https://raw.githubusercontent.com/cloudman4416/GamesModules/refs/heads/main/Project_Slayer/"
    Library:Notify({
        Title = "Attention",
        Content = "Enabling Solara Support (Script Might Take Longer Than Usual To Load)",
        Duration = 5
    })
    getgenv().require = function(obj:LocalScript|ModuleScript)
        local succ, ret = pcall(function()
            return loadstring(decompile(obj))()
        end)
        if succ then
            print("required", obj:GetFullName())
            return ret
        else
            return loadstring(game:HttpGet(string.gsub(`{modules}{obj:GetFullName()}.lua`, " ", "%%20")))()
        end
    end
end

local baseUrl = "https://raw.githubusercontent.com/cloudman4416/scripts/refs/heads/main"

local succ, err = pcall(function()
    loadstring(game:HttpGet(`{baseUrl}/{game.GameId}/{game.PlaceId}.lua`))()
end)

if not succ then
    print(err)
end