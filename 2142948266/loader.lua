--LOADER
makefolder("CloudHub")
makefolder("CloudHub/PJS")

local executor = identifyexecutor()
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
GuiService.ErrorMessageChanged:Connect(function()
	TeleportService:Teleport(5956785391, client)
end)

local response = request({
    Url = "https://raw.githubusercontent.com/cloudman4416/scripts/refs/heads/main/2142948266/base.lua",
    Method = "GET",
    Headers = {
        ["If-None-Match"] = (isfile("CloudHub/PJS/base") and isfile("CloudHub/PJS/cache") and readfile("CloudHub/PJS/cache")) or "none"
    }
})

if response.StatusCode == 200 then
    writefile("CloudHub/PJS/cache", response.Headers.ETag or response.Headers.etag or "")
    writefile("CloudHub/PJS/base", response.Body)
end

response = request({
    Url = "https://raw.githubusercontent.com/cloudman4416/scripts/refs/heads/main/logo.webp",
    Method = "GET",
    Headers = {
        ["If-None-Match"] = (isfile("CloudHub/logo.webp") and isfile("CloudHub/cache") and readfile("CloudHub/cache")) or "none"
    }
})

if response.StatusCode == 200 then
    -- Only fetch the image again if changed
    local image = game:HttpGet("https://raw.githubusercontent.com/cloudman4416/scripts/refs/heads/main/logo.webp")
    writefile("CloudHub/logo.webp", image)
    writefile("CloudHub/cache", response.Headers.ETag or response.Headers.etag or "")
end


--[[local fixeable = {
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
end]]

local baseUrl = `https://raw.githubusercontent.com/cloudman4416/scripts/refs/heads/main/{game.GameId}/{game.PlaceId}.lua`
local base64url = `https://api.github.com/repos/cloudman4416/scripts/contents/{game.GameId}/{game.PlaceId}.lua?ref=main`

--[[if base64 and base64.decode then
    local response = game:HttpGet(base64url)
    local data = HttpService:JSONDecode(response)

    local base64decoded = base64.decode(data.content:gsub("\n", ""))
    loadstring(base64decoded)()
else
	local succ, err = pcall(function()
		loadstring(game:HttpGet(baseUrl))()
	end)
	
	if not succ then
		print(err)
	end
end]]
local succ, err;
while not succ do
    succ, err = pcall(function()
        loadstring(game:HttpGet(baseUrl))()
    end)
    if not succ then
        print(err)
        task.wait(3)
    end
end