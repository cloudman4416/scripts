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

local function download(link, location, cache)
    local response = request({
        Url = link,
        Method = "GET",
        Headers = {
            ["If-None-Match"] = (isfile(location) and isfile(cache) and readfile(cache)) or "none"
        }
    })

    if response.StatusCode == 200 then
        writefile(cache, response.Headers.ETag or response.Headers.etag or "")
        writefile(location, response.Body)
    end
end

download("https://raw.githubusercontent.com/cloudman4416/scripts/refs/heads/main/2142948266/base.lua", "CloudHub/PJS/base", "CloudHub/PJS/cache")


local response = request({
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

download("https://raw.githubusercontent.com/cloudman4416/scripts/refs/heads/main/2142948266/translations.json", "CloudHub/PJS/translations.json", "CloudHub/PJS/transCache")

local baseUrl = `https://raw.githubusercontent.com/cloudman4416/scripts/refs/heads/main/{game.GameId}/{game.PlaceId}.lua`
local base64url = `https://api.github.com/repos/cloudman4416/scripts/contents/{game.GameId}/{game.PlaceId}.lua?ref=main`

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