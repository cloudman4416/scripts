--Loader
local executor = identifyexecutor()
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
GuiService.ErrorMessageChanged:Connect(function()
	TeleportService:Teleport(5956785391, client)
end)

local fixeable = {
    "Solara";
    "Xeno"
}

if table.find(fixeable, executor) then
    local Library = loadstring(game:HttpGetAsync("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    local modules = "https://raw.githubusercontent.com/cloudman4416/GamesModules/refs/heads/main/Project_Slayer/"
    Library:Notify({
        Title = "Attention",
        Content = `Enabling {executor} Support (Script Might Take Longer Than Usual To Load)`,
        Duration = 5
    })
    getgenv().require = function(obj:LocalScript|ModuleScript)
        local succ, ret = pcall(function()
            return loadstring(decompile(obj))()
        end)
        if succ then
            return ret
        else
            return loadstring(game:HttpGet(string.gsub(`{modules}{obj:GetFullName()}.lua`, " ", "%%20")))()
        end
    end
end

local baseUrl = `https://raw.githubusercontent.com/cloudman4416/scripts/refs/heads/main/{game.GameId}/{game.PlaceId}.lua`
local base64url = `https://api.github.com/repos/cloudman4416/scripts/contents/{game.GameId}/{game.PlaceId}.lua?ref=main`

if base64 and base64.decode then
    local response = game:HttpGet(base64url)
    local data = HttpService:JSONDecode(response)

    local base64decoded = base64.decode(data.content:gsub("\n", ""))
    loadstring(base64decoded)()
else
	local succ, err = pcall(function()
		loadstring(game:HttpGet(baseurl))()
	end)
	
	if not succ then
		print(err)
	end
end