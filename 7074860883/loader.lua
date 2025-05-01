--Loader
repeat task.wait() until game:IsLoaded()
local client = game.Players.LocalPlayer
repeat task.wait() until client:GetAttribute("Playing")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")
GuiService.ErrorMessageChanged:Connect(function()
	task.wait(5)
	TeleportService:Teleport(87039211657390, client)
end)

local baseUrl = `https://raw.githubusercontent.com/cloudman4416/scripts/refs/heads/main/{game.GameId}/{game.PlaceId}.lua`
local base64url = `https://api.github.com/repos/cloudman4416/scripts/contents/{game.GameId}/{game.PlaceId}.lua?ref=main`

if base64 and base64.decode then
	local succ, err = pcall(function()
		local response = game:HttpGet(base64url)
		local data = HttpService:JSONDecode(response)

		local base64decoded = base64.decode(data.content:gsub("\n", ""))
		loadstring(base64decoded)()
	end)
	if not succ then
		print(err)
		loadstring(game:HttpGet(baseUrl))()
	end
else
	local succ, err = pcall(function()
		loadstring(game:HttpGet(baseUrl))()
	end)
	if not succ then
		print(err)
	end
end