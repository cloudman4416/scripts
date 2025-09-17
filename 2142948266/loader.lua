--LOADER
makefolder("CloudHub")
makefolder("CloudHub/PJS")

local executor = identifyexecutor()
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("StarterGui")
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

local function checkKey(key)
	local response = HttpService:JSONDecode(game:HttpGet("https://work.ink/_api/v2/token/isValid/" .. key or "abcdefg"))
	if response.valid then
		writefile("CloudHub/Key", response.info.token)
		return true
	else
		
		return false
	end
end

makefolder("CloudHub")

if not (isfile("CloudHub/Key") and checkKey(readfile("CloudHub/Key"))) then
	pcall(function()
		local Fluent = loadstring(game:HttpGet("https://github.com/cloudman4416/Fluent_Clone/releases/latest/download/main.lua"))()
		local options = Fluent.Options

		local Window = Fluent:CreateWindow({
			Title = "Key System",
			SubTitle = "CloudHub",
			TabWidth = 160,
			Size = UDim2.fromOffset(580, 340),
			Acrylic = false,
			Theme = "Obsidian",
			MinimizeKey = Enum.KeyCode.LeftControl
		})

		local Tabs = {
			KeySys = Window:AddTab({ Title = "Key System", Icon = "key" }),
		}

		local Entkey = Tabs.KeySys:AddInput("Input", {
				Title = "Enter Key",
				Description = "Enter Key Here",
				Default = "",
				Placeholder = "Enter key…",
				Numeric = false,
				Finished = false,
		})

		local Checkkey = Tabs.KeySys:AddButton({
			Title = "Check Key",
			Description = "Enter Key before pressing this button",
			Callback = function()
				if checkKey(options.Input.Value) then
					Fluent:Destroy()
				else
					Fluent:Notify({
						Title = "Key System",
						Content = "Invalide Key",
						Duration = 20
					})
				end
			end
		})

		local Getkey = Tabs.KeySys:AddButton({
			Title = "Get Key",
			Description = "Get Key here",
			Callback = function()
				setclipboard("https://workink.net/1Sgk/n0noofu9")
			end
		})

		Window:SelectTab(1)

		while Fluent.Unloaded == false do task.wait() end
	end)
end


local succ, err = false, ""

local bindable = Instance.new("BindableFunction") -- créer une fonction bindable locale

bindable.OnInvoke = function()
    setclipboard(err) -- créer une fonction distante pour cela
end

while not succ do
    succ, err = pcall(function()
        loadstring(game:HttpGet(baseUrl))()
    end)
    if not succ then
        print(err)
		CoreGui:SetCore("SendNotification", {
			Title = "Cloudhub Bug Report";
			Text = err;
			Callback = bindable;
			Button1 = "Copy Report";
			Duration = math.huge;
		})
        task.wait(5)
    end
end