--Loader
repeat task.wait() until game:IsLoaded()
local client = game.Players.LocalPlayer
repeat task.wait() until client:GetAttribute("Loaded")
local GuiService = game:GetService("GuiService")
GuiService.ErrorMessageChanged:Connect(function()
	TeleportService:Teleport(87039211657390, client)
end)

local baseUrl = "https://raw.githubusercontent.com/cloudman4416/scripts/refs/heads/main"

local succ, err = pcall(function()
    loadstring(game:HttpGet(`{baseUrl}/{game.GameId}/{game.PlaceId}.lua`))()
end)

if not succ then
    print(err)
end