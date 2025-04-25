--Loader
local GuiService = game:GetService("GuiService")
GuiService.ErrorMessageChanged:Connect(function()
	TeleportService:Teleport(5956785391, client)
end)

local baseUrl = "https://raw.githubusercontent.com/cloudman4416/scripts/refs/heads/main"

local succ, err = pcall(function()
    loadstring(game:HttpGet(`{baseUrl}/{game.GameId}/{game.PlaceId}.lua`))()
end)

if not succ then
    print(err)
end