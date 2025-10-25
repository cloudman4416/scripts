--LOADER
makefolder("CloudHub")
makefolder("CloudHub/PJS")

local executor = identifyexecutor()
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
GuiService.ErrorMessageChanged:Connect(function()
	TeleportService:Teleport(18337464872, client)
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


local baseUrl = `https://raw.githubusercontent.com/cloudman4416/scripts/refs/heads/main/{game.GameId}/{game.PlaceId}.lua`
local base64url = `https://api.github.com/repos/cloudman4416/scripts/contents/{game.GameId}/{game.PlaceId}.lua?ref=main`


local function checkKey(key)
	local response = HttpService:JSONDecode(game:HttpGet("https://work.ink/_api/v2/token/isValid/" .. (key or "abcdefg")))
	if response.valid then
		writefile("CloudHub/Key", key)
		return true
	else
		return false
	end
end

makefolder("CloudHub")

--[[if not checkKey((isfile("CloudHub/Key") and readfile("CloudHub/Key"))) then
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
			Title = "Get Key Link",
			Description = "Copy the link to get key then paste in your browser",
			Callback = function()
				setclipboard("https://workink.net/1Sgk/n0noofu9")
			end
		})

		Window:SelectTab(1)

		while Fluent.Unloaded == false do task.wait() end
	end)
end]]

if table.find({"Xeno", "Solara"}, executor) then
	StarterGui:SetCore("SendNotification", {
		Title = "Cloudhub !!!";
		Text = "SOLARA and XENO dont support the entire cloudhub, some functionnalities require a better executor";
		Button1 = "Yes daddy";
		Button2 = "Okay daddy";
		Duration = math.huge;
	})
end

local succ, err = false, ""

local bindable = Instance.new("BindableFunction") -- créer une fonction bindable locale

bindable.OnInvoke = function()
    setclipboard(err) -- créer une fonction distante
end

while not succ do
    succ, err = pcall(function()
        loadstring(game:HttpGet(baseUrl))()
    end)
    if not succ then
        print(err)
		StarterGui:SetCore("SendNotification", {
			Title = "Cloudhub Bug Report";
			Text = err;
			Callback = bindable;
			Button1 = "Copy Report";
			Duration = math.huge;
		})
        task.wait(5)
    end
end